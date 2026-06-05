#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/panjuncai/drd_web.git}"
APP_DIR="${APP_DIR:-/var/www/drd_web}"

if command -v apt >/dev/null 2>&1; then
  sudo apt update
  sudo apt install -y nginx git
elif command -v yum >/dev/null 2>&1; then
  sudo yum install -y nginx git
else
  echo "Unsupported server package manager. Install nginx and git manually."
  exit 1
fi

if [ -d "$APP_DIR/.git" ]; then
  sudo git -C "$APP_DIR" pull --ff-only
else
  sudo mkdir -p "$(dirname "$APP_DIR")"
  sudo git clone "$REPO_URL" "$APP_DIR"
fi

if [ -d /etc/nginx/sites-available ] && [ -d /etc/nginx/sites-enabled ]; then
  NGINX_SITE="${NGINX_SITE:-/etc/nginx/sites-available/drd_web}"
  NGINX_ENABLED="/etc/nginx/sites-enabled/drd_web"
else
  NGINX_SITE="${NGINX_SITE:-/etc/nginx/conf.d/drd_web.conf}"
  NGINX_ENABLED=""
fi

sudo tee "$NGINX_SITE" >/dev/null <<NGINX
server {
    listen 80;
    server_name _;

    root $APP_DIR;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(?:jpg|jpeg|png|gif|webp|css|js|ico|svg)$ {
        expires 30d;
        add_header Cache-Control "public";
        try_files $uri =404;
    }
}
NGINX

if [ -n "$NGINX_ENABLED" ]; then
  sudo ln -sf "$NGINX_SITE" "$NGINX_ENABLED"
fi

sudo nginx -t
sudo systemctl enable nginx
sudo systemctl reload nginx || sudo systemctl restart nginx

echo "Deployed to $APP_DIR"
