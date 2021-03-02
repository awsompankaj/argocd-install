#!/bin/bash

if [ "$#" -eq  "0" ] || [ "$#" -ne  "3" ]
   then
     echo "No arguments supplied or incorrect arguments"
     echo "usage: $0 adminpassword developerpassword ingresshostname"
     exit 1
 fi

git clone https://github.com/awsompankaj/argocd-install.git
cd argocd-install

which helm
if [ $(echo $?) != 0 ]
then
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
fi
kubectl create ns argocd
#rm -rf argo-cd*.tgz
#helm repo add argo https://argoproj.github.io/argo-helm
#helm pull argo/argo-cd
#tar -xvzf argo-cd-2.14.7.tgz 
#cd argo-cd
#sed -i '551i\    accounts.developer: apiKey, login' values.yaml 
helm install argocd . -n argocd  --set server.extraArgs={--insecure} --set server.ingress.enabled=true --set server.ingress.hosts={$3} 
PASS=$(kubectl get pods -n argocd  -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
sleep 30
argocd login $3 --username admin  --password $PASS --grpc-web  --insecure
argocd account update-password --account developer --current-password $PASS --new-password $2
argocd account update-password  --account admin --current-password $PASS --new-password $1
argocd logout $3
argocd login $3 --username developer  --password $2 --grpc-web  --insecure
argocd cluster add --in-cluster kubernetes-admin@kubernetes
