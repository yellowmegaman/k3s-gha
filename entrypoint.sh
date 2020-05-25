#!/bin/bash -e

export KUBECONFIG=k3s.yaml
export RUNNER_HOSTNAME=$(docker info --format '{{lower .Name}}')

docker run -d --name=k3s --privileged --tmpfs /run --tmpfs /var/run -p 6443:6443 -p 80:80 $(if [ "$INTPUT_CUSTOM_REGISTRY" = true ]; then echo --mount "type=bind,src=$INPUT_PARENT_WORKSPACE/registries.yaml,dst=/etc/rancher/k3s/registries.yaml"; fi) rancher/k3s:$INPUT_K3S_TAG server

sleep 15

docker cp k3s:/etc/rancher/k3s/k3s.yaml .
sed -i "s/127.0.0.1/$RUNNER_HOSTNAME/g" k3s.yaml

echo 'wait for k3s'
for attempt in {1..60}; do
	if kubectl version; then
		break;
	else
		echo "k3s is not yet up"
		sleep 3
	fi
done

echo 'wait for traefik is READY'
for attempt in {1..60}; do
	if kubectl -n kube-system get pod -o custom-columns=POD:metadata.name,READY:status.containerStatuses[*].ready | grep true | grep '^traefik'; then
		break
	elif [ "$attempt" -eq 60 ]; then
		exit 1
	else
		sleep 1; echo -n '.'
	fi
done

echo 'wait for coredns is READY'

for attempt in {1..60}; do
	if kubectl -n kube-system get pod -o custom-columns=POD:metadata.name,READY:status.containerStatuses[*].ready | grep true | grep '^coredns'; then
		break
	elif [ "$attempt" -eq 60 ]; then
		exit 1
	else
		sleep 1
		echo -n '.'
	fi
done


echo 'get all resources'
kubectl get all --all-namespaces

chmod a+r k3s.yaml

### copy kubectl over

if [ "$INTPUT_INSTALL_KUBECTL" = true ]; then
	mkdir bin
	cp /usr/local/bin/kubectl bin/kubectl
	chmod a+x bin/kubectl
	echo "::add-path::$INPUT_PARENT_WORKSPACE/bin"
fi
