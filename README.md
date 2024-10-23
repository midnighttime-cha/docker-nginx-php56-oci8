# Deploy

## Docker run
```bash
docker run -d -p 8081:80 \
    --restart=always \
    -v /var/www/html:/var/www/html \
    --name docker-nginx-php56-oci8 \
    --log-driver json-file \
    --log-opt max-size=15m \
    --log-opt max-file=5 \
    ghcr.io/midnighttime-cha/docker-nginx-php56-oci8:latest
```