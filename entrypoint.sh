#!/bin/bash -e

export KUBECONFIG=k3s.yaml

touch k3s.yaml

pwd
ls
whoami

docker run -d --name=k3s --privileged --tmpfs /run --tmpfs /var/run -p 6443:6443 -p 80:80 -v "$PWD"/k3s.yaml:/etc/rancher/k3s/k3s.yaml -v "$PWD"/registries.yaml:/etc/rancher/k3s/registries.yaml rancher/k3s:$INPUT_K3S_TAG server

docker ps

echo '#######################################'
docker inspect k3s
echo '#######################################'


sleep 5
netstat -plunt

nslookup k3s
nc -zv k3s 6443

echo 'wait for k3s'
for attempt in {1..60}; do
	if kubectl version; then
		exit;
	else
		echo "k3s is not yet up"
		sleep 3
	fi
done

echo 'wait for traefik is READY'
for attempt in {1..60}; do
	if kubectl -n kube-system get pod -o custom-columns=POD:metadata.name,READY:status.containerStatuses[*].ready | grep true | grep '^traefik'; then
		exit
	elif [ "$attempt" -eq 60 ]; then
		exit 1
	else
		sleep 1; echo -n '.'
	fi
done

echo 'wait for coredns is READY'

for attempt in {1..60}; do
	if kubectl -n kube-system get pod -o custom-columns=POD:metadata.name,READY:status.containerStatuses[*].ready | grep true | grep '^coredns'; then
		exit
	elif [ "$attempt" -eq 60 ]; then
		exit 1
	else
		sleep 1
		echo -n '.'
	fi
done


echo 'get all resources'
kubectl get all --all-namespaces

echo "::set-output name=kubeconfig::$(cat k3s.yaml)"
