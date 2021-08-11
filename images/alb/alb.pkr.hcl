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
    sources     = ["traefik.toml", "traefik.service", "docker-compose.yaml"]
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
      "sudo mv /tmp/traefik.toml /etc/traefik/traefik.toml",
      "sudo mv /tmp/traefik.service /etc/systemd/system/traefik.service",
      "sudo mv /tmp/docker-compose.yaml /home/ubuntu/docker-compose.yaml",
      "sudo chmod 744 /etc/traefik/traefik.toml",
      "sudo chmod 744 /home/ubuntu/docker-compose.yaml",
      "sudo chmod 664 /etc/systemd/system/traefik.service",
      "sudo chmod 664 /home/ubuntu/docker-compose.yaml",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable traefik.service",
      "sudo systemctl start traefik.service"
    ]
  }
}