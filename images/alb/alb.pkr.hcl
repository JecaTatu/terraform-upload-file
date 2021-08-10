source "amazon-ebs" "loadbalancer" {
  region        = "us-east-1"

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
    sources = ["traefik.toml", "poetry.lock", "pyproject.toml"]
    destination = "/etc/traefik/"
  }

  provisioner "file" {
    sources = ["traefik.service", "update-config.service", "update-config.timer"]
    destination = "/etc/systemd/system/"
  }

  provisioner "shell" {
      inline = [
        "/usr/bin/cloud-init status --wait",
        "sudo apt-get update -y",
        "sudo apt-get install -y nginx python3-pip python3-testresources",
        "pip3 install poetry",
        "export PATH=$PATH:/home/ubuntu/.local/bin",
        "poetry export --without-hashes -f requirements.txt -o requirements.txt",
        "pip3 install -r requirements.txt",
        "sudo chown -R $USER:$USER /etc/nginx/",
        "sudo mv /tmp/update-config.sh /usr/local/bin/update-config.sh",
        "sudo mv /tmp/update-config.service /etc/systemd/system/update-config.service",
        "sudo mv /tmp/update-config.timer /etc/systemd/system/update-config.timer",
        "sudo chmod 744 /usr/local/bin/update-config.sh",
        "sudo chmod 664 /etc/systemd/system/update-config.service",
        "sudo chmod 664 /etc/systemd/system/update-config.service",
        "sudo systemctl daemon-reload",
        "sudo systemctl enable update-config.timer"
        "sudo systemctl enable /etc/systemd/system/traefik.service"
        "sudo systemctl start traefik.service"
      ]
  }
}