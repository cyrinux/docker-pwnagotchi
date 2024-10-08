variable "image_name" {
  type = string
}

variable "pisugar_enabled" {
  type = bool
}

locals {
  install_pisugar = <<-EOF
    %{if var.pisugar_enabled}
    rpi-pisugar-install
    %{endif}
  EOF
}

build {
  name = "main"

  sources = [
    "source.arm-image.armhf"
  ]

  provisioner "file" {
    direction   = "upload"
    source      = "./rootfs"
    destination = "/tmp"
  }

  provisioner "shell" {
    environment_vars = [
      "TZ=UTC",
      "LANG=en_US.UTF-8",
      "LC_ALL=en_US.UTF-8",
      "DPKG_FORCE=confold",
      "DEBIAN_FRONTEND=noninteractive",
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ]
    skip_clean      = true
    execute_command = "/usr/bin/env -i {{ .Vars }} /bin/sh -eux {{ .Path }}"
    inline = [
      <<EOF
        find /tmp/rootfs/ -type f -name .gitkeep -delete
        find /tmp/rootfs/ -type d -exec chmod 755 '{}' ';' -exec chown root:root '{}' ';'
        find /tmp/rootfs/ -type f -exec chmod 644 '{}' ';' -exec chown root:root '{}' ';'
        find /tmp/rootfs/ -type f -regex '.+/\(bin/.+\|rc\.local$\)' -exec chmod 755 '{}' ';'
        find /tmp/rootfs/ -mindepth 1 -maxdepth 1 -exec cp -fa '{}' / ';'
        rm -rf /tmp/rootfs/
      EOF
      ,
      <<EOF
        hostname -F /etc/hostname
        rm -f /etc/localtime
        dpkg-reconfigure -f noninteractive tzdata
        dpkg-reconfigure -f noninteractive locales
        dpkg-reconfigure -f noninteractive keyboard-configuration
      EOF
      ,
      <<EOF
        apt-get update
        apt-get dist-upgrade -y
      EOF
      ,
      <<EOF
        apt-get install -y \
          bash \
          ca-certificates \
          crda \
          curl \
          dnsmasq \
          dphys-swapfile \
          gnupg \
          htop \
          i2c-tools \
          jq \
          openssh-server \
          zstd \
          golang \
          vim \
          xxd \
          bc
      EOF
      ,
      local.install_pisugar
      ,
      <<EOF
        apt-get install -y \
          python3-rpi.gpio python3-pip \
          python-smbus python-dev \
          libopenjp2-7 \
          && pip3 install Pillow==8.2.0
      EOF
      ,
      <<EOF
        apt-get purge -y \
          firmware-brcm80211 \
          nfs-common \
          raspberrypi-net-mods \
          triggerhappy \
          unattended-upgrades \
          wpasupplicant \
          libraspberrypi0 \
          libraspberrypi-dev \
          libraspberrypi-doc \
          libraspberrypi-bin
        apt-get autoremove -y
      EOF
      ,
      <<EOF
        rpi-rtl8821au-update
        rpi-nexmon-update
        rm -rf /usr/local/src/nexmon/
      EOF
      ,
      <<EOF
        curl --proto '=https' --tlsv1.3 -sSf 'https://download.docker.com/linux/raspbian/gpg' | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
        printf '%s\n' "deb [arch=armhf signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/raspbian/ $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
        apt-get update && apt-get install -y docker-ce
      EOF
      ,
      <<EOF
        systemctl set-default multi-user.target
        systemctl disable \
          apt-daily-upgrade.timer \
          apt-daily.timer \
          dhcpcd.service \
          fake-hwclock.service \
          bluetooth.service \
          ifup@wlan0.service \
          ifup@wlan1.service
        systemctl mask \
          bluetooth.service
        systemctl enable \
          dnsmasq.service \
          docker.service \
          dphys-swapfile.service \
          fstrim.timer \
          pwnagotchi.service \
          ssh.service
      EOF
      ,
      <<EOF
        download-frozen-image /tmp/pwnagotchi-image/ ${var.image_name}:latest
        tar -cf /var/lib/pwnagotchi-image.tar -C /tmp/pwnagotchi-image/ ./
        rm -rf /tmp/pwnagotchi-image/
        ln -s /var/lib/pwnagotchi/peers /root/peers
        ln -s /var/lib/pwnagotchi/handshakes /root/handshakes
      EOF
      ,
      <<EOF
        curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.gpg | apt-key add -
        curl -fsSL https://pkgs.tailscale.com/stable/raspbian/buster.list | tee /etc/apt/sources.list.d/tailscale.list
        apt-get update && apt-get install tailscale -y
      EOF
      ,
      <<EOF
        rm -f /etc/ssh/ssh_host_*key*
        find /var/lib/apt/lists/ -mindepth 1 -delete; apt-get clean
        find / -type f -regex '.+\.\(dpkg\|ucf\)-\(old\|new\|dist\)' -ignore_readdir_race -delete ||:
        find /tmp/ /var/tmp/ -ignore_readdir_race -mindepth 1 -delete ||:
      EOF
    ]
  }
}
