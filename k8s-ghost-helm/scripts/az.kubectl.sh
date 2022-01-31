az login --service-principal -u 93031176-d2d8-4035-b9ef-00b5a4febee6 -p U.4p51.gLtiR10Yemwzd5weld9-Z6X5Blk --tenant bad3cd3d-a88a-478d-a251-43f7355aad77
az account set --subscription 1bd78ea7-13c0-4d71-bc70-b6a822ea4a46
az aks get-credentials --resource-group rg-nordcloud-ghost --name ghost-k8s-cluster

