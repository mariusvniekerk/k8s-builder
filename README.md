# conda-forge k8s-builder

This will attempt to perform a build for an arbitrary feedstock on a target kubernetes cluster (Assumed to be managed GKS for now).

Build artifacts are store on gcs.

Currently this makes a large number of assumptions about how a kubernetes cluster is configured.

TODO:
* Add kubernetes resources showing the general shape of the cluster and its setup
* Test GPU containers
* Windows containers for a gold star?

