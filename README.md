# k3s on Github Actions

A GitHub Action for running k3s kubernetes cluster


## How it works
 * Action is by itself a docker container with docker and kubectl installed
 * Action is launching k3s container and some checks to ensure kubernetes is up and running
 * Optionally (by default, but can be turned off) installs kubectl (copies over) to enable hassle-free k8s interaction

## Optional Input parameters
 * k3s_tag - k3s tag to use. (can be found at https://hub.docker.com/r/rancher/k3s/tags)
 * parent_workspace - workspace path on runner, obtainer from context, no need to specify anything here, except you know what you're doing
 * registries_yaml_path - relative path of registries.yaml
 * kubectl_version
 * install_kubectl - enabled by default, copies kubectl to bin dir in workspace to allow other steps to use kubectl
 * k3s_arguments - by default set to `--no-deploy=traefik`

## Required parameters
 * custom_registry - set to 'true' to mount your `registries.yaml` to k3s. This will allow to use private registry mapping in k3s. (set to `false` if you don't have such needs)
 
### GitHub Actions
```
# File: .github/workflows/ci.yml
name: k3s
on:
  push:
    branches:
      - master
  pull_request:
env:
  KUBECONFIG: k3s.yaml
jobs:
  k3s:
    name: k3s
    runs-on: ubuntu-latest
    steps:
      - name: checkout code
        uses: actions/checkout@master
      - name: k3s
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
