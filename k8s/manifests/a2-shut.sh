NC="\033[0m"
GR="\033[0;32m"
RD="\033[0;31m"

echo deleteing ingress...
kubectl delete ingress backend-ingress

echo deleteing ingress controller...
kubectl delete -n ingress-nginx deploy ingress-nginx-controller

echo deleting service...
kubectl delete service backend-svc

echo deleteing deployment...
kubectl delete deploy backend

echo deleteing cluster...
kind delete cluster --name a2-demo

