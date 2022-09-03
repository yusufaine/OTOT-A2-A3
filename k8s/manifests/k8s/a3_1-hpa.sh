kubectl apply -f metrics-server.yaml
kubectl apply -f hpa-nodejs-deploy-a2-backend.yaml

# while true; clear; do kubectl describe hpa; sleep 1; done

