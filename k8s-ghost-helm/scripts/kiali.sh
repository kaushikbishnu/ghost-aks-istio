echo "---------INSTALLING KIALI---------"
helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server

export INGRESS_DOMAIN=$(az network public-ip list --query "[?contains(name, 'kubernetes')].[dnsSettings.fqdn]" --output tsv
)
echo ${INGRESS_DOMAIN}

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