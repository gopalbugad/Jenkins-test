FROM nginx:alpine
WORKDIR /usr/share/nginx/html/
COPY index.html /usr/share/nginx/html/index.html
COPY Dockerfile .
