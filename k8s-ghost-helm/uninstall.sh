helm uninstall istio-base -n istio-system
helm uninstall istiod -n istio-system #--wait
helm uninstall istio-ingress -n istio-ingress
kubectl delete namespace istio-ingress
kubectl delete namespace istio-ingress
kubectl delete namespace istio-system
helm uninstall ghost-nordcloud