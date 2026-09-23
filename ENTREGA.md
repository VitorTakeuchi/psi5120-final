# Guia de entrega — PSI5120 Trabalho Final

Extensão do trabalho intermediário (HPA: Minikube vs. EKS), opção 2.2 do enunciado.
Entrega: **13/09/2026 23h55**. Artigo em **inglês, IEEE, 6–18 páginas**.
Autoria individual: Vitor Augusto Takeuchi (NUSP 11327606).

## Checklist
- [x] Artigo final em inglês (IEEE): `artigo/artigo.tex` (+ `figuras/`)
- [x] Ext. 1 — repetições e estatística: `experimentos/ext1-repeticoes/` + `resultados/`
- [x] Ext. 2 — multi-nós e saturação: `experimentos/ext2-multinos/`
- [x] Ext. 3 — métricas além de CPU: `experimentos/ext3-metricas/`
- [x] Evidências (figuras) em `artigo/figuras/`
- [ ] Compilar o PDF final no Overleaf e revisar o inglês
- [ ] (Opcional) Publicar este repositório no GitHub e citar o link
- [ ] Submeter o PDF no Moodle

## Publicar no GitHub (opcional, recomendado)
Pode ser um repositório novo (ex.: `psi5120-final`) ou uma pasta no repo do TA1.
Repositório novo:
```bash
cd ~/Downloads/psi5120-final
git init
git add .
git commit -m "PSI5120 Trabalho Final - extensoes do HPA (repeticoes, saturacao, memoria)"
git branch -M main
git remote add origin https://github.com/VitorTakeuchi/psi5120-final.git
git push -u origin main
```
(Na autenticação, use o Personal Access Token como senha, como no TA1.)

## Observações
- Todos os experimentos rodam em Minikube (sem custo de AWS).
- O baseline Minikube-vs-EKS entra como Tabela I (resultado já medido no TA1).
- Os `trial-*.csv` brutos são ignorados pelo .gitignore; os agregados
  (`resumo-estatistico.csv`, gráficos) devem ser versionados.
