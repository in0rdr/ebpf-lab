variable "manifest" {
  type    = string
  default = "manifest.json"
}

source "qemu" "centos9" {
  accelerator      = "kvm"
  boot_command     = ["<up><tab> rd.shell ip=dhcp inst.cmdline inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter>"]
  boot_wait        = "5s"
  cpu_model        = "host"
  disk_interface   = "virtio"
  disk_size        = "14000"
  memory           = "4096"
  cpus             = "2"
  net_device       = "virtio-net"
  format           = "qcow2"
  http_directory   = "config"
  iso_checksum     = "file:https://linuxsoft.cern.ch/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso.SHA256SUM"
  iso_url          = "https://linuxsoft.cern.ch/centos-stream/9-stream/BaseOS/x86_64/iso/CentOS-Stream-9-latest-x86_64-boot.iso"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  ssh_timeout      = "20m"
  ssh_username     = "root"
  ssh_password     = "root"
  vm_name          = "centos9-${formatdate("YYYYMMDD-hhmmss", timestamp())}.qcow2"
  output_directory = "output/centos9-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
}

build {
  sources = ["source.qemu.centos9"]

  provisioner "shell" {
    script = "scripts/ebpf-lab.sh"
  }

  post-processor "manifest" {
    output     = "${var.manifest}"
    strip_path = true
  }
}
