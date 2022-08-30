NC="\033[0m"
GR="\033[1;32m"
GR1="\033[0;32m"
YL="\033[1;33m"

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

kubectl cluster-info --context $ctx 
kubectl get nodes --context $ctx

# pauseMsg "\n${GR1}Press any key to create the deployment.${NC}"

echo "\n${GR}Creating deployment with the following variables:${NC}"
echo "  ${GR}name :${NC} backend" 
echo "  ${GR}label:${NC} backend" 
echo "  ${GR}image:${NC} yusufaine/nodejs-app"
echo "  ${GR}port :${NC} 3000\n"

kubectl apply -f ./nodejs-deploy.yaml --context $ctx

echo "\n${YL}Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=ready pod --selector=app=backend --timeout=45s --context $ctx
echo ""
kubectl get po -l app=backend -o wide --context $ctx


# pauseMsg "\n${GR1}Press any key to create the service.${NC}"

echo "\n${GR}Creating service with the following variables:${NC}"
echo "  ${GR}name :${NC} backend-svc" 
echo "  ${GR}label:${NC} backend" 
echo "  ${GR}port :${NC} 3000\n"

kubectl apply -f ./nginx-svc.yaml --context $ctx

echo "\n${YL}Printing service details...${NC}"
kubectl describe svc backend-svc --context $ctx
echo ""
kubectl get svc -l app=backend -o wide --context $ctx

# pauseMsg "\n${GR1}Press any key to create the NGINX ingress controller.${NC}"

echo "\n${GR}Creating NGINX ingress controller${NC}"
kubectl apply -f "https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml" --context $ctx

echo "\n${YL}Waiting for NGINX ingress controller to be ready...${NC}"
ns="ingress-nginx"
sr="app.kubernetes.io/component=controller"
kubectl wait --namespace $ns --for=condition=ready pod --selector=$sr --timeout 45s --context $ctx
kubectl --namespace $ns get po -l $sr -o wide --context $ctx
kubectl -n $ns get deploy --context $ctx

# pauseMsg "\n${GR1}Press any key to create the image's ingress object.${NC}"

echo "\n${GR}Creating ingress object of yusufaine/nodejs-app${NC}"
kubectl apply -f nodejs-ingress-obj.yaml --context $ctx

echo "\n${YL}Waiting for nodejs-ingress-obj to be ready...${NC}"
sleep 45
kubectl get ingress -l app=backend -o wide --context $ctx

pauseMsg "\n${GR}A2 demo is now ready to be tested...${NC}"

