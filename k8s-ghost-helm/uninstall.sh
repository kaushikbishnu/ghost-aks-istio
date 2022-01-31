helm uninstall istio-base -n istio-system
helm uninstall istiod -n istio-system --wait
helm uninstall istio-ingressgateway -n istio-system --wait
kubectl delete namespace istio-system
kubectl label namespace default istio-injection=disabled --overwrite
helm uninstall kiali-server -n istio-system
helm uninstall ghost-nordcloud