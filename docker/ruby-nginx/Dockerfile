FROM nginx:latest AS base
ENV TZ=Europe/Berlin
RUN apt-get update \
  && apt-get -y upgrade \
  && apt-get -y install --no-install-recommends \
      netcat vim curl \
  && rm -rf /var/lib/apt/lists/*

FROM base
COPY nginx.nginx /etc/nginx/nginx.conf
COPY fastcgi_params /etc/nginx/
WORKDIR /etc/nginx
CMD ["nginx-debug", "-g", "daemon off;"]
