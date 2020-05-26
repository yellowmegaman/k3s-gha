#!/bin/bash -e

### install kubectl
curl -L -s --create-dirs https://storage.googleapis.com/kubernetes-release/release/"$INPUT_KUBECTL_VERSION"/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

export KUBECONFIG=k3s.yaml
export RUNNER_HOSTNAME=$(docker info --format '{{lower .Name}}')

docker run -d --name=k3s --privileged --tmpfs /run --tmpfs /var/run -p 6443:6443 -p 80:80 $(if [ "$INPUT_CUSTOM_REGISTRY" = true ]; then echo --mount "type=bind,src=$RUNNER_WORKSPACE/$(echo $RUNNER_WORKSPACE | sed 's|.*/||')/$INPUT_REGISTRIES_YAML_PATH,dst=/etc/rancher/k3s/registries.yaml"; fi) rancher/k3s:$INPUT_K3S_TAG server "$INPUT_K3S_ARGUMENTS"

sleep 15

docker cp k3s:/etc/rancher/k3s/k3s.yaml .
sed -i "s/127.0.0.1/$RUNNER_HOSTNAME/g" k3s.yaml

echo 'wait for k3s'
for attempt in {1..60}; do
	if kubectl version; then
		break;
	elif [ "$attempt" -eq 60 ]; then
		echo "timeout reached"
		exit 1
	else
		echo "k3s is not yet up"
		sleep 3
	fi
done

kubectl -n kube-system rollout status deploy/coredns --timeout=120s

echo 'get all resources'
kubectl get all --all-namespaces

chmod a+r k3s.yaml

### 'copy kubectl over'

if [ "$INPUT_INSTALL_KUBECTL" = true ]; then
	mkdir -p bin
	cp /usr/local/bin/kubectl bin/kubectl
	chmod a+x bin/kubectl
	echo "::add-path::$INPUT_PARENT_WORKSPACE/bin"
fi
