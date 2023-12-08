# eBPF Lab
This is a lab environment with example code from the book Learning eBPF by Liz
Rice: https://github.com/lizrice/learning-ebpf

## Lab Environment
A packer configuration was created in the `packer` folder to build and
configure a Centos 9 stream VM with:
* bcc (https://github.com/iovisor/bcc)
* bpftool (https://github.com/libbpf/bpftool)
* bpftrace (https://github.com/iovisor/bpftrace)

Unfortunately, some blockers (broken functionality, missing features) were
encountered pretty early in the eBPF learning process when using the pre-built
software from the distribution repositories. Therefore, most recent components
are built from the main branch with the idea of a reproducible lab environment. 

The Packer build allows to reproduce and develop the Lab image. To create the
qemu image with Packer:
```
cd packer
packer build libvirt-centos9.pkr.hcl
```

## Setup and Connect to Lab VM

Configure location of qemu image:
```
qemuimg=output/centos9-20230512-132055/centos9-20230512-132055.qcow2
```

Create the KVM lab VM:
```
sudo virt-install --name ebpf-lab --description "eBPF Lab" \
 --osinfo=centos-stream9 --ram=4096 --vcpus=2 \
 --disk path=$qemuimg --boot hd --wait 0 --autostart
```

Create a sample ssh config:
```
domip=$(sudo virsh -q domifaddr ebpf-lab | awk '{print $4}' | cut -d/ -f 1)

cat << EOF > ssh-config
Host ebpf-lab
    HostName $domip
    User root
EOF
```

Connect to the VM with password `root`:
```
ssh ebpf-lab -F ssh-config
```

## Usage
* Work as the root user

## Lab cleanup
Remove the VM and associated resource:
```
sudo virsh destroy ebpf-lab
sudo virsh undefine ebpf-lab
rm ssh-config
rm $qemuimg
```
