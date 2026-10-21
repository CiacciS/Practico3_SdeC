# Makefile - atajos para compilar, correr y depurar el TP #3.a
#
#   make ovmf        compila el firmware OVMF (DEBUG) una sola vez        (Parte 1)
#   make             compila HelloPkg y copia los .efi a disco/           (Partes 2-4)
#   make run         arranca QEMU + OVMF con disco/ montado como FS0:     (Partes 2-4)
#   make debug       igual que run, pero con QEMU esperando a GDB en :1234 (Parte 5)
#   make simbolos    calcula donde quedo cargada la app (lee build/debug.log)
#   make gdb         abre GDB, carga los simbolos y se conecta a QEMU
#   make clean       borra build/ y los .efi de disco/
#
# Variables que se pueden pisar en la linea de comandos:
#   EDK2      donde esta clonado edk2           (por defecto ~/edk2)
#   TOOLCHAIN tag de compilador de EDK2         (por defecto GCC; en edk2 viejos era GCC5)
#   TARGET    NOOPT | DEBUG | RELEASE           (por defecto NOOPT: -O0, ideal para GDB)
#   APP       modulo a depurar                  (por defecto HelloWorld)
#
#   ej: make TARGET=RELEASE        make simbolos APP=HelloPrint
#
# OJO: las lineas de las recetas tienen que empezar con TAB, no con espacios.

SHELL     := /bin/bash
EDK2      ?= $(HOME)/edk2
TOOLCHAIN ?= GCC
TARGET    ?= NOOPT
APP       ?= HelloWorld

PKG_BUILD := $(EDK2)/Build/HelloPkg/$(TARGET)_$(TOOLCHAIN)/X64
OVMF_FV   := $(EDK2)/Build/OvmfX64/DEBUG_$(TOOLCHAIN)/FV
OVMF_X64  := $(EDK2)/Build/OvmfX64/DEBUG_$(TOOLCHAIN)/X64
DISCO     := disco
VARS      := build/OVMF_VARS.fd
BOOTX64   := $(DISCO)/EFI/BOOT/BOOTX64.EFI
LOG       := build/debug.log

# Carga el entorno de EDK2 en la misma shell en la que corre 'build'.
# PACKAGES_PATH le dice a 'build' que busque paquetes tambien en este repo,
# asi HelloPkg no tiene que estar copiado adentro de edk2.
EDK_ENV   := cd $(EDK2) && export PACKAGES_PATH=$(EDK2):$(CURDIR) && source ./edksetup.sh > /dev/null &&

# OVMF_CODE.fd: el firmware (solo lectura).  OVMF_VARS.fd: la NVRAM (copia propia, escribible).
# -m 256M fijo: con la misma configuracion, OVMF carga la app siempre en la misma direccion.
# -debugcon: todo lo que OVMF escribe en el puerto 0x402 (sus DEBUG()) va a build/debug.log.
QEMU      := qemu-system-x86_64 -m 256M \
             -drive if=pflash,format=raw,unit=0,readonly=on,file=$(OVMF_FV)/OVMF_CODE.fd \
             -drive if=pflash,format=raw,unit=1,file=$(VARS) \
             -drive format=raw,file=fat:rw:$(DISCO) \
             -net none -nographic \
             -global isa-debugcon.iobase=0x402 -debugcon file:$(LOG)

.PHONY: all app disco ovmf run debug simbolos gdb clean

all: disco

app:
	$(EDK_ENV) build -p HelloPkg/HelloPkg.dsc -a X64 -t $(TOOLCHAIN) -b $(TARGET)

disco: app
	cp $(PKG_BUILD)/SimplestApp.efi $(PKG_BUILD)/HelloWorld.efi $(PKG_BUILD)/HelloPrint.efi $(DISCO)/
	ls -l $(DISCO)

ovmf:
	$(EDK_ENV) build -p OvmfPkg/OvmfPkgX64.dsc -a X64 -t $(TOOLCHAIN) -b DEBUG

$(VARS):
	mkdir -p build
	cp $(OVMF_FV)/OVMF_VARS.fd $@

# La UEFI Shell que se compilo junto con OVMF, en la ruta de arranque por defecto
# de un medio removible (\EFI\BOOT\BOOTX64.EFI). OVMF registra su Shell interna
# como opcion de categoria APP y BDS no la arranca sola: arranca solo opciones de
# categoria BOOT, como este disco. Asi la Shell arranca sin pasar por el menu.
$(BOOTX64):
	mkdir -p $(dir $@)
	cp $(OVMF_X64)/Shell.efi $@

run: $(VARS) $(BOOTX64)
	$(QEMU)

debug: $(VARS) $(BOOTX64)
	$(QEMU) -s

simbolos:
	scripts/simbolos.sh $(APP) $(LOG) $(PKG_BUILD) build/simbolos.gdb

gdb:
	gdb -x scripts/conectar.gdb

clean:
	rm -rf build
	rm -f $(DISCO)/*.efi
	rm -rf $(DISCO)/EFI
