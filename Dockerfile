# Use a lightweight web server
FROM nginx:alpine

# Copy HTML file into the web server directory
COPY index.html /usr/share/nginx/html/index.html
