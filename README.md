# Pwnagotchi on Docker

I leave here, without any support, the Docker image that I use for my [Pwnagotchi](https://pwnagotchi.ai).

![My Pwnagotchi](./resources/pwnagotchi.jpg)

# Packer image command:

```
env CPU_TYPE="cortex-a7" PWNAGOTCHI_ANDROID_MAC="F8:1F:F0:E6:AB:5C" PWNAGOTCHI_DISPLAY_ENABLED="false" PWNAGOTCHI_NAME="rpiux" PWNAGOTCHI_ANDROID_IP="192.168.44.46" make packer
```
