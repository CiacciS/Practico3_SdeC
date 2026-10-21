# conectar.gdb - se carga con 'make gdb' (gdb -x scripts/conectar.gdb)
#
# 1. Carga los simbolos de la app en la direccion donde OVMF la va a cargar
#    (build/simbolos.gdb lo genera 'make simbolos').
# 2. Pone un breakpoint en la primera instruccion de UefiMain (antes del prologo).
# 3. Se conecta al stub de GDB que abre QEMU con -s (tcp::1234).
#
# Despues de esto QEMU queda detenido: escribi 'continue' en GDB y recien ahi
# ejecuta la app en la UEFI Shell.

set pagination off
# add-symbol-file pregunta (y or n); con esto no pregunta
set confirm off
set architecture i386:x86-64

source build/simbolos.gdb

# Con '*' frena en la direccion exacta; sin '*', GDB intenta saltear el prologo
# y donde frena depende de su version
break *UefiMain

target remote :1234
