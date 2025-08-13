packer {
  required_plugins {
    oracle = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/oracle"
    }
  }
}

variable "ssh_private_key_file" {
  default = "/home/ubuntu/.ssh/oci_key"
}

variable "ssh_public_key_file" {
  default = "/home/ubuntu/.ssh/oci_key.pub"
}

source "oracle-oci" "ubuntu" {
  compartment_ocid     = "ocid1.tenancy.oc1..aaaaaaaa6jvn6ty3gevdog7phzcnbh7x3ek4suj4cwyd7imjhe62qwv7x2iq"
  subnet_ocid          = "ocid1.subnet.oc1.ap-hyderabad-1.aaaaaaaa4nwj6qaqilt7vfwfgq5ygal266s57effy6hotkv3lozgitdesviq"
  availability_domain  = "yFYg:AP-HYDERABAD-1-AD-1"
  shape                = "VM.Standard.E2.1.Micro"
  base_image_ocid      = "ocid1.image.oc1.ap-hyderabad-1.aaaaaaaafs7imfvcicboqisaisiz5bbpuzbg5gicwjwvyhnhsvdaowuc3w4q"
  ssh_username         = "ubuntu"
  ssh_private_key_file = var.ssh_private_key_file
}

build {
  name    = "ubuntu-nginx-oci"
  sources = ["source.oracle-oci.ubuntu"]

  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl stop nginx", # don't leave running in the image
      "echo 'Nginx installed successfully!'"
    ]
  }
