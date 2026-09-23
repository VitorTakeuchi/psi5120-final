#!/usr/bin/env bash
# =============================================================================
# monitor.sh — Coletor de métricas do HPA (usado nos DOIS ambientes).
# -----------------------------------------------------------------------------
# Registra, a cada 5 s, o número de réplicas e a utilização média de CPU do
# HPA em um arquivo CSV. Rode em um terminal SEPARADO durante o teste de carga.
# O CSV vira insumo direto para os GRÁFICOS do artigo (réplicas x tempo,
# CPU x tempo) e para a evidência de "métricas coletadas".
#
# Uso:  ./scripts/monitor.sh evidencias/minikube/metrics.csv
#       ./scripts/monitor.sh evidencias/eks/metrics.csv
# =============================================================================
set -euo pipefail

OUT="${1:-metrics.csv}"                 # arquivo de saída (1º argumento)
HPA_NAME="php-apache"

echo "timestamp,replicas,cpu_utilizacao_pct" > "$OUT"
echo ">> Coletando métricas em '$OUT' a cada 5s (Ctrl+C para parar)..."

while true; do
  TS=$(date +%H:%M:%S)

  # Réplicas atuais (jsonpath é mais confiável que "recortar" a saída de texto).
  REPLICAS=$(kubectl get hpa "$HPA_NAME" \
    -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo "")

  # Utilização média de CPU medida pelo HPA (pode ser vazio nos primeiros segundos).
  CPU=$(kubectl get hpa "$HPA_NAME" \
    -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' \
    2>/dev/null || echo "")

  echo "$TS,${REPLICAS:-NA},${CPU:-NA}" | tee -a "$OUT"
  sleep 5
done
