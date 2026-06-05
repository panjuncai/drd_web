# ECS 部署说明

这个项目是纯静态站，ECS 上用 Nginx 托管即可。

## 服务器要求

- 安全组开放 `22`、`80`
- 建议系统：Ubuntu 22.04、Debian、Alibaba Cloud Linux
- 如果后续绑定域名并启用 HTTPS，再开放 `443`
- 如果使用现有 `bigclouder.com` Nginx 配置，可把 `deploy/nginx-bigclouder-drd-web.conf` 追加到当前 Nginx 配置中，对应域名是 `d.bigclouder.com`

## 一键部署

登录 ECS 后执行：

```bash
curl -fsSL https://raw.githubusercontent.com/panjuncai/drd_web/main/deploy/ecs-setup.sh -o ecs-setup.sh
chmod +x ecs-setup.sh
./ecs-setup.sh
```

部署目录默认是：

```text
/var/www/drd_web
```

部署完成后访问 ECS 公网 IP。

## 整合到现有 bigclouder.com Nginx 配置

已准备配置片段：

```text
deploy/nginx-bigclouder-drd-web.conf
```

它会新增：

```text
d.bigclouder.com
www.d.bigclouder.com
```

站点根目录：

```text
/var/www/drd_web
```

把配置放到服务器后检查并重载：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 更新网站

本地修改后：

```bash
npm run build
git add .
git commit -m "Update site"
git push
```

服务器上更新：

```bash
cd /var/www/drd_web
sudo git pull --ff-only
sudo systemctl reload nginx
```

## 本地构建

页面不再依赖 Tailwind CDN，CSS 由本地构建生成：

```bash
npm install
npm run build
```
