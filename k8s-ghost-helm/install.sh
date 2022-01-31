helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update
kubectl create namespace istio-system
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --set pilot.resources.requests.cpu=100m --set pilot.resources.requests.memory=128Mi --wait
kubectl label namespace istio-system istio-injection=enabled  --overwrite 
kubectl label namespace default istio-injection=enabled  --overwrite 
helm install istio-ingressgateway istio/gateway -n istio-system --wait
helm status istiod -n istio-system
helm upgrade --install ghost-nordcloud ./ghost-nordcloud/ #-n istio-ingress

## install telemetry
helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install --namespace istio-system prometheus prometheus-community/kube-prometheus-stack

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_DOMAIN=${INGRESS_HOST}
echo ${INGRESS_DOMAIN}

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: ghost-nordcloud-gateway
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-ghost
      protocol: HTTP
    hosts:
    - "${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: ghost-nordcloud-vs
spec:
  hosts:
  - "${INGRESS_DOMAIN}"
  gateways:
  - ghost-nordcloud-gateway
  http:
  - match:
    route:
    - destination:
        host: ghost-nordcloud
        port:
          number: 80
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: ghost-nordcloud
spec:
  host: ghost-nordcloud
  trafficPolicy:
    tls:
      mode: DISABLE
---
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: kiali-server-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-kiali
      protocol: HTTP    
    hosts:
    - "${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: kiali-server
  namespace: istio-system
spec:
  hosts:
  - "${INGRESS_DOMAIN}"
  gateways:
  - kiali-server-gateway
  http:
  - match:
    - uri:
        prefix: /kiali
    route:
    - destination:
        host: kiali
        port:
          number: 20001
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: kiali
  namespace: istio-system
spec:
  host: kiali
  trafficPolicy:
    tls:
      mode: DISABLE
EOF

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: prometheus-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http-prom
      protocol: HTTP
    hosts:
    - "${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: prometheus-vs
  namespace: istio-system
spec:
  hosts:
  - "${INGRESS_DOMAIN}"
  gateways:
  - prometheus-gateway
  http:
  - match:
    - uri:
        prefix: /prometheus
    route:
    - destination:
        host: prometheus
        port:
          number: 9090
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: prometheus
  namespace: istio-system
spec:
  host: prometheus
  trafficPolicy:
    tls:
      mode: DISABLE
---
EOF