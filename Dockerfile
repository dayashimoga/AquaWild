# Multi-platform Flutter build & development environment
FROM ghcr.io/cirruslabs/flutter:3.38.4 AS build-env

WORKDIR /app

# Copy dependency specifications and resolve packages
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy source code
COPY . .

# Run static analysis and tests
RUN flutter analyze --fatal-infos --fatal-warnings
RUN flutter test

# Build Flutter Web target
RUN flutter build web --release

# Production lightweight static web server stage
FROM nginx:alpine AS runtime
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
