"""分析コードの見本。自分の研究に合わせて書き換える。

原稿(.qmd)からは `from analysis.sample import ...` で読み込む。
"""

import matplotlib.pyplot as plt
import matplotlib_fontja  # noqa: F401  図の中で日本語を使えるようにする
import pandas as pd


def load_scores(path):
    """得点データ(列: class, score)を読み込む。"""
    return pd.read_csv(path)


def summarize(scores):
    """クラスごとの人数・平均・標準偏差を表にする。"""
    table = scores.groupby("class")["score"].agg(["count", "mean", "std"])
    table.index.name = "クラス"
    table.columns = ["人数", "平均", "標準偏差"]
    return table


def plot_scores(scores):
    """クラスごとの得点の分布を箱ひげ図で描く。"""
    groups = scores.groupby("class")["score"]
    fig, ax = plt.subplots()
    ax.boxplot([g.to_numpy() for _, g in groups])
    ax.set_xticklabels([name for name, _ in groups])
    ax.set_xlabel("クラス")
    ax.set_ylabel("得点")
