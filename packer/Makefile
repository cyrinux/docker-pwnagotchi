#!/usr/bin/make -f

SHELL := /bin/sh
.SHELLFLAGS := -euc

PACKER := $(shell command -v packer 2>/dev/null)
QEMU_IMG := $(shell command -v qemu-img 2>/dev/null)
SUDO := $(shell command -v sudo 2>/dev/null)

export IMAGE_NAME ?= docker.io/cyrinux/pwnagotchi
export PWNAGOTCHI_NAME ?= pwnagotchi
export CPU_TYPE ?= arm1176

PACKER_WORK_DIR := ./
PACKER_CACHE_DIR := ./packer_cache/
PACKER_ARMHF_OUT := ./dist/armhf/disk-$(PWNAGOTCHI_NAME)-$(CPU_TYPE).img

ifneq ($(SUDO_USER),)
	export HOME := $(shell getent passwd "$(SUDO_USER)" | cut -d: -f6)
endif

##################################################
## "all" target
##################################################

.PHONY: all
all: init build

##################################################
## "build" target
##################################################

.PHONY: build
build: build-armhf

.PHONY: build-armhf
build-armhf: $(PACKER_ARMHF_OUT)

.PHONY: init
init:
	'$(SUDO)' '$(PACKER)' init '$(PACKER_WORK_DIR)'

$(PACKER_ARMHF_OUT):
	@echo Will make pwnagotchi '$(PWNAGOTCHI_NAME)'
	mkdir -p '$(dir $(PACKER_ARMHF_OUT))'
	envsubst < '$(PACKER_WORK_DIR)'/rootfs/etc/hostname.template > '$(PACKER_WORK_DIR)'/rootfs/etc/hostname
	envsubst < '$(PACKER_WORK_DIR)'/rootfs/etc/hosts.template > '$(PACKER_WORK_DIR)'/rootfs/etc/hosts
	envsubst < '$(PACKER_WORK_DIR)'/rootfs/etc/pwnagotchi.env.template > '$(PACKER_WORK_DIR)'/rootfs/etc/pwnagotchi.env
	'$(SUDO)' '$(PACKER)' build -force -only=arm-image.armhf '$(PACKER_WORK_DIR)'
	rm -f '$(PACKER_WORK_DIR)'/rootfs/etc/pwnagotchi.env
	rm -f '$(PACKER_WORK_DIR)'/rootfs/etc/hostname
	rm -f '$(PACKER_WORK_DIR)'/rootfs/etc/hosts
	'$(SUDO)' '$(QEMU_IMG)' resize -f raw '$(PACKER_ARMHF_OUT)' 8G

##################################################
## "clean" target
##################################################

.PHONY: clean
clean:
	rm -rf '$(PACKER_ARMHF_OUT)' '$(PACKER_CACHE_DIR)'
