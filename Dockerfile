FROM alpine:latest
# Set Hugo Version
ENV HUGO_VERSION=0.59.1
# create website directory
RUN mkdir /root/nullday
# Copy hugo project into container
COPY . /root/nullday
# Get Hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/
ADD https://github.com/caddyserver/caddy/releases/download/v2.0.0-beta9/caddy2_beta9_linux_amd64 /tmp/
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /usr/local/bin/
RUN install -Dm755 /tmp/caddy2_beta9_linux_amd64 /usr/local/bin/caddy
# Generate static website
RUN hugo --minify --source=/root/nullday/
# Expose port 80 for nginx
EXPOSE 80
ENTRYPOINT ["/usr/local/bin/caddy"]
CMD ["file-server", "-root", "/root/nullday/public/", "-listen", "0.0.0.0:80"]
