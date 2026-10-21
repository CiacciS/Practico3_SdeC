/** @file
  HelloPrint.c - el mismo Hello World, pero con las bibliotecas de EDK2.

  - UefiBootServicesTableLib guarda la System Table en la global gST (y los Boot
    Services en gBS) desde su constructor, que corre antes que UefiMain.
  - UefiLib aporta Print(), que formatea como printf y termina llamando a
    gST->ConOut->OutputString.
**/

#include <Uefi.h>
#include <Library/UefiBootServicesTableLib.h>
#include <Library/UefiLib.h>

EFI_STATUS
EFIAPI
UefiMain (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  // 1. Igual que en HelloWorld, pero con la global gST
  gST->ConOut->OutputString (gST->ConOut, L"Hello World! (via gST)\r\n");

  // 2. Con Print(): acepta formato como printf (%s espera una cadena CHAR16)
  Print (L"Hello World! (via Print)\r\n");
  Print (L"Firmware: %s, revision 0x%08x\r\n", gST->FirmwareVendor, gST->FirmwareRevision);
  Print (L"UEFI %d.%d\r\n", gST->Hdr.Revision >> 16, gST->Hdr.Revision & 0xFFFF);

  return EFI_SUCCESS;
}
