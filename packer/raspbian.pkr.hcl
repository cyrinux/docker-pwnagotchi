source "arm-image" "raspbian" {
  image_type = "raspberrypi"

  iso_url = "https://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2019-09-30/2019-09-26-raspbian-buster-lite.zip"
  iso_checksum = "a50237c2f718bd8d806b96df5b9d2174ce8b789eda1f03434ed2213bbca6c6ff"
  iso_checksum_type = "sha256"

  qemu_binary = "qemu-arm-static"
  qemu_args = ["-cpu", "arm1176", "-E", "LANG=en_US.UTF-8", "-E", "LC_ALL=en_US.UTF-8"]

  output_filename = "raspbian.img"
  target_image_size = 4294967296
}

build {
  sources = [
    "source.arm-image.raspbian"
  ]

  provisioner "file" {
    direction = "upload"
    source = "./rootfs/"
    destination = "/"
  }

  provisioner "shell" {
    inline = [
      "hostname -F /etc/hostname",
      "rm -f /etc/localtime",
      "dpkg-reconfigure -f noninteractive tzdata",
      "dpkg-reconfigure -f noninteractive locales",
      "dpkg-reconfigure -f noninteractive keyboard-configuration"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DPKG_FORCE=confold",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "apt-get update",
      "apt-get dist-upgrade -y",
      "apt-mark hold firmware-brcm80211",
      "apt-get purge -y bluez nfs-common raspberrypi-net-mods triggerhappy unattended-upgrades wpasupplicant",
      "apt-get install -y --no-install-recommends apt-transport-https ca-certificates crda curl dnsmasq dphys-swapfile gnupg htop i2c-tools openssh-server"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DPKG_FORCE=confold",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "printf '%s\n' 'deb [arch=armhf] http://http.re4son-kernel.com/re4son/ kali-pi main' > /etc/apt/sources.list.d/re4son.list",
      "curl --proto '=https' --tlsv1.3 -sSf 'https://re4son-kernel.com/keys/http/archive-key.asc' | apt-key add -",
      "apt-get update",
      "apt-get install -y --no-install-recommends kalipi-bootloader kalipi-kernel kalipi-kernel-headers kalipi-re4son-firmware",
      "apt-get install -y --no-install-recommends libraspberrypi-bin libraspberrypi-dev libraspberrypi-doc libraspberrypi0"
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DPKG_FORCE=confold",
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "printf '%s\n' 'deb [arch=armhf] https://download.docker.com/linux/raspbian/ buster stable' > /etc/apt/sources.list.d/docker.list",
      "curl --proto '=https' --tlsv1.2 -sSf 'https://download.docker.com/linux/raspbian/gpg' | apt-key add -",
      "apt-get update",
      "apt-get install -y --no-install-recommends docker-ce docker-ce-cli"
    ]
  }

  provisioner "shell" {
    inline = [
      "systemctl disable apt-daily.timer apt-daily-upgrade.timer dhcpcd.service fake-hwclock.service",
      "systemctl enable dnsmasq.service docker.service dphys-swapfile.service fstrim.timer ssh.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "apt-get autoremove -y",
      "rm -rf /var/lib/apt/lists/*",
      "rm -f /etc/ssh/ssh_host*_key*"
    ]
  }
}
