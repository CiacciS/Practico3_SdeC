## @file
# HelloPkg.dsc - descripcion de plataforma (DSC) del paquete del TP #3.a
#
# El DSC le dice a 'build' tres cosas:
#   [Defines]        como se llama el paquete, para que arquitecturas y targets se compila
#   [LibraryClasses] que implementacion concreta (instancia) usar para cada clase de
#                    biblioteca que piden nuestros modulos (y las bibliotecas entre si)
#   [Components]     que modulos (.inf) hay que compilar
#
# Targets:
#   NOOPT   -O0 y simbolos: el que usamos para depurar con GDB (Parte 5)
#   DEBUG   -Os + LTO y simbolos
#   RELEASE -Os + LTO, sin el .debug enlazado
##

[Defines]
  PLATFORM_NAME                  = HelloPkg
  PLATFORM_GUID                  = aa2205f1-53ae-4604-b9a4-79488bf909a9
  PLATFORM_VERSION               = 0.01
  DSC_SPECIFICATION              = 0x0001001C
  OUTPUT_DIRECTORY               = Build/HelloPkg
  SUPPORTED_ARCHITECTURES        = X64
  BUILD_TARGETS                  = NOOPT|DEBUG|RELEASE
  SKUID_IDENTIFIER               = DEFAULT

#
# Bibliotecas comunes de MdePkg (StackCheckLib, RegisterFilterLib, ...).
# Las versiones recientes de EDK2 compilan todo con -fstack-protector y exigen una
# instancia de StackCheckLib; este include la provee.
#
!include MdePkg/MdeLibs.dsc.inc

[LibraryClasses]
  # Punto de entrada: define _ModuleEntryPoint, que corre los constructores de las
  # bibliotecas y despues llama a nuestro UefiMain
  UefiApplicationEntryPoint|MdePkg/Library/UefiApplicationEntryPoint/UefiApplicationEntryPoint.inf
  # gImageHandle, gST y gBS
  UefiBootServicesTableLib|MdePkg/Library/UefiBootServicesTableLib/UefiBootServicesTableLib.inf
  # gRT
  UefiRuntimeServicesTableLib|MdePkg/Library/UefiRuntimeServicesTableLib/UefiRuntimeServicesTableLib.inf
  # Print() y amigos
  UefiLib|MdePkg/Library/UefiLib/UefiLib.inf
  PrintLib|MdePkg/Library/BasePrintLib/BasePrintLib.inf
  MemoryAllocationLib|MdePkg/Library/UefiMemoryAllocationLib/UefiMemoryAllocationLib.inf
  DevicePathLib|MdePkg/Library/UefiDevicePathLib/UefiDevicePathLib.inf
  # Base
  BaseLib|MdePkg/Library/BaseLib/BaseLib.inf
  BaseMemoryLib|MdePkg/Library/BaseMemoryLib/BaseMemoryLib.inf
  PcdLib|MdePkg/Library/BasePcdLibNull/BasePcdLibNull.inf
  # DEBUG() y ASSERT() escriben en la consola (ConOut)
  DebugLib|MdePkg/Library/UefiDebugLibConOut/UefiDebugLibConOut.inf
  DebugPrintErrorLevelLib|MdePkg/Library/BaseDebugPrintErrorLevelLib/BaseDebugPrintErrorLevelLib.inf

[Components]
  HelloPkg/SimplestApp/SimplestApp.inf
  HelloPkg/HelloWorld/HelloWorld.inf
  HelloPkg/HelloPrint/HelloPrint.inf
