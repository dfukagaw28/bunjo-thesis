# 卒業論文テンプレート(Markdown + Quarto + LuaLaTeX)

Markdown で書いた原稿と分析コードから、卒業論文の PDF を作るための雛形です。
本文・図表・脚注・参考文献・分析コードを、1 つのリポジトリで管理します。

## 始め方

1. このページの **Use this template** から、自分用のリポジトリを作る(Private を推奨)。
2. 手元に clone し、必要なソフトを入れる。
   - [Quarto](https://quarto.org/docs/get-started/)(1.4 以降)
   - TeX Live(LuaLaTeX と jlreq、LuaTeX-ja、原ノ味フォントを含むもの。フルインストールなら入っている)
   - [uv](https://docs.astral.sh/uv/getting-started/installation/)(Python の版とパッケージを管理する)
   - リポジトリのフォルダで `uv sync` を実行する。Python 本体と、分析に使うパッケージが入る。
3. `_quarto.yml` の上のほうにある題目・氏名・学籍番号・担当教員・要旨を書き換える。
4. PDF を作る。

```sh
uv run quarto render      # _book/thesis.pdf ができる
uv run quarto preview     # 保存するたびに作り直してプレビューする
```

GitHub に push すると、GitHub Actions が同じ PDF を作ります(Actions タブ → 実行結果 → Artifacts)。
手元に環境がなくても、PDF はここから取得できます。

## どこに何を書くか

| 場所 | 内容 |
|:--|:--|
| `_quarto.yml` | 題目、氏名、担当教員、要旨、章の並び順 |
| `index.qmd` | 第 1 章(ファイル名は変えない) |
| `chapters/*.qmd` | 第 2 章以降と付録 |
| `acknowledgements.qmd` | 謝辞 |
| `references.bib` | 文献データ |
| `analysis/` | 実験・分析のコード |
| `data/` | データ |
| `pyproject.toml`、`uv.lock` | 分析に使うパッケージとその版(`uv add` で更新する) |
| `figures/` | 写真など、コードで作らない図(必要になったら作る) |
| `_template/` | 表紙・版面・文献スタイル。ふだんは触らない |

文献データは、CiNii Research や Google Scholar、Zotero から BibTeX 形式で書き出して `references.bib` に貼り付けます。

章を増やすときは、`chapters/` にファイルを作り、`_quarto.yml` の `chapters` に 1 行足します。

## 書き方の早見表

サンプルの各章が、そのまま書き方の見本になっています。

| やりたいこと | 書き方 |
|:--|:--|
| 見出し | `# 章` `## 節` `### 項` |
| 脚注 | `本文[^1]` と `[^1]: 注の内容`、または `^[注の内容]` |
| 文献の引用 | `[@okumura2023]`、複数は `[@a; @b]` |
| 図(コード) | チャンクの先頭に `#| label: fig-名前` と `#| fig-cap: "説明"` |
| 図(画像) | `![説明](figures/a.pdf){#fig-名前 width=80%}` |
| 表(コード) | チャンクの先頭に `#| label: tbl-名前` と `#| tbl-cap: "説明"` |
| 表(手書き) | 表の直後に `: 説明 {#tbl-名前}` |
| 数式 | `$$ ... $$ {#eq-名前}` |
| 図表・数式の参照 | `@fig-名前` `@tbl-名前` `@eq-名前` |
| 章・節の参照 | 見出しに `{#sec-名前}` を付け、`第[-@sec-名前]章` |

## 分析コードについて

- 原稿の中のコードは、PDF を作るたびに実行されます。図表と本文の数値がずれません。
- 長い処理は `analysis/` に関数として書き、原稿からは呼び出すだけにします。
- パッケージを足すときは `uv add パッケージ名`(例: `uv add scikit-learn`)を実行し、
  変わった `pyproject.toml` と `uv.lock` もコミットします。
  `uv.lock` に版が記録されるので、手元でも GitHub Actions でも同じ版で計算されます。
- R を使う場合は、チャンクを ```` ```{r} ```` にします。コードを使わない場合は、チャンクを消せば Python は不要です。
- 計算に時間がかかるようになったら、`_quarto.yml` の `execute` に `freeze: auto` を足します。
  変更のない章は再計算されなくなります(`_freeze/` もコミットしてください)。
- 大きなデータや公開できないデータは、`.gitignore` に書いてリポジトリに入れないようにします。

## 体裁

- A4、11pt、1 行 41 字 × 37 行。中表紙、要旨、目次、本文、謝辞、参考文献、付録の順。
- ページ番号は、要旨と目次がローマ数字、本文からアラビア数字。
- 参考文献は、本文に `[1]` の番号を入れ、引用した順に並べる。書式は情報処理学会の記載方法に準じる(`_template/references.csl`)。
  - 和文: `[1] 著者：題名，誌名，Vol.19，No.3，pp.365–372（2004）．`
  - 英文: `[2] Author, A. and Author, B.: Title, Journal, Vol.21, No.2, pp.120–126 (1978).`
  - 和文か英文かは、題目と著者名に日本語があるかどうかで自動で切り替わる(`_template/ja-refs.lua`)。
  - 別の形式にするときは、[Zotero Style Repository](https://www.zotero.org/styles) の CSL ファイルに差し替える。
- 本文中のコード(`` `analysis/sample.py` `` など)は、`/` `_` `-` `.` の直後で改行できる(`_template/code-breaks.lua`)。
  長いパスが行末に来ても、その行の字間が広がらない。区切りのない長い文字列は改行できない。
- 原稿の改行は、PDF では空白にならない(`_quarto.yml` の `wrap: preserve`)。和文の途中で改行してかまわない。
- 書体は原ノ味明朝で、見出しも明朝の太字(`_template/fonts.tex`)。
- 版面は `_template/doc-class.tex`、表紙と要旨は `_template/before-body.tex` で変えられます。

## Overleaf に移すとき

最後の手直しを Overleaf で行いたい場合は、PDF を作るときに使った LaTeX のソースを残して持っていきます。

```sh
uv run quarto render -M keep-tex:true
```

1. リポジトリ直下にできた `thesis.tex` と、コードで作った図 `chapters/*_files/figure-pdf/` を、フォルダ構成を変えずに Overleaf のプロジェクトへアップロードする。
   `figures/` に置いた画像も同じようにアップロードする。
2. Overleaf の Menu → Compiler を **LuaLaTeX** にする。

移したあとは、次のことができなくなります。分析と文献が固まってから移してください。

- 分析コードは実行されない。図表と本文中の数値は、移した時点の値のまま固定される。
- 文献番号と参考文献の一覧は、清書済みの文字として入る。引用を足すと、番号と一覧を手で直すことになる。
- 以後は LaTeX で直接書くことになり、Quarto の原稿には戻せない。
