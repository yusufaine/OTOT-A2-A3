NC="\033[0m"
GR="\033[0;32m"
RD="\033[0;31m"

echo deleteing ingress...
kubectl delete ingress backend-ingress-zone-aware

echo deleteing ingress controller...
kubectl delete -n ingress-nginx deploy ingress-nginx-controller

echo deleting service...
kubectl delete service backend-svc-zone-aware

echo deleteing deployment...
kubectl delete deploy backend-zone-aware

echo deleteing cluster...
kind delete cluster --name a3-demo

