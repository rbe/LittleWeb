FROM ubuntu:latest AS base
ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
      netcat vim curl git build-essential libtool zlib1g-dev libyaml-dev libssl-dev \
  && rm -rf /var/lib/apt/lists/*

FROM base AS apps
ARG ASDF_VERSION=v0.11.1
ENV TZ=Europe/Berlin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
      fcgiwrap sqlite3-tools litecli graphviz plantuml \
  && rm -rf /var/lib/apt/lists/* \
  && git clone https://github.com/asdf-vm/asdf.git "${HOME}/.asdf" --branch "${ASDF_VERSION}"

FROM apps AS apps-ruby-gems
COPY --from=apps /root/.asdf /root/.asdf
COPY *.sh /usr/local/bin/
RUN chmod 555 /usr/local/bin/*.sh
CMD ["docker-entrypoint.sh"]
