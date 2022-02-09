echo "---------INSTALLING prometheus---------"
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/prometheus.yaml

export INGRESS_DOMAIN=$(az network public-ip list --query "[?contains(name, 'kubernetes')].[dnsSettings.fqdn]" --output tsv
)
echo ${INGRESS_DOMAIN}

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