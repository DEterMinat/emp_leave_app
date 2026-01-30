# Stage 1: Build Flutter Web
FROM ubuntu:22.04 AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Clear folder before get dependencies
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
