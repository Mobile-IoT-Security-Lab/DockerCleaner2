FROM alpine:latest AS builder

RUN apk update && \
    apk add --no-cache build-base curl wget libffi-dev gmp-dev ncurses-dev pkgconfig python3 py3-pip && \
    apk cache clean

WORKDIR /DockerCleaner
COPY . .

RUN python3 -m venv ./venv
RUN ./venv/bin/pip install requests

RUN wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
RUN chmod +x /bin/hadolint

# RUN curl -sSL https://get.haskellstack.org/ | sh
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org  | sh
ENV PATH="/root/.ghcup/bin:/root/.local/bin:${PATH}"

RUN cd DockerCleaner && stack install

FROM alpine:latest AS build

RUN apk update && \
    apk add --no-cache libffi gmp ncurses-libs python3 && \
    apk cache clean

COPY --from=builder /root/.local/bin/dockercleaner /usr/local/bin/

COPY /demo-dockerfiles .
COPY --from=builder /DockerCleaner/venv /app/.venv

# Ensure the virtual environment's Python is used
ENV PATH="/.venv/bin:${PATH}"

ENTRYPOINT [ "dockercleaner" ]
