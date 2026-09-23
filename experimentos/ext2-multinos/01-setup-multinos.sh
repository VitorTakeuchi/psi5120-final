#!/usr/bin/env bash
# =============================================================================
# 01-setup-multinos.sh — Extensão 2: cluster Minikube com MÚLTIPLOS nós.
# -----------------------------------------------------------------------------
# O trabalho intermediário usou um cluster de nó único e apontou como limitação
# não ter avaliado o comportamento quando o cluster fica sem recursos. Aqui
# subimos um cluster local com 3 nós para (a) observar a DISTRIBUIÇÃO de Pods
# entre nós — como no EKS, mas sem custo — e (b) provocar SATURAÇÃO, levando
# Pods ao estado Pending.
#
# Uso:  ./experimentos/ext2-multinos/01-setup-multinos.sh
# =============================================================================
set -euo pipefail

# Perfil separado para não conflitar com o cluster do trabalho intermediário.
PROFILE="ext2"

# 3 nós, cada um pequeno de propósito: assim a soma de CPU alocável é limitada
# e conseguimos provocar saturação sem precisar de uma carga enorme.
minikube start -p "$PROFILE" --nodes=3 --cpus=2 --memory=2048 --driver=docker

# Metrics Server em cluster multi-nós do Minikube pode precisar ser habilitado
# explicitamente no perfil.
minikube addons enable metrics-server -p "$PROFILE"
kubectl --context "$PROFILE" -n kube-system rollout status deployment/metrics-server --timeout=120s

echo ">> Cluster multi-nós pronto. Nós:"
kubectl --context "$PROFILE" get nodes -o wide
# >> SCREENSHOT: 'kubectl get nodes' com os 3 nós Ready (evidência do cluster local multi-nós).
echo
echo ">> Use o contexto '$PROFILE' nos comandos kubectl seguintes:"
echo "   kubectl --context $PROFILE ..."
