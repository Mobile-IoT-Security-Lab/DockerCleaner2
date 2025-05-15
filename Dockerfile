FROM alpine:latest AS builder

RUN apk update && \
    apk add --no-cache build-base curl wget libffi-dev gmp-dev ncurses-dev pkgconfig && \
    apk cache clean

WORKDIR /DockerCleaner
COPY . .

# RUN python3 -m venv /venv  # Changed to /venv
# RUN /venv/bin/pip install requests

RUN wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-x86_64
RUN chmod +x /bin/hadolint

RUN curl --tlsv1.2 -sSf https://get-ghcup.haskell.org  | sh
ENV PATH="/root/.ghcup/bin:/root/.local/bin:${PATH}"

RUN cd DockerCleaner && stack install

FROM alpine:latest AS build

RUN apk update && \
    apk add --no-cache libffi gmp ncurses-libs python3 py3-pip && \
    apk cache clean

COPY --from=builder /root/.local/bin/dockercleaner /usr/local/bin/
COPY /demo .

# Create a new virtual environment in the build stage, now at /venv
RUN python3 -m venv /venv
RUN /venv/bin/pip install --no-cache-dir requests

# Copy only the installed 'requests' package from the builder's venv
# COPY --from=builder /venv/lib/python3.*/site-packages/requests /venv/lib/python3.*/site-packages/

COPY --from=builder /root/.local/bin/dockercleaner /usr/local/bin/
COPY DockerCleaner/package-versions/ /package-versions

ENV PATH="/venv/bin:${PATH}:/usr/local/bin"

ENTRYPOINT [ "dockercleaner" ]
