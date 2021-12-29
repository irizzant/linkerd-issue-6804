#!/bin/bash

k3d cluster create --k3s-arg "--disable=traefik@server:0" --wait

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update

kubectl create ns monitoring

linkerd install | kubectl apply -f-

linkerd viz install | kubectl apply -f-

kubectl annotate ns monitoring linkerd.io/inject=enabled

kubectl -n monitoring apply -f thanos-objstore-config.yaml

helm install prometheus -n monitoring -f values-prometheus.yaml --version 17.1.0 prometheus-community/kube-prometheus-stack

helm install thanos --version 8.2.5 --values=values-thanos.yaml --namespace monitoring bitnami/thanos
