# PSI5120 — Trabalho Final: Extensão do estudo de HPA no Kubernetes

Extensão do trabalho intermediário (HPA em Minikube vs. AWS EKS). Cada extensão
ataca **uma limitação declarada** no artigo intermediário, e todas rodam em
**Minikube (sem custo de nuvem)**.

## Entregáveis (ver ENTREGA.md)

| Item | Onde | Status |
|---|---|:---:|
| Artigo final (inglês, IEEE) | `artigo/artigo.pdf` (compilar do `.tex`) | ✅ |
| Ext. 1 — repetições/estatística | `experimentos/ext1-repeticoes/`, `resultados/ext1/` | ✅ |
| Ext. 2 — multi-nós/saturação | `experimentos/ext2-multinos/` | ✅ |
| Ext. 3 — métricas além de CPU | `experimentos/ext3-metricas/` | ✅ |
| Evidências (figuras) | `artigo/figuras/` | ✅ |
| Submissão no Moodle (PDF) | — | ⬜ |

## Ligação com as limitações do trabalho intermediário

| Limitação declarada no TA1 | Extensão que a cobre |
|---|---|
| "Execução única, sem repetições nem estatística" | **Ext. 1** — repetições + média ± desvio |
| "Não avaliou saturação nem escalonamento de nós" | **Ext. 2** — Minikube multi-nós + Pods `Pending` |
| "Usou só CPU; a métrica pode não refletir a demanda" | **Ext. 3** — HPA por memória (+ rota KEDA) |

## Estrutura

```
psi5120-final/
├── manifests/                      # manifestos base reaproveitados do TA1
├── scripts/                        # monitor.sh (coleta) reaproveitado
├── experimentos/
│   ├── ext1-repeticoes/            # run-trials.sh + analyze.py
│   ├── ext2-multinos/              # setup multi-nós + manifestos de saturação + roteiro
│   └── ext3-metricas/              # HPA por memória + roteiro (rota KEDA opcional)
├── resultados/                     # CSVs e gráficos gerados por você
└── artigo/                         # artigo final em inglês (a montar)
```

## Como executar (resumo)

Pré-requisito: `.venv` com pandas/numpy/matplotlib (o mesmo do TA1).

**Ext. 1 — repetições e estatística** (usa o cluster de nó único do TA1):
```bash
./minikube/01-setup.sh          # (do repo do TA1) ou um minikube start simples
kubectl apply -f manifests/
./experimentos/ext1-repeticoes/run-trials.sh 10 180
python3 experimentos/ext1-repeticoes/analyze.py resultados/ext1
```

**Ext. 2 — multi-nós e saturação:**
```bash
./experimentos/ext2-multinos/01-setup-multinos.sh
# seguir experimentos/ext2-multinos/roteiro-ext2.md
```

**Ext. 3 — métricas além de CPU:**
```bash
# seguir experimentos/ext3-metricas/roteiro-ext3.md (rota A: memória)
```

## Observação de escopo
Todas as extensões são locais e gratuitas. O ambiente EKS do TA1 entra no artigo
final como **baseline já medido** (reaproveitado), sem necessidade de subir o
cluster pago novamente.
