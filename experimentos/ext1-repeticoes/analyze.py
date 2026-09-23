#!/usr/bin/env python3
# =============================================================================
# analyze.py — Extensão 1: agrega as repetições em estatística descritiva.
# -----------------------------------------------------------------------------
# Lê os trial-XX.csv gerados por run-trials.sh e produz:
#   1) Uma tabela-resumo (media +/- desvio) das métricas por repeticao:
#      tempo ate a 1a escala, replica maxima, CPU de pico.
#   2) Um grafico de replicas x tempo com a MEDIA e a faixa +/- 1 desvio,
#      sobrepondo todas as repeticoes (mostra a variabilidade visualmente).
#
# Requer: pandas, numpy, matplotlib (dentro do venv .venv).
# Uso:  python3 analyze.py resultados/ext1
# =============================================================================
import sys, glob, os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def carregar_trials(pasta):
    """Carrega os trial-XX.csv (fase de carga, sem os -cooldown)."""
    arquivos = sorted(
        f for f in glob.glob(os.path.join(pasta, "trial-*.csv"))
        if "cooldown" not in f
    )
    trials = []
    for f in arquivos:
        df = pd.read_csv(f)
        df["replicas"] = pd.to_numeric(df["replicas"], errors="coerce")
        df["cpu_pct"] = pd.to_numeric(df["cpu_pct"], errors="coerce")
        trials.append(df)
    return arquivos, trials


def metricas_por_trial(trials):
    """Extrai, por repeticao: tempo ate 1a escala, replica max, CPU pico."""
    linhas = []
    for df in trials:
        # tempo ate a primeira vez que replicas > 1
        escala = df[df["replicas"] > 1]
        t_primeira = escala["t_seg"].iloc[0] if not escala.empty else np.nan
        linhas.append({
            "t_primeira_escala_s": t_primeira,
            "replica_maxima": df["replicas"].max(),
            "cpu_pico_pct": df["cpu_pct"].max(),
        })
    return pd.DataFrame(linhas)


def main():
    pasta = sys.argv[1] if len(sys.argv) > 1 else "resultados/ext1"
    arquivos, trials = carregar_trials(pasta)
    if not trials:
        print(f"Nenhum trial-*.csv encontrado em {pasta}")
        sys.exit(1)

    print(f"Repetições carregadas: {len(trials)}")

    # ---- Tabela-resumo (media +/- desvio) ----
    m = metricas_por_trial(trials)
    resumo = m.agg(["mean", "std"]).T
    resumo.columns = ["media", "desvio_padrao"]
    print("\n=== Resumo estatístico (média ± desvio) ===")
    print(resumo.to_string(float_format=lambda x: f"{x:.2f}"))
    resumo.to_csv(os.path.join(pasta, "resumo-estatistico.csv"))
    print(f"\nSalvo: {os.path.join(pasta, 'resumo-estatistico.csv')}")

    # ---- Gráfico: réplicas x tempo, média + faixa de desvio ----
    # Reamostra todas as repetições numa grade de tempo comum (passo 5s).
    t_max = min(df["t_seg"].max() for df in trials)
    grade = np.arange(0, t_max + 1, 5)
    matriz = []
    for df in trials:
        interp = np.interp(grade, df["t_seg"], df["replicas"].ffill().fillna(1))
        matriz.append(interp)
    matriz = np.array(matriz)
    media = matriz.mean(axis=0)
    desvio = matriz.std(axis=0)

    fig, ax = plt.subplots(figsize=(7, 4))
    # cada repetição em cinza claro
    for linha in matriz:
        ax.plot(grade, linha, color="0.8", linewidth=0.8)
    ax.plot(grade, media, color="C0", linewidth=2, label="Média")
    ax.fill_between(grade, media - desvio, media + desvio,
                    alpha=0.25, color="C0", label="± 1 desvio-padrão")
    ax.set_xlabel("Tempo (s)")
    ax.set_ylabel("Número de réplicas")
    ax.set_title(f"HPA — Réplicas x Tempo ({len(trials)} repetições, Minikube)")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    out = os.path.join(pasta, "replicas-media-desvio.png")
    fig.savefig(out, dpi=150)
    print(f"Salvo: {out}")


if __name__ == "__main__":
    main()
