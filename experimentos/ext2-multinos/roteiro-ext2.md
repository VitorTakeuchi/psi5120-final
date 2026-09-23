# Extensão 2 — Elasticidade no nível de nós e saturação (Minikube multi-nós)

> Objetivo: cobrir dois aspectos que o trabalho intermediário declarou não ter
> avaliado — (a) a distribuição de Pods entre múltiplos nós em ambiente local e
> (b) o comportamento do HPA quando o cluster fica **sem recursos** (Pods
> `Pending`). Tudo no Minikube, sem custo de nuvem.

## Contexto (ligação com o intermediário)
No TA1, o Minikube tinha um único nó e o EKS dois. O artigo apontou que não
avaliou saturação nem o papel do escalonamento de nós. Aqui reproduzimos os dois
localmente com um cluster de 3 nós pequenos.

## 1. Subir o cluster multi-nós
```bash
chmod +x experimentos/ext2-multinos/*.sh
./experimentos/ext2-multinos/01-setup-multinos.sh
```
- 📸 Screenshot: `kubectl --context ext2 get nodes` (3 nós `Ready`).

## 2. Implantar com dimensionamento que satura
```bash
kubectl --context ext2 apply -f experimentos/ext2-multinos/deployment-saturacao.yaml
kubectl --context ext2 apply -f manifests/service.yaml
kubectl --context ext2 apply -f experimentos/ext2-multinos/hpa-saturacao.yaml
kubectl --context ext2 rollout status deployment/php-apache
```

## 3. Gerar carga e observar DISTRIBUIÇÃO + SATURAÇÃO
Em terminais separados (lembre do `--context ext2`):
```bash
# Terminal 1 — watch dos pods com o nó de cada um
kubectl --context ext2 get pods -l app=php-apache -o wide --watch

# Terminal 2 — watch do HPA
kubectl --context ext2 get hpa php-apache --watch

# Terminal 3 — carga
kubectl --context ext2 run load-generator --image=busybox:1.36 --restart=Never \
  -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

O que observar e capturar:
- **Distribuição:** no `-o wide`, os Pods se espalham pelos 3 nós (coluna NODE).
  📸 Screenshot — evidência de distribuição multi-nó em ambiente local.
- **Saturação:** conforme o HPA pede mais réplicas, em algum momento novos Pods
  ficam em `Pending`. Investigue o motivo:
  ```bash
  kubectl --context ext2 get pods -l app=php-apache -o wide | grep Pending
  kubectl --context ext2 describe pod <pod-pending> | grep -A5 Events
  ```
  Espera-se um evento do tipo `FailedScheduling ... Insufficient cpu`.
  📸 Screenshot — o HPA deseja N réplicas mas o cluster só executa M<N.

## 4. Interpretação para o artigo
- O HPA continua **pedindo** réplicas (desired), mas o número **ready** estaciona:
  evidência concreta de que o HPA não resolve a falta de capacidade — isso é papel
  do escalonamento de nós (Cluster Autoscaler/Karpenter em nuvem).
- Compare `desired` vs `ready`:
  ```bash
  kubectl --context ext2 get hpa php-apache \
    -o custom-columns=DESIRED:.status.desiredReplicas,CURRENT:.status.currentReplicas
  ```

## 5. Limpeza
```bash
minikube delete -p ext2
```

## Dados a registrar
- Nº de réplicas em que a saturação começou (primeiro `Pending`).
- Réplicas `desired` vs `ready` no pico.
- Motivo do `FailedScheduling` (mensagem exata do `describe`).
