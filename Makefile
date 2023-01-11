# Makefile for Node-RED using IBM Container Registry and IBM Code Engine

ICR_ID=de.icr.io/node-red-raptho
IMG_NAME:="node-red"
IMG_VERSION:="1.0"
CE_PROJECT_NAME="node-red"
CE_APP="node-red"
NODE_RED_USERNAME=raphael
NODE_RED_PASSWORD=
API_KEY=

default: build run

build:
	podman build --rm -t $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --build-arg NODE_RED_USERNAME=$(NODE_RED_USERNAME) --build-arg NODE_RED_PASSWORD=$(NODE_RED_PASSWORD) --layers=false .
	podman image prune --filter label=stage=builder --force

run:
	podman run -d \
          --name ${IMG_NAME} \
          --env-file ./code-engine-secrets \
          -p 1880:1880 \
          --restart unless-stopped \
          $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

stop:
	@podman rm -f ${IMG_NAME} >/dev/null 2>&1 || :

clean:
	@podman rmi -f $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) >/dev/null 2>&1 || :
	podman image prune --filter label=stage=builder --force

login:
	ibmcloud login --sso
	ibmcloud cr region-set eu-central
	ibmcloud target -g Default
	ibmcloud cr login --client podman

rm-old:
	ibmcloud cr image-rm $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

push:
	podman push $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION)

apikey-create:
	ibmcloud iam api-key-create makefile-node-red -d "API Key for Makefile Automation Node-RED on IBM Code Engine"

apikey-delete:
	ibmcloud iam api-key-delete -f makefile-node-red

code-engine-create:
	ibmcloud ce project create -n $(CE_PROJECT_NAME)
	ibmcloud ce registry create --name ibm-container-registry --server de.icr.io --username iamapikey --password $(API_KEY)
	ibmcloud ce secret create --name node-red-config --from-env-file code-engine-secrets
	ibmcloud ce app create --name node-red --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --registry-secret ibm-container-registry --env-from-secret node-red-config  --port 1880 --min-scale 1 --max-scale 1 --cpu 0.25 --memory 0.5G 

code-engine-update:
	ibmcloud ce project select -n $(CE_PROJECT_NAME)
	ibmcloud ce app get -n $(CE_APP)
	ibmcloud ce secret update --name node-red-config --from-env-file code-engine-secrets
	ibmcloud ce app update --name $(CE_APP) --image $(ICR_ID)/$(IMG_NAME):$(IMG_VERSION) --registry-secret ibm-container-registry --port 1880 --min-scale 1 --max-scale 1 --cpu 0.25 --memory 0.5G --env-from-secret node-red-config
	ibmcloud ce app logs --name $(CE_APP)

code-engine-delete:
	ibmcloud ce project delete -n $(CE_PROJECT_NAME) --hard --no-wait -f

.PHONY: build run push stop clean
