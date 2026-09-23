# Extensão 3 — Autoescalamento por métricas além da CPU

> Objetivo: cobrir a limitação declarada no trabalho intermediário de que a CPU
> pode não refletir integralmente a demanda. Demonstramos o HPA por **memória**
> (nativo, sem instalar nada) e documentamos a rota **KEDA** (event-driven) como
> caminho para métricas de aplicação (ex.: requisições por segundo).

## Rota A — HPA por memória (recomendada, sem dependências)

### 1. Implantar a aplicação que consome memória + o HPA por memória
```bash
kubectl apply -f experimentos/ext3-metricas/deployment-mem.yaml
kubectl apply -f experimentos/ext3-metricas/hpa-memoria.yaml
kubectl rollout status deployment/mem-app
```

### 2. Observar o escalamento por memória
```bash
kubectl get hpa mem-app --watch
```
- Como cada réplica já sobe consumindo ~120Mi (acima de 60% dos 150Mi de
  `requests`), o HPA deve criar réplicas para diluir a média de memória.
- 📸 Screenshot: `TARGETS` mostrando `memory: XX%/60%` e réplicas subindo.
- Compare com o `top pods` para casar o número com o consumo real:
  ```bash
  kubectl top pods -l app=mem-app
  ```

### 3. Interpretação para o artigo
- O mesmo mecanismo (HPA, autoscaling/v2) escala por uma métrica diferente sem
  qualquer mudança de arquitetura — só troca o campo `resource.name`.
- Discuta a diferença de dinâmica: memória tende a subir e **não cair** tão
  rápido quanto CPU (aplicações raramente liberam memória), o que afeta o
  `scale down`. Esse contraste com o experimento de CPU do intermediário é um
  ótimo ponto de análise.

### 4. Limpeza
```bash
kubectl delete -f experimentos/ext3-metricas/hpa-memoria.yaml
kubectl delete -f experimentos/ext3-metricas/deployment-mem.yaml
```

## Rota B — KEDA / métricas de aplicação (opcional, mais ambiciosa)

Se quiser ir além das métricas de recurso e escalar por uma métrica de
aplicação (ex.: requisições HTTP por segundo, tamanho de fila), o caminho é o
KEDA (Kubernetes Event-Driven Autoscaling), que estende o HPA.

Passos gerais (documentar no artigo mesmo que não execute):
1. Instalar o KEDA no cluster (`helm install keda kedacore/keda` ou manifesto).
2. Definir um `ScaledObject` apontando para um *scaler* (ex.: Prometheus,
   contador de requisições, fila SQS/Kafka).
3. O KEDA cria e gerencia um HPA por baixo, mas dirigido pela métrica de evento.

Isso demonstra a limitação da métrica única de forma ainda mais forte: a decisão
de escalar passa a refletir a **demanda da aplicação**, não o consumo de
recurso. Fica como trabalho complementar caso o tempo permita.

## Dados a registrar
- Utilização de memória de pico e nº de réplicas atingido (Rota A).
- Comportamento do scale down por memória vs. o scale down por CPU do TA1.
