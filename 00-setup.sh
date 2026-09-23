#!/usr/bin/env bash
# =============================================================================
# 00-setup.sh — Prepara o ambiente do trabalho final (Ubuntu).
# -----------------------------------------------------------------------------
# Faz, em um comando só:
#   1. Sobe um cluster Minikube de nó único com metrics-server (Ext. 1 e Ext. 3).
#   2. Cria/ativa o virtualenv Python com pandas/numpy/matplotlib (gráficos).
#   3. Aplica os manifestos base (Deployment/Service/HPA) para a Ext. 1.
#
# NÃO cobre a Ext. 2 (multi-nós), que tem o próprio setup em
# experimentos/ext2-multinos/01-setup-multinos.sh (perfil separado).
#
# Uso:  ./00-setup.sh
#       (rode a partir da RAIZ do repositório do trabalho final)
# =============================================================================
set -euo pipefail

echo ">> [1/3] Subindo cluster Minikube (nó único)..."
if minikube status >/dev/null 2>&1; then
  echo "   Minikube já está rodando — reutilizando."
else
  minikube start --cpus=2 --memory=4096 --driver=docker
fi
minikube addons enable metrics-server
kubectl -n kube-system rollout status deployment/metrics-server --timeout=120s

echo ">> [2/3] Preparando ambiente Python (.venv)..."
if [ ! -d .venv ]; then
  python3 -m venv .venv
fi
# shellcheck disable=SC1091
source .venv/bin/activate
pip install --quiet --upgrade pip
pip install --quiet pandas numpy matplotlib
echo "   .venv pronto (pandas/numpy/matplotlib instalados)."

echo ">> [3/3] Aplicando manifestos base (Deployment/Service/HPA)..."
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/hpa.yaml
kubectl rollout status deployment/php-apache --timeout=120s

echo
echo "=============================================================="
echo " Ambiente pronto. Próximos passos:"
echo "  - Deixe o venv ativo:   source .venv/bin/activate"
echo "  - Aguarde ~1 min e confira:  kubectl get hpa php-apache"
echo "    (TARGETS deve sair de <unknown> para cpu: 0%/50%)"
echo
echo "  Extensão 1 (repetições, ~1h30):"
echo "    ./experimentos/ext1-repeticoes/run-trials.sh 10 180"
echo "    python3 experimentos/ext1-repeticoes/analyze.py resultados/ext1"
echo
echo "  Extensão 3 (métricas além de CPU): ver experimentos/ext3-metricas/roteiro-ext3.md"
echo "  Extensão 2 (multi-nós): ./experimentos/ext2-multinos/01-setup-multinos.sh"
echo "=============================================================="
