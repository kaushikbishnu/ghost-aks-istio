echo "---------INSTALLING grafana---------"
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/grafana.yaml

export INGRESS_DOMAIN=$(az network public-ip list --query "[?contains(name, 'kubernetes')].[dnsSettings.fqdn]" --output tsv
)
echo ${INGRESS_DOMAIN}

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: garfana-server-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 15021
      name: http-grafana
      protocol: HTTP    
    hosts:
    - "${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: garfana-server
  namespace: istio-system
spec:
  hosts:
  - "${INGRESS_DOMAIN}"
  gateways:
  - garfana-server-gateway
  http:
  - match:
    route:
    - destination:
        host: grafana
        port:
          number: 3000
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: grafana
  namespace: istio-system
spec:
  host: grafana
  trafficPolicy:
    tls:
      mode: DISABLE
EOF