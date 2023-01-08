# Secure Node-RED editor by generating bcrypt hash and store it in settings.js
FROM registry.access.redhat.com/ubi9:9.0.0-1640 as hasher

ARG NODE_RED_USERNAME
ARG NODE_RED_PASSWORD

WORKDIR /settings
COPY settings.js /settings/
RUN yum install -y httpd-tools &&\
    PWHASH=$(htpasswd -nbBC 10 ${NODE_RED_USERNAME} ${NODE_RED_PASSWORD} | cut -d ':' -f 2) &&\
    sed -i 's/admin/'"${NODE_RED_USERNAME}/" settings.js &&\
    sed -i 's/mybcrypthash/'"${PWHASH}/" settings.js

# Build image
# Dockerhub official node:18.12.1
FROM node@sha256:24fa671fefd72b475dd41365717920770bb2702a4fccfd9ef300a3b7f60d6555 as build
LABEL stage=builder

WORKDIR /opt/app-root/data
COPY ["package.json", "flows.json", "flows_cred.json", "/opt/app-root/data/"]
COPY --from=hasher /settings/settings.js /opt/app-root/data/
RUN npm install --no-audit --no-fund --omit=dev

## Release image
# Dockerhub official node:18.12.1-slim
FROM node@sha256:0c3ea57b6c560f83120801e222691d9bd187c605605185810752a19225b5e4d9

WORKDIR /opt/app-root/data
COPY --from=build /opt/app-root/data /opt/app-root/data/
RUN chown -R node:node /opt/app-root/data
USER node

ENV PORT 1880
ENV NODE_ENV=production
ENV NODE_PATH=/opt/app-root/data/node_modules
EXPOSE 1880

CMD ["node", "/opt/app-root/data/node_modules/node-red/red.js", "--setting", "/opt/app-root/data/settings.js", "/opt/app-root/data/flows.json"]
