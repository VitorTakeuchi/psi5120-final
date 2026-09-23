# Artigo final (inglês, IEEE) — como compilar

- `artigo.tex`: template IEEEtran, inglês, já com autoria e as 6 figuras.
- `figuras/`: evidências das 3 extensões (Ext.1 gráfico; Ext.2 nós/distribuição/HPA;
  Ext.3 HPA por memória/top pods).

## Overleaf
1. New Project > Upload Project > suba a pasta `artigo/` inteira (com figuras/).
2. Compile (2x). O IEEEtran e o babel english já vêm no Overleaf.

## Ainda por fazer (você)
- Revisar o inglês nas partes novas (passei o texto no seu estilo cauteloso, mas
  confira termos técnicos).
- Se o professor pedir autores adicionais do grupo, ajuste \author (você fará individual).
- O baseline (Minikube vs EKS) entra como Tabela I resumida; se quiser, pode
  reincluir figuras do intermediário na Seção "Baseline".
- Confirmar o link do GitHub (já está na Introdução).

## Números reais embutidos
- Ext.1: 72.9±17.1 s; 4.6±0.84 réplicas; 196.4±48.6% CPU (10 trials).
- Ext.2: 3 nós; distribuição; saturação READY 15/40.
- Ext.3: HPA por memória 1→4; travado 80%/60%; 120Mi/pod, CPU ~0m.
