FROM nginx:stable-alpine
# Set Hugo Version
ENV HUGO_VERSION=0.54.0
# Copy hugo project into container
COPY . .
# Get Hugo
ADD https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz /tmp/
RUN tar -xf /tmp/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C /usr/local/bin/
# Generate static website
RUN hugo --destination=/usr/share/nginx/html/
# Expose port 80 for nginx
EXPOSE 80


