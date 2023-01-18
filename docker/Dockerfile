FROM nginx:latest AS base
ENV TZ=Europe/Berlin
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
      netcat vim fcgiwrap \
  && rm -rf /var/lib/apt/lists/*

FROM base AS apps
ENV TZ=Europe/Berlin
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
      graphviz plantuml \
  && rm -rf /var/lib/apt/lists/*

FROM apps AS apps-ruby-gems
RUN  apt-get update \
  && apt-get -y install --no-install-recommends \
      ruby ruby-cgi ruby-fcgi ruby-mail \
      ruby-asciidoctor ruby-asciidoctor-kroki ruby-asciidoctor-plantuml ruby-asciidoctor-pdf \
  && rm -rf /var/lib/apt/lists/* \
  && gem install asciidoctor-diagram \
  && gem install barby \
  && gem install rqrcode

FROM apps-ruby-gems
COPY 90-fcgiwrap.sh /docker-entrypoint.d/
COPY nginx.nginx /etc/nginx/nginx.conf
COPY fastcgi_params /etc/nginx/
RUN chmod 555 /docker-entrypoint.d/*.sh
WORKDIR /etc/nginx
CMD ["nginx-debug", "-g", "daemon off;"]
