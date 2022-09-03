NC="\033[0m"
GR="\033[1;32m"
GR1="\033[0;32m"
YL="\033[0;33m"

cname="a2-demo"
ctx="kind-a2-demo"

function pauseMsg() {
  echo "${1}"
  read -rsn 2
}

#########################################################################

echo "\nRunning A2 demo script\n"

echo "${GR}Creating clusters${NC}"
kind create cluster --name $cname --config ./cluster-config.yaml
echo ""

kubectl cluster-info
kubectl get nodes 

pauseMsg "\n${GR1}Press any key to create the deployment.${NC}"

echo "\n${GR}Creating deployment with the following variables:${NC}"
echo "  ${GR1}name :${NC} backend" 
echo "  ${GR1}label:${NC} backend" 
echo "  ${GR1}image:${NC} yusufaine/nodejs-app"
echo "  ${GR1}port :${NC} 3000\n"

kubectl apply -f ./nodejs-deploy.yaml 

echo "\n${YL}Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=45s 
echo ""
kubectl get po -l app=backend 


pauseMsg "\n${GR1}Press any key to create the service.${NC}"

echo "\n${GR}Creating service with the following variables:${NC}"
echo "  ${GR1}name :${NC} backend-svc" 
echo "  ${GR1}label:${NC} backend" 
echo "  ${GR1}port :${NC} 3000\n"

kubectl apply -f ./nodejs-svc.yaml

echo "\n${YL}Printing service details...${NC}"
kubectl describe svc backend-svc
echo
kubectl get svc -l app=backend
echo "\n${YL}Run the following commands in new terminal sessions:"
echo "  - ${GR1}kubectl port-forward service/backend-svc 8080:3000${NC}"
echo "  - ${GR1}curl -s localhost:8080 | grep -E \"Matric|Name\"${NC}" 
# pauseMsg ""

pauseMsg "\n${GR1}Press any key to create the NGINX ingress controller.${NC}"

echo "\n${GR}Creating NGINX ingress controller${NC}"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml" 

echo "\n${YL}Waiting for NGINX ingress controller to be ready...${NC}"
ns="ingress-nginx"
sr="app.kubernetes.io/component=controller"
kubectl wait --namespace $ns --for=condition=ready pod --selector=$sr --timeout 45s
kubectl --namespace $ns get po -l $sr 
kubectl -n $ns get deploy 

pauseMsg "\n${GR1}Press any key to create the image's ingress object.${NC}"

echo "\n${GR}Creating ingress object of yusufaine/nodejs-app${NC}"
kubectl apply -f nodejs-ingress-obj.yaml 

echo "\n${YL}Waiting for nodejs-ingress-obj to be ready...${NC}"
sleep 45
kubectl get ingress -l app=backend 

echo "\n${YL}A2 demo is now ready to be tested. Run the following command."
pauseMsg "  - ${GR1}curl -s localhost | grep -E \"Matric|Name\"${NC}"
echo "curl -s localhost | grep -E \"Matric|Name\"" | pbcopy

