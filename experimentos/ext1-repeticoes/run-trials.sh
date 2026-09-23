#!/usr/bin/env bash
# =============================================================================
# run-trials.sh — Extensão 1: repetições automatizadas do experimento de HPA.
# -----------------------------------------------------------------------------
# Executa N vezes o ciclo completo (repouso -> carga -> scale up -> parar ->
# scale down) no cluster Minikube atual e grava, para cada repetição, um CSV
# com réplicas e utilização de CPU ao longo do tempo. Ao final, cada trial vira
# um arquivo trial-XX.csv que o analyze.py agrega em média +/- desvio-padrão.
#
# Objetivo: responder à limitação "execução única" declarada no trabalho
# intermediário, medindo a VARIABILIDADE entre execuções.
#
# Pré-requisitos: cluster Minikube ativo com metrics-server, e os manifestos
# aplicados (Deployment/Service/HPA). Rode a partir da RAIZ do repositório.
#
# Uso:   ./experimentos/ext1-repeticoes/run-trials.sh [N] [SEGUNDOS_CARGA]
#        (padrão: N=10 repetições, 180s de carga por repetição)
# =============================================================================
set -euo pipefail

N="${1:-10}"                 # número de repetições
LOAD_SECONDS="${2:-180}"     # duração da carga por repetição (s)
COOLDOWN=360                 # espera entre repetições p/ voltar a 1 réplica (s)
HPA_NAME="php-apache"
OUTDIR="resultados/ext1"
mkdir -p "$OUTDIR"

echo ">> Extensão 1 — $N repetições, ${LOAD_SECONDS}s de carga cada."
echo ">> Resultados em $OUTDIR/trial-XX.csv"

# Função: coleta réplicas e CPU do HPA a cada 5s por uma duração dada.
coletar() {
  local arquivo="$1" duracao="$2" fim
  echo "t_seg,replicas,cpu_pct" > "$arquivo"
  fim=$(( SECONDS + duracao ))
  local t0=$SECONDS
  while [ $SECONDS -lt $fim ]; do
    local rep cpu
    rep=$(kubectl get hpa "$HPA_NAME" -o jsonpath='{.status.currentReplicas}' 2>/dev/null || echo "")
    cpu=$(kubectl get hpa "$HPA_NAME" -o jsonpath='{.status.currentMetrics[0].resource.current.averageUtilization}' 2>/dev/null || echo "")
    echo "$(( SECONDS - t0 )),${rep:-NA},${cpu:-NA}" >> "$arquivo"
    sleep 5
  done
}

for i in $(seq 1 "$N"); do
  TRIAL=$(printf "trial-%02d.csv" "$i")
  echo ">> [$i/$N] Garantindo estado inicial (1 réplica)..."
  kubectl scale deployment "$HPA_NAME" --replicas=1 >/dev/null 2>&1 || true
  sleep 15

  echo ">> [$i/$N] Iniciando carga por ${LOAD_SECONDS}s e coletando..."
  # Sobe o gerador de carga em background.
  kubectl run load-generator-$i \
    --image=busybox:1.36 --restart=Never \
    -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done" \
    >/dev/null 2>&1 || true

  # Coleta durante a carga.
  coletar "$OUTDIR/$TRIAL" "$LOAD_SECONDS"

  echo ">> [$i/$N] Encerrando carga..."
  kubectl delete pod load-generator-$i --force --grace-period=0 >/dev/null 2>&1 || true

  # Continua coletando durante o cooldown (para capturar o scale down).
  echo ">> [$i/$N] Coletando scale down (~${COOLDOWN}s)..."
  coletar "$OUTDIR/${TRIAL%.csv}-cooldown.csv" "$COOLDOWN"

  echo ">> [$i/$N] Repetição concluída."
done

echo ">> Todas as $N repetições concluídas. Agregue com:"
echo "   python3 experimentos/ext1-repeticoes/analyze.py $OUTDIR"
