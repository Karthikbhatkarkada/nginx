variable "oci_config_file" {}
variable "compartment_id" {}

source "oracle-oci" "ubuntu" {
  config_file_profile = "DEFAULT"
  config_file         = var.oci_config_file
  compartment_id      = var.compartment_id
  image_ocid          = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaafs7imfvcicboqisaisiz5bbpuzbg5gicwjwvyhnhsvdaowuc3w4q"
  shape               = "VM.Standard.E2.1.Micro"
  ssh_username        = "ubuntu"
}

build {
  sources = ["source.oracle-oci.ubuntu"]

  # Copy Jenkins-built Nginx files to VM
  provisioner "file" {
    source      = "nginx-build"  # Folder from Jenkins build
    destination = "/tmp/nginx-build"
  }

  # Install runtime deps, place nginx in proper path, configure service
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y libpcre3 zlib1g libssl3",
      "sudo mkdir -p /usr/local/nginx",
      "sudo cp -r /tmp/nginx-build/* /usr/local/nginx/",
      "sudo ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx",
      "sudo bash -c 'cat <<EOF > /etc/systemd/system/nginx.service
[Unit]
Description=Nginx Service
After=network.target

[Service]
ExecStart=/usr/local/nginx/sbin/nginx -g \"daemon off;\"
Restart=always

[Install]
WantedBy=multi-user.target
EOF'",
      "sudo systemctl enable nginx"
    ]
  }
}
