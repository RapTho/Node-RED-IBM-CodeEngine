# Build a Node-RED Docker Container

Take a look at the `Dockerfile` and `Makefile` to build a Docker container which will run
Node-RED and this flow.

Modify the Dockerfile to include your Docker userid.

```sh
DOCKERHUB_ID:=<your Docker Hub ID>
```

To build/run/test the container, run some of these `make` commands:

```sh
make build
make run
make test
make ui
make stop
make clean
```

### Authors

- [John Walicki](https://github.com/johnwalicki)
- [Raphael Tholl](https://github.com/RapTho)

---

## License

This tutorial is licensed under the Apache Software License, Version 2. Separate third party code objects invoked within this code pattern are licensed by their respective providers pursuant to their own separate licenses. Contributions are subject to the [Developer Certificate of Origin, Version 1.1 (DCO)](https://developercertificate.org/) and the [Apache Software License, Version 2](http://www.apache.org/licenses/LICENSE-2.0.txt).
