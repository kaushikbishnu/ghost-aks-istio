echo "---------INSTALLING GHOST---------"


export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_DOMAIN=${INGRESS_HOST}
echo ${INGRESS_DOMAIN}

helm upgrade --install ghost-nordcloud ../ghost-nordcloud/ --set service.url=http://${INGRESS_HOST}  #-n istio-ingress

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

