source "hyperv-iso" "fedora_34" {
    # We are using the Fedora 34 "Everything" ISO
    iso_url = "https://download.fedoraproject.org/pub/fedora/linux/releases/34/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-34-1.2.iso"
    iso_checksum = "sha256:eb617779a454f9792a84985d1d6763f78c485e89a0d09e9e62b4dabcd540aff1"

    # Serving the kickstart file from the files directory
    http_directory = "./files"

    # This boot command selects the "Install Fedora 34" option (by default the boot screen
    # has "Test media and install fedora 34" selected, which is redundant since Packer has
    # already verified the ISO's integrity) and tells kickstart to fetch the configuration
    # from Packer's built-in webserver and use that.
    boot_command = [
        "c",
        "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd\\:LABEL=Fedora-E-dvd-x86_64-34",
        " inst.ks=http\\://{{ .HTTPIP }}\\:{{ .HTTPPort }}/anaconda-ks-merged-hyperv.cfg<enter>",
        "<wait5>",
        "initrdefi /images/pxeboot/initrd.img<enter>",
        "<wait5>",
        "boot<enter>"
    ]

    # Hyper-V configuration.
    disk_size = "262144"
    memory = "2048"
    vm_name = "dev_fedora-34"
    cpus = 2
    generation = 2
    enable_secure_boot = true
    secure_boot_template = "MicrosoftUEFICertificateAuthority"
    skip_export = true
    switch_name = "Default Switch"

    # We don't need to run any scripts after the initial provisioning is done,
    # so we can get away with no communicator and setting a long shutdown timeout
    # to ensure that the install completes.
    # The major variables here are internet speed (the install does have to download
    # some packages) and disk io speed, of course.
    communicator = "ssh"
    ssh_username = "sramanujam"
    ssh_private_key_file = "~/.ssh/id_rsa"
    ssh_timeout = "3h"
}

build {
    sources = [
        "sources.hyperv-iso.fedora_34"
    ]
}
