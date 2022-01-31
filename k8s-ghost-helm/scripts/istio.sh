echo "---------INSTALLING ISTIO---------"

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --set pilot.resources.requests.cpu=100m --set pilot.resources.requests.memory=128Mi --wait
kubectl label namespace istio-system istio-injection=enabled  --overwrite 
kubectl label namespace default istio-injection=enabled  --overwrite 
helm install istio-ingressgateway istio/gateway -n istio-system --wait
helm status istiod -n istio-system