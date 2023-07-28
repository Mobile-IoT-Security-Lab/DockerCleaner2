FROM alpine:3.7
RUN apk add wget=1.20.3-r0 coreutils=8.28-r0 perl=5.26.3-r0 autoconf=2.69-r0 dpkg-dev=1.18.24-r0 dpkg=1.18.24-r0 file=5.32-r2 g++=6.4.0-r5 gcc=6.4.0-r5 libc-dev=0.7.1-r0 make=4.2.1-r0 pkgconf=1.3.10-r0 re2c=1.0.2-r0 linux-headers=4.4.6-r2 --no-cache --virtual .build-deps \
 && mkdir -p /usr/local/src
#   Build openssl
ARG OPENSSL_VERSION=1.1.0g
ARG OPENSSL_SHA256="de4d501267da39310905cb6dc8c6121f7a2cad45a7707f76df828fe1b85073af"
RUN cd /usr/local/src \
 && wget "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" -O "openssl-${OPENSSL_VERSION}.tar.gz" \
 && echo "$OPENSSL_SHA256" "openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c - \
 && tar -zxvf "openssl-${OPENSSL_VERSION}.tar.gz" \
 && cd "openssl-${OPENSSL_VERSION}" \
 && ./config no-async shared --prefix=/usr/local/ssl --openssldir=/usr/local/ssl -Wl,-rpath,/usr/local/ssl/lib \
 && make \
 && make install \
 && cp /usr/local/ssl/bin/openssl /usr/bin/openssl \
 && rm -rf "/usr/local/src/openssl-${OPENSSL_VERSION}.tar.gz" "/usr/local/src/openssl-${OPENSSL_VERSION}"
#   Build GOST-engine for OpenSSL
ARG GOST_ENGINE_VERSION=3bd506dcbb835c644bd15a58f0073ae41f76cb06
ARG GOST_ENGINE_SHA256="4777b1dcb32f8d06abd5e04a9a2b5fe9877c018db0fc02f5f178f8a66b562025"
RUN apk add cmake=3.9.5-r0 unzip=6.0-r3 --no-cache --virtual .build-deps \
 && cd /usr/local/src \
 && wget "https://github.com/gost-engine/engine/archive/${GOST_ENGINE_VERSION}.zip" -O gost-engine.zip \
 && echo "$GOST_ENGINE_SHA256" gost-engine.zip | sha256sum -c - \
 && unzip gost-engine.zip -d ./ \
 && cd "engine-${GOST_ENGINE_VERSION}" \
 && sed -i 's|printf("GOST engine already loaded\\n");|goto end;|' gost_eng.c \
 && mkdir build \
 && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS='-I/usr/local/ssl/include -L/usr/local/ssl/lib' -DOPENSSL_ROOT_DIR=/usr/local/ssl -DOPENSSL_INCLUDE_DIR=/usr/local/ssl/include -DOPENSSL_LIBRARIES=/usr/local/ssl/lib .. \
 && cmake --build . --config Release \
 && cd ../bin \
 && cp gostsum gost12sum /usr/local/bin \
 && cd .. \
 && cp bin/gost.so /usr/local/ssl/lib/engines-1.1 \
 && rm -rf "/usr/local/src/gost-engine.zip" "/usr/local/src/engine-${GOST_ENGINE_VERSION}"
#   Enable engine
RUN sed -i '6i openssl_conf=openssl_def' /usr/local/ssl/openssl.cnf \
 && echo "" >> /usr/local/ssl/openssl.cnf \
 && echo "# OpenSSL default section" >> /usr/local/ssl/openssl.cnf \
 && echo "[openssl_def]" >> /usr/local/ssl/openssl.cnf \
 && echo "engines = engine_section" >> /usr/local/ssl/openssl.cnf \
 && echo "" >> /usr/local/ssl/openssl.cnf \
 && echo "# Engine scetion" >> /usr/local/ssl/openssl.cnf \
 && echo "[engine_section]" >> /usr/local/ssl/openssl.cnf \
 && echo "gost = gost_section" >> /usr/local/ssl/openssl.cnf \
 && echo "" >> /usr/local/ssl/openssl.cnf \
 && echo "# Engine gost section" >> /usr/local/ssl/openssl.cnf \
 && echo "[gost_section]" >> /usr/local/ssl/openssl.cnf \
 && echo "engine_id = gost" >> /usr/local/ssl/openssl.cnf \
 && echo "dynamic_path = /usr/local/ssl/lib/engines-1.1/gost.so" >> /usr/local/ssl/openssl.cnf \
 && echo "default_algorithms = ALL" >> /usr/local/ssl/openssl.cnf \
 && echo "CRYPT_PARAMS = id-Gost28147-89-CryptoPro-A-ParamSet" >> /usr/local/ssl/openssl.cnf
#   Rebuild curl
ARG CURL_VERSION=7.59.0
ARG CURL_SHA256="099d9c32dc7b8958ca592597c9fabccdf4c08cfb7c114ff1afbbc4c6f13c9e9e"
RUN cd /usr/local/src \
 && wget "https://curl.haxx.se/download/curl-${CURL_VERSION}.tar.gz" -O "curl-${CURL_VERSION}.tar.gz" \
 && echo "$CURL_SHA256" "curl-${CURL_VERSION}.tar.gz" | sha256sum -c - \
 && tar -zxvf "curl-${CURL_VERSION}.tar.gz" \
 && cd "curl-${CURL_VERSION}" \
 && CPPFLAGS="-I/usr/local/ssl/include" LDFLAGS="-L/usr/local/ssl/lib -Wl,-rpath,/usr/local/ssl/lib" LD_LIBRARY_PATH=/usr/local/ssl/lib ./configure --prefix=/usr/local/curl --with-ssl=/usr/local/ssl --with-libssl-prefix=/usr/local/ssl \
 && make \
 && make install \
 && ln -s /usr/local/curl/bin/curl /usr/bin/curl \
 && rm -rf "/usr/local/src/curl-${CURL_VERSION}.tar.gz" "/usr/local/src/curl-${CURL_VERSION}"
#   Rebuild stunnel
ARG STUNNEL_VERSION=5.50
ARG STUNNEL_SHA256="951d92502908b852a297bd9308568f7c36598670b84286d3e05d4a3a550c0149"
RUN cd /usr/local/src \
 && wget "https://www.stunnel.org/downloads/stunnel-${STUNNEL_VERSION}.tar.gz" -O "stunnel-${STUNNEL_VERSION}.tar.gz" \
 && echo "$STUNNEL_SHA256" "stunnel-${STUNNEL_VERSION}.tar.gz" | sha256sum -c - \
 && tar -zxvf "stunnel-${STUNNEL_VERSION}.tar.gz" \
 && cd "stunnel-${STUNNEL_VERSION}" \
 && CPPFLAGS="-I/usr/local/ssl/include" LDFLAGS="-L/usr/local/ssl/lib -Wl,-rpath,/usr/local/ssl/lib" LD_LIBRARY_PATH=/usr/local/ssl/lib ./configure --prefix=/usr/local/stunnel --with-ssl=/usr/local/ssl \
 && make \
 && make install \
 && ln -s /usr/local/stunnel/bin/stunnel /usr/bin/stunnel \
 && rm -rf "/usr/local/src/stunnel-${STUNNEL_VERSION}.tar.gz" "/usr/local/src/stunnel-${STUNNEL_VERSION}"
#  Clean
RUN apk del .build-deps
RUN addgroup -S docker-user ; adduser -S -G docker-user docker-user
USER docker-user
# Please add your HEALTHCHECK here!!!
