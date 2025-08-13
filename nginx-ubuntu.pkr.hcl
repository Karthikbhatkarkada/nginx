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

  # Copy your Nginx repo into VM
  provisioner "file" {
    source      = "."   # Assuming Jenkins workspace contains your repo
    destination = "/tmp/nginx-src"
  }

  # Build and install Nginx in the VM
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y gcc make",
      "cd /tmp/nginx-src",
      "auto/configure",
      "make",
      "sudo make install",    
      "sudo ln -sf /usr/local/nginx/sbin/nginx /usr/bin/nginx",
    ]
  }
}
