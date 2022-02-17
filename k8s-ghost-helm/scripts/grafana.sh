echo "---------INSTALLING grafana---------"
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/grafana.yaml

# az network public-ip update -g $(az group list --query "[?contains(name, 'k8s-cluster')].[name]" --output tsv) -n $(az network public-ip list --query "[?contains(name, 'kubernetes')].[name]" --output tsv) --dns-name nordcloud
# export INGRESS_DOMAIN=$(az network public-ip list --query "[?contains(name, 'kubernetes')].[dnsSettings.fqdn]" --output tsv
# )
export INGRESS_DOMAIN="eastus.cloudapp.azure.com"
echo ${INGRESS_DOMAIN}

CERT_DIR=/tmp/certs
mkdir -p ${CERT_DIR}
openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -subj "/O=example Inc./CN=*.${INGRESS_DOMAIN}" -keyout ${CERT_DIR}/ca.key -out ${CERT_DIR}/ca.crt
openssl req -out ${CERT_DIR}/cert.csr -newkey rsa:2048 -nodes -keyout ${CERT_DIR}/tls.key -subj "/CN=*.${INGRESS_DOMAIN}/O=example organization"
openssl x509 -req -days 365 -CA ${CERT_DIR}/ca.crt -CAkey ${CERT_DIR}/ca.key -set_serial 0 -in ${CERT_DIR}/cert.csr -out ${CERT_DIR}/tls.crt
kubectl create -n istio-system secret tls telemetry-gw-cert --key=${CERT_DIR}/tls.key --cert=${CERT_DIR}/tls.crt

cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana-gateway
  namespace: istio-system
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 443
      name: https-grafana
      protocol: HTTPS
    tls:
      mode: SIMPLE
      credentialName: telemetry-gw-cert
    hosts:
    - "nordcloud.${INGRESS_DOMAIN}"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana-vs
  namespace: istio-system
spec:
  hosts:
  - "nordcloud.${INGRESS_DOMAIN}"
  gateways:
  - grafana-gateway
  http:
  - route:
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
---
EOF