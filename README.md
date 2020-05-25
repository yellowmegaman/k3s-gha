# k3s on Github Actions

A GitHub Action for running k3s kubernetes cluster


## How it works
 * Action is by itself a docker container with docker and kubectl installed
 * Action is launching k3s container and some checks to ensure kubernetes is up and running
 * Optionally (by default, but can be turned off) installs kubectl (copies over) to enable hassle-free k8s interaction

### GitHub Actions
```
# File: .github/workflows/ci.yml
name: CI
on:
  push:
    branches:
      - master
  pull_request:
env:
  KUBECONFIG: k3s.yaml
jobs:
  lint:
    name: lint
    runs-on: ubuntu-latest
    steps:
      - name: checkout code
        uses: actions/checkout@master
      - name: k3s
        id: k3s
        uses: yellowmegaman/k3s-gha@master
        with:
          custom_registry: true
      - name: try to use kubeconfig
        run: kubectl get ns
```

This will result in something similar:
```
Run kubectl get ns
NAME              STATUS   AGE
default           Active   52s
kube-system       Active   51s
kube-public       Active   51s
kube-node-lease   Active   51s
```
