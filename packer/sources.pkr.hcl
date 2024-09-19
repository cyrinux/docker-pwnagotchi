variable "pwnagotchi_name" {
  default = env("PWNAGOTCHI_NAME")
}

variable "cpu_type" {
  default = env("CPU_TYPE")
}

source "arm-image" "armhf" {
  image_type = "raspberrypi"

  iso_url      = "https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz"
  iso_checksum = "file:https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/2024-07-04-raspios-bookworm-armhf-lite.img.xz.sha256"

  qemu_binary = "qemu-arm-static"
  qemu_args   = ["-cpu", "${var.cpu_type}"]

  output_filename   = "./dist/armhf/disk-${var.pwnagotchi_name}-${var.cpu_type}.img"
  target_image_size = 7 * 1024 * 1024 * 1024
}
