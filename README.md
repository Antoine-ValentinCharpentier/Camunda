# Camunda
OAuth token URL : http://127.0.0.1:18080/auth/realms/camunda-platform/protocol/openid-connect/token  

> Les modifications effectuées

existingSecretKey: console-secret  
existingSecret: identity-secret-for-components  
global > identity > auth > identity > Hide existing secret  
les replicas de elastic, gateway, zeebe à fixer à 1  

> Les commandes

kind delete cluster -n camunda-platform-local-8.6  
kind create cluster --name camunda-platform-local-8.6  

helm repo add camunda https://helm.camunda.io/  
helm repo update  

kubectl apply -f secrets.yaml  
helm install camunda-platform camunda/camunda-platform   --version 11.1.1  -f ./values2.yml  

kubectl get pods  

> Attendre 16 min

> Ouvertures des ports

kubectl port-forward svc/camunda-platform-zeebe-gateway 26500:26500  
kubectl port-forward svc/camunda-platform-operate  8081:80  
kubectl port-forward svc/camunda-platform-keycloak 18080:80  
kubectl port-forward svc/camunda-platform-identity 8080:80   
