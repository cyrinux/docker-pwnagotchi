variables {
  pwnagotchi_name = env("PWNAGOTCHI_NAME")
}

source "arm-image" "armhf" {
  image_type = "raspberrypi"

  iso_url      = "https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip"
  iso_checksum = "file:https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-05-28/2021-05-07-raspios-buster-armhf-lite.zip.sha256"

  qemu_binary = "qemu-arm-static"
  qemu_args   = ["-cpu", "arm1176"]

  output_filename   = "./dist/armhf/disk-${var.pwnagotchi_name}.img"
  target_image_size = 6442450944
}
