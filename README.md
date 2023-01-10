# Build a Node-RED Docker Container

Take a look at the [Dockerfile](Dockerfile) and [Makefile](Makefile) to build a Docker container which will run
Node-RED and this flow.

To build/run/push/deploy the container, run some of these `make` commands:

```sh
make build
make run
make stop
make clean
make login
make rm-old
make push
make apikey-create
make apikey-delete
make code-engine-create
make code-engine-update
make code-engine-delete
```

## Prerequisites

- [podman](https://podman.io/getting-started/installation)
- [IBM Cloud account](https://cloud.ibm.com/)
- [IBM Cloud CLI](https://cloud.ibm.com/docs/cli?topic=cli-getting-started)
- [IBM Container Registry](https://cloud.ibm.com/registry/catalog) instance
- [IBM Code Engine](https://cloud.ibm.com/codeengine/overview) instance

Install ibmcloud cli plugins "Code Engine" and "Container Registry"

```
ibmcloud plugin install code-engine
ibmcloud plugin install container-registry
```

## How to use

[Makefile](Makefile) variables. Set your API-KEY once created and a password for the Node-RED editor

```
ICR_ID=de.icr.io/node-red-raptho
IMG_NAME:="node-red"
IMG_VERSION:="1.0"
CE_PROJECT_NAME="node-red"
CE_APP="node-red"
NODE_RED_USERNAME=raphael
NODE_RED_PASSWORD=
API_KEY=
```

To secure publicly deployed Node-RED editor, set the same Node-RED related credentials also in the [code-engine-secrets](code-engine-secrets) file

```
NODE_RED_USERNAME=raphael
NODE_RED_PASSWORD=
NODE_RED_GUEST_ACCESS=false
```

### Authors

- [John Walicki](https://github.com/johnwalicki)
- [Raphael Tholl](https://github.com/RapTho)

---

## License

This tutorial is licensed under the Apache Software License, Version 2. Separate third party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1 (DCO)](https://developercertificate.org/) and the [Apache Software License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).

```

```
