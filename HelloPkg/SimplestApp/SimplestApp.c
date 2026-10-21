/** @file
  SimplestApp.c - la aplicacion UEFI mas chica posible.

  No imprime nada: solo le devuelve EFI_SUCCESS al que la cargo (la UEFI Shell).
  Sirve para ver que el ciclo compilar -> copiar al disco -> ejecutar en OVMF anda.
**/

#include <Uefi.h>

EFI_STATUS
EFIAPI
UefiMain (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  return EFI_SUCCESS;
}
