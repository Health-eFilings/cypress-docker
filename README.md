# Cypress

This repository is used in [dockerhub](https://hub.docker.com/r/healthefilings/cypress) in order to build a cypress image ready to be used in GC Kubernetes.

If we use the original image the app is not able to create files inside the container so we need to set the permissions to the folders that app needs or override configurations.
