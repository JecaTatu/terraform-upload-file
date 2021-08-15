source "amazon-ebs" "loadbalancer" {
  region = "us-east-1"

  ami_name      = "custom-traefik-alb"
  instance_type = "t2.micro"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20201026"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.loadbalancer"]

  provisioner "file" {
    sources     = ["traefik.toml", "traefik.service", "docker-compose.yaml", "traefik", "redirect.toml"]
    destination = "/tmp/"
  }



  provisioner "shell" {
    inline = [
      "/usr/bin/cloud-init status --wait",
      "sudo apt-get update -y",
      "export PATH=$PATH:/home/ubuntu/.local/bin",
      "sudo mkdir /etc/traefik",
      "sudo mkdir /etc/docker",
      "curl -fsSL get.docker.com -o get-docker.sh",
      "sh get-docker.sh",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo chown -R $USER:$USER /etc/traefik/",
      # "tar -zxvf /tmp/traefik_binary.tar.gz",
      "sudo cp /tmp/traefik /usr/local/bin",
      "sudo setcap 'cap_net_bind_service=+ep' /usr/local/bin/traefik",
      "sudo chown root:root /usr/local/bin/traefik",
      "sudo chmod 755 /usr/local/bin/traefik",
      "sudo groupadd -g 321 traefik",
      "sudo useradd -g traefik --no-user-group --home-dir /var/www --no-create-home --shell /usr/sbin/nologin --system --uid 321 traefik",
      "sudo usermod -aG docker traefik",
      # "sudo mkdir /etc/traefik",
      "sudo mkdir /etc/traefik/acme",
      "sudo mkdir /etc/traefik/dynamic",
      "sudo chown -R root:root /etc/traefik",
      "sudo chown -R traefik:traefik /etc/traefik/dynamic",
      "sudo touch /var/log/traefik.log",
      "sudo chown traefik:traefik /var/log/traefik.log",
      "sudo mv /tmp/traefik.toml /etc/traefik/traefik.toml",
      "sudo mv /tmp/redirect.toml /etc/traefik/dynamic/redirect.toml",
      "sudo mv /tmp/traefik.service /etc/systemd/system/traefik.service",
      "sudo mv /tmp/docker-compose.yaml /home/ubuntu/docker-compose.yaml",
      "sudo chmod 744 /etc/traefik/traefik.toml",
      "sudo chmod 744 /home/ubuntu/docker-compose.yaml",
      "sudo chmod 664 /etc/systemd/system/traefik.service",
      "sudo chown root:root /etc/systemd/system/traefik.service",
      "sudo chmod 664 /home/ubuntu/docker-compose.yaml",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable traefik.service",
      "sudo systemctl start traefik.service",
      "docker-compose -f /home/ubuntu/docker-compose.yaml"
    ]
  }
}