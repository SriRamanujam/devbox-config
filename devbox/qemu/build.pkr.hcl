source "qemu" "fedora_34" {
    # We are using the Fedora 34 "Everything" ISO
    iso_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/34/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-34-1.2.iso"
    iso_checksum = "sha256:eb617779a454f9792a84985d1d6763f78c485e89a0d09e9e62b4dabcd540aff1"

    # Serving the kickstart file from the files directory
    http_directory = "./files"

    # Direct QEMU configuration. Kickstart will not run unless you give it 2GB or more
    # of RAM, and 2 CPUs is just to make things faster.
    disk_size = "256G"
    disk_interface = "virtio"
    format = "qcow2"
    memory = "2048"
    cpus = "2"
    accelerator = "kvm"
    vm_name = "dev_fedora-34.qcow2"

    # This boot command selects the "Install Fedora 34" option (by default the boot screen
    # has "Test media and install fedora 34" selected, which is redundant since Packer has
    # already verified the ISO's integrity) and tells kickstart to fetch the configuration
    # from Packer's built-in webserver and use that.
    boot_command = [
        "<up><wait><tab><wait>",
        " inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/anaconda-ks-merged.cfg<enter>"
    ]
    boot_key_interval = "30ms"

    # We don't need to run any scripts after the initial provisioning is done,
    # so we can get away with no communicator and setting a long shutdown timeout
    # to ensure that the install completes.
    # The major variables here are internet speed (the install does have to download
    # some packages) and disk io speed, of course.
    communicator = "none"
    shutdown_timeout = "3h"
}

source "qemu" "ubuntu_2104" {
    iso_url = "http://releases.ubuntu.com/21.04/ubuntu-21.04-live-server-amd64.iso"
    iso_checksum = "sha256:e4089c47104375b59951bad6c7b3ee5d9f6d80bfac4597e43a716bb8f5c1f3b0"

    # Serving the autoinstall file from the files directory
    http_directory = "./files"

    # Direct QEMU configuration. VMs tend not to run in under 2 GB of RAM these days.
    disk_size = "256G"
    disk_interface = "virtio"
    format = "qcow2"
    memory = "2048"
    cpus = "2"
    accelerator = "kvm"
    vm_name = "dev_ubuntu-2104.qcow2"

    # This boot command comes from the official Vagrant
    # bento box.
    boot_command = [
                " <wait>",
                " <wait>",
                " <wait>",
                " <wait>",
                " <wait>",
                "c",
                "<wait>",
                "set gfxpayload=keep",
                "<enter><wait>",
                "linux /casper/vmlinuz quiet<wait>",
                " autoinstall<wait>",
                " ds=nocloud-net<wait>",
                "\\;s=http://<wait>",
                "{{.HTTPIP}}<wait>",
                ":{{.HTTPPort}}/<wait>",
                " ---",
                "<enter><wait>",
                "initrd /casper/initrd<wait>",
                "<enter><wait>",
                "boot<enter><wait>"
    ]

    # We don't need to run any scripts after the initial provisioning is done,
    # so we can get away with no communicator and setting a long shutdown timeout
    # to ensure that the install completes.
    # The major variables here are internet speed (the install does have to download
    # some packages) and disk io speed, of course.
    communicator = "none"
    shutdown_timeout = "3h"
}


build {
    sources = [
        "sources.qemu.fedora_34",
        "sources.qemu.ubuntu_2104"
    ]
}