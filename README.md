# conda-forge k8s-builder

This will attempt to perform a build for an arbitrary feedstock on a target kubernetes cluster.

Does not currently work, due to path issues it seems.

We need to adjust the behavior of conda-build in order for it to build inside the container
instead of on a volume mounted thing


The DIND behavior is super flaky and we should not use it.

TODO: Refactor to just use our build containers directly


