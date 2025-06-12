# Stage 1
FROM alpine:latest AS build


# ARG HUGO_BASEURL="http://localhost"
ENV HUGO_BASEURL=${HUGO_BASEURL}

# Install the Hugo go app and git.
RUN apk add --update hugo git

WORKDIR /opt/HugoApp

# Copy Hugo config into the container's Workdir.
COPY . .

# Run Hugo in the Workdir to generate HTML in /public.
RUN hugo \
      --gc \
      --minify \
      --baseURL "${HUGO_BASEURL}/" \
      --logLevel info

# Remove git artifacts
RUN rm -rf .git

# # Stage 2
FROM nginx:alpine
# COPY public /usr/share/nginx/html
# COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# Set workdir to the NGINX default dir.
# WORKDIR /usr/share/nginx/html

# Copy HTML from previous build into the Workdir.
COPY --from=build --chown=$USER:$USER /opt/HugoApp/public /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# COPY --from=public --chown=$USER:$USER . /usr/share/nginx/html
# COPY --from=nginx default.conf /etc/nginx/conf.d/default.conf

# CMD [ "nginx", "-g", "daemon off;"]
EXPOSE 80/tcp
