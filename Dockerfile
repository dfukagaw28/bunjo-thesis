# 卒業論文の PDF を作るための環境(GitHub Actions と同じ TinyTeX・Quarto・uv)
#
#   作る:  docker build -t bunjo-thesis .
#   使う:  docker run --rm -v "$PWD":/work bunjo-thesis
#          (_book/thesis.pdf ができる。詳しくは README の「Docker で PDF を作る」)
#
# Intel / AMD の PC と、Apple Silicon の Mac(arm64)のどちらでも作れる。

FROM ubuntu:24.04

ARG TARGETARCH
ARG TINYTEX_VERSION=2026.10
ARG QUARTO_VERSION=1.10.19

# docker run --user で自分のユーザとして動かしても書き込めるように、
# 書き込みが起きる場所は誰でも書けるようにしておく
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    HOME=/home/thesis

# tlmgr は perl で動く。Python は Ubuntu の 3.12 を使う(uv が入れるものより小さい)
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl perl python3.12 xz-utils \
 && rm -rf /var/lib/apt/lists/*

# TinyTeX と、組版に使う TeX のパッケージ
# (原ノ味フォントの情報も先に作っておく。初回の PDF 作成が速くなる)
# (tlmgr がダウンロードした目録は消す。必要になればまたダウンロードされる)
RUN case "$TARGETARCH" in arm64) arch=arm64 ;; *) arch=x86_64 ;; esac \
 && curl -fsSL "https://github.com/rstudio/tinytex-releases/releases/download/v${TINYTEX_VERSION}/TinyTeX-1-linux-${arch}-v${TINYTEX_VERSION}.tar.xz" \
    | tar xJ -C /opt \
 && mv /opt/.TinyTeX /opt/TinyTeX \
 && ln -s /opt/TinyTeX/bin/*-linux /opt/TinyTeX/bin/current \
 && /opt/TinyTeX/bin/current/tlmgr update --self \
 && /opt/TinyTeX/bin/current/tlmgr install jlreq luatexja haranoaji selnolig caption regexpatch \
 && printf '%s\n' '\documentclass{jlreq}' '\usepackage[haranoaji,deluxe]{luatexja-preset}' \
      '\begin{document}あ\textbf{あ}\textgt{あ}\end{document}' > /tmp/warm.tex \
 && cd /tmp && /opt/TinyTeX/bin/current/lualatex -interaction=nonstopmode warm.tex > /dev/null \
 && rm -f /tmp/warm.* \
 && rm -f /opt/TinyTeX/tlpkg/texlive.tlpdb.main.* \
 && chmod -R a+rwX /opt/TinyTeX
ENV PATH=/opt/TinyTeX/bin/current:$PATH

# Quarto(PDF の作成に使わない Typst・Sass・esbuild などは消す)
RUN case "$TARGETARCH" in arm64) arch=arm64 ;; *) arch=amd64 ;; esac \
 && mkdir -p /opt/quarto \
 && curl -fsSL "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${arch}.tar.gz" \
    | tar xz -C /opt/quarto --strip-components=1 \
 && cd /opt/quarto/bin/tools/*/ \
 && rm -rf typst typst-gather dart-sass esbuild deno_dom
ENV PATH=/opt/quarto/bin:$PATH

# uv と、uv.lock に記録した版の Python パッケージ
# (仮想環境は、手元の .venv とぶつからないよう /opt/venv に置く。JupyterLab などの dev は入れない)
COPY --from=ghcr.io/astral-sh/uv:0.13.0 /uv /uvx /usr/local/bin/
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_PYTHON_PREFERENCE=only-system \
    UV_NO_DEV=1 \
    UV_CACHE_DIR=/tmp/uv-cache \
    UV_LINK_MODE=copy
WORKDIR /work
COPY pyproject.toml uv.lock .python-version ./
# (matplotlib のフォント一覧も先に作っておく)
RUN mkdir -p "$HOME" \
 && uv sync --locked \
 && uv run python -c "import matplotlib_fontja, matplotlib.pyplot" \
 && rm -rf /tmp/uv-cache \
 && chmod -R a+rwX /opt/venv "$HOME"

CMD ["uv", "run", "quarto", "render"]
