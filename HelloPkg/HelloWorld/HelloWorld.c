/** @file
  HelloWorld.c - Hello World "a mano", sin bibliotecas de impresion.

  El firmware nos pasa un puntero a la EFI_SYSTEM_TABLE. De ahi sacamos ConOut,
  que es la interfaz del protocolo EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL asociada a la
  consola, y llamamos a su funcion OutputString.

  Las cadenas en UEFI son CHAR16 (UTF-16): por eso el prefijo L"...".
  El salto de linea en la consola UEFI es \r\n (retorno de carro + nueva linea).
**/

#include <Uefi.h>

EFI_STATUS
EFIAPI
UefiMain (
  IN EFI_HANDLE        ImageHandle,
  IN EFI_SYSTEM_TABLE  *SystemTable
  )
{
  EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL  *ConOut;
  EFI_STATUS                       Status;

  ConOut = SystemTable->ConOut;

  //
  // Los protocolos son structs de punteros a funcion. El primer argumento de cada
  // funcion es siempre el propio protocolo ("This"), como un 'self' explicito.
  //
  Status = ConOut->OutputString (ConOut, L"Hello World!\r\n");

  return Status;
}
