#!/bin/bash
set -ex
sudo yum update -y
echo "[+] Installing docker"
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
echo "[+] Installing docker compose"
sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "[+] Writing docker-compose for traefik"
cat /home/docker-compose.yaml <<EOF
version: "3.3"

services:
  traefik:
    image: "traefik:v2.0.0"
    command:
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --providers.docker
      - --api
      - --log.level=DEBUG
      - --certificatesresolvers.letsencrypt.acme.email=gas5@cin.ufpe.br
      - --certificatesresolvers.letsencrypt.acme.storage=/acme.json
      - --certificatesresolvers.letsencrypt.acme.tlschallenge=true
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./acme.json:/acme.json"
    labels:
      # Dashboard
      - "traefik.http.routers.traefik.rule=Host(`dashboard.gas.localhost`)"
      - "traefik.http.routers.traefik.service=api@internal"
      - "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
      - "traefik.http.routers.traefik.entrypoints=websecure"
      - "traefik.http.routers.http-catchall.rule=hostregexp(`{host:.+}`)"
      - "traefik.http.routers.http-catchall.entrypoints=web"
      - "traefik.http.routers.http-catchall.middlewares=redirect-to-https"
      - "traefik.http.middlewares.redirect-to-https.redirectscheme.scheme=https"

  webapp:
    image: containous/whoami:v1.3.0
    labels:
      - "traefik.http.routers.app1.rule=Host(`web.gas.localhost`)"
      - "traefik.http.routers.app1.entrypoints=websecure"
      - "traefik.http.routers.app1.tls=true"
      - "traefik.http.routers.app1.tls.certresolver=letsencrypt"
EOF
echo "[+] Running traefik docker"
cd /home/
sudo docker-compose -d