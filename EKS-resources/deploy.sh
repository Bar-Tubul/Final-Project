#!/bin/bash

# Define namespaces
MONITORING_NAMESPACE="monitoring"
INGRESS_NAMESPACE="ingress-nginx"

# Apply EKS basic deployments and services
echo "Applying basic deployments and services..."
kubectl apply -f homer.yaml
kubectl apply -f tetris.yaml
kubectl apply -f monkeytype.yaml
kubectl apply -f nginx-service.yaml
kubectl apply -f statuspage-deployment.yaml
kubectl apply -f nginx-deployment.yaml
kubectl apply -f statuspage-service.yaml
# Install Prometheus stack with Helm
echo "Installing Prometheus stack using Helm..."
helm install bop prometheus-community/kube-prometheus-stack -n $MONITORING_NAMESPACE -f values.yaml

# Apply Prometheus-related files
echo "Applying Prometheus and Nginx Prometheus exporter configurations..."
kubectl apply -f nginx-prometheus-deployment.yaml
kubectl apply -f nginx-prometheus-service.yaml
kubectl apply -f prometheus_nginx_alert.yaml

echo "Applying logging"
kubectl apply -f ./04-EFK-Log/

# Install Nginx Ingress Controller with Helm
echo "Installing Nginx Ingress Controller using Helm..."
helm install ingress-nginx ingress-nginx/ingress-nginx -n $INGRESS_NAMESPACE

# Apply Ingress configurations
echo "Applying Ingress configurations..."
kubectl apply -f ingress.yaml
kubectl apply -f ingress-class.yaml

# Apply external files for Ingress
echo "Applying external Ingress configurations..."
kubectl apply -f external-prometheus.yaml
kubectl apply -f external-argocd.yaml
kubectl apply -f external-grafana.yaml
kubectl apply -f external-homer.yaml
kubectl apply -f external-kibana.yaml
kubectl apply -f external-nginx

# Apply ClusterIssuer for certificates
echo "Applying ClusterIssuer for certificates..."
kubectl apply -f cluster-issuer.yaml

echo "All configurations applied successfully!"

