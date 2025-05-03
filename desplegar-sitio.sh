#!/bin/bash

# Desplegar sitio web estático en Minikube
# Sonia Guevara

# Rutas del proyecto y del directorio de montaje
PROJECT_PATH="/c/Users/MegaTecnologia/Documents/0311AT/proyecto-k8s/manifiestos"
MOUNT_PATH="/c/Users/MegaTecnologia/Documents/0311AT/PaginaWeb"
MINIKUBE_MOUNT_PATH="/data/web"
NAMESPACE="web-estatica"

echo "🚀 Iniciando Minikube si no está corriendo..."
if ! minikube status &>/dev/null; then
  minikube start
else
  echo "✅ Minikube ya está corriendo."
fi

# Montar el directorio del proyecto en Minikube en segundo plano
echo "📁 Montando el directorio en Minikube..."
minikube mount "$MOUNT_PATH:$MINIKUBE_MOUNT_PATH" &

# Esperar un momento para asegurarse de que el montaje esté realizado
sleep 20

echo "📦 Aplicando manifiestos de Kubernetes..."

kubectl apply -f "$PROJECT_PATH/namespace.yaml"
kubectl apply -f "$PROJECT_PATH/pv.yaml" -n "$NAMESPACE"
kubectl apply -f "$PROJECT_PATH/pvc.yaml" -n "$NAMESPACE"
kubectl apply -f "$PROJECT_PATH/deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "$PROJECT_PATH/service.yaml" -n "$NAMESPACE"

echo "⏳ Esperando a que los pods estén listos..."
for i in {1..10}; do
  sleep 20
  READY=$(kubectl get pods -n "$NAMESPACE" --no-headers | grep -c 'Running')
  if [ "$READY" -gt 0 ]; then
    echo "✅ Pods listos!"
    break
  fi
done

if [ "$READY" -eq 0 ]; then
  echo "❌ Los pods no se están ejecutando. Verifica el estado de los pods."
  exit 1
fi

echo "🌐 Obteniendo IP y puerto del servicio..."
MINIKUBE_IP=$(minikube ip)
NODE_PORT=$(kubectl get svc static-website-service -n "$NAMESPACE" -o jsonpath="{.spec.ports[0].nodePort}")

URL="http://$MINIKUBE_IP:$NODE_PORT"
echo "✅ Sitio desplegado correctamente: $URL"

# Abrir en navegador (solo en Windows + Git Bash)
if command -v explorer.exe &>/dev/null; then
  explorer.exe "$URL"
else
  echo "⚠ No se puede abrir el navegador automáticamente."
fi
