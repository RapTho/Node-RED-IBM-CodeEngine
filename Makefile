# Makefile for Node-RED apps using IBM Container Registry and IBM Code Engine

ICR_ID=de.icr.io/node-red-raptho
IMG_NAME:="node-red"
IMG_VERSION:="1.0"
CE_PROJECT_NAME="node-red"
CE_APP="node-red"
NODE_RED_USERNAME=adltm
NODE_RED_PASSWORD=1234
ARCH:="amd64"

# Leave blank for open DockerHub containers
# CONTAINER_CREDS:=-r "registry.wherever.com:myid:mypw"

default: build run

build:
	echo podman build --rm -t $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) .
	podman build --rm -t $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) .
	podman image prune --filter label=stage=builder --force

dev: stop build
	podman run -it --name ${IMG_NAME} \
          $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) /bin/bash

run: stop
	podman run -d \
          --name ${IMG_NAME} \
          --env-file ./code-engine-secrets \
          -p 1880:1880 \
          --restart unless-stopped \
          $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

test:
	xdg-open http://127.0.0.1:1880

ui:
	xdg-open http://127.0.0.1:1880/ui

stop:
	@podman rm -f ${IMG_NAME} >/dev/null 2>&1 || :

clean:
	@podman rmi -f $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) >/dev/null 2>&1 || :
	podman image prune --filter label=stage=builder --force

login:
	ibmcloud login --sso
	ibmcloud cr login
	ibmcloud cr region-set eu-central
	ibmcloud target -g Default
	ibmcloud cr login --client podman

rm-old:
	ibmcloud cr image-rm $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

push:
	podman push $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

code-engine-create:
	ibmcloud ce registry create --name ibm-container-registry
	ibmcloud ce secret create --name node-red-config --from-env-file code-engine-secrets
	ibmcloud ce application create --name node-red --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

code-engine:
	ibmcloud ce project list
	ibmcloud ce project select -n $(CE_PROJECT_NAME)
	ibmcloud ce application list
	ibmcloud ce application get -n $(CE_APP)
	ibmcloud ce secret update --name node-red-config --from-env-file code-engine-secrets
	#ibmcloud ce registry create --name ibm-container-registry --server de.icr.io --username $(NODE_RED_USERNAME) --password $(NODE_RED_PASSWORD)
	ibmcloud ce app update --name $(CE_APP) --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --port 1880 --max-scale 1 --cpu 0.25 --memory 0.5G --env-from-secret node-red-config --registry-secret ibm-container-registry
	ibmcloud ce app logs --name $(CE_APP)

code-engine-delete-app:
	ibmcloud ce application delete --name $(CE_APP)

multiarch:
	echo podman build --arch $(ARCH) -t $(ICR_ID)/$(IMG_NAME)-arm64:$(IMG_VERSION) -f Dockerfile
	podman build --arch $(ARCH) -t $(ICR_ID)/$(IMG_NAME)-arm64:$(IMG_VERSION) -f Dockerfile
	podman image prune --filter label=stage=builder --force

.PHONY: build dev run push test ui stop clean
