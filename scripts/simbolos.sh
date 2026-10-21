#!/usr/bin/env bash
#
# simbolos.sh - arma el comando de GDB que carga los simbolos de una app UEFI
#               en la direccion donde OVMF la cargo.
#
# Uso: scripts/simbolos.sh <Modulo> <debug.log> <dir_build> <salida.gdb>
#   ej: scripts/simbolos.sh HelloWorld build/debug.log ~/edk2/Build/HelloPkg/NOOPT_GCC/X64 build/simbolos.gdb
#
# Por que hace falta: el .efi es un PE/COFF reubicable. El firmware (LoadImage) elige
# en tiempo de ejecucion donde ponerlo en memoria, asi que GDB no puede saber solo
# donde quedo cada funcion. El DXE Core de OVMF (compilado en DEBUG) lo informa por
# el puerto de depuracion 0x402 con una linea como:
#
#   Loading driver at 0x00006649000 EntryPoint=0x0000664C658 HelloWorld.efi
#
# Direccion de cada seccion en memoria = base de carga + VMA (RVA) de la seccion en el PE.
# Esas direcciones se le pasan a 'add-symbol-file' junto con el .debug (ELF con DWARF).

set -euo pipefail

if [[ $# -ne 4 ]]; then
  echo "Uso: $0 <Modulo> <debug.log> <dir_build> <salida.gdb>" >&2
  exit 1
fi

MODULO=$1
LOG=$2
DIR=$3
SALIDA=$4

EFI="$DIR/$MODULO.efi"
DEBUG="$DIR/$MODULO.debug"

for f in "$LOG" "$EFI" "$DEBUG"; do
  [[ -f $f ]] || { echo "Error: no existe $f" >&2; exit 1; }
done

# 1. Base de carga: la ultima vez que el log registro la carga del modulo
LINEA=$(grep -a "Loading driver at .* $MODULO.efi" "$LOG" | tail -n 1 || true)
if [[ -z $LINEA ]]; then
  echo "Error: $LOG no tiene la linea 'Loading driver at ... $MODULO.efi'." >&2
  echo "       Corre la app al menos una vez con 'make run' (OVMF DEBUG) y volve a intentar." >&2
  exit 1
fi
BASE=$(sed -E 's/.*Loading driver at (0x[0-9A-Fa-f]+).*/\1/' <<< "$LINEA")
ENTRY=$(sed -E 's/.*EntryPoint=(0x[0-9A-Fa-f]+).*/\1/' <<< "$LINEA")

# 2. RVA de .text y .data dentro del PE (columna VMA de objdump -h)
rva() { objdump -h "$EFI" | awk -v s="$1" '$2 == s { print "0x" $4 }'; }
TEXT_RVA=$(rva .text)
DATA_RVA=$(rva .data)

TEXT=$(printf '0x%x' $((BASE + TEXT_RVA)))
DATA=$(printf '0x%x' $((BASE + DATA_RVA)))

# 3. Control cruzado: EntryPoint - base tiene que ser la direccion de _ModuleEntryPoint en el .debug
ENTRY_RVA=$(printf '0x%x' $((ENTRY - BASE)))
ENTRY_SYM=$(nm "$DEBUG" | awk '$3 == "_ModuleEntryPoint" { print "0x" $1 }')

echo "Linea del log      : $LINEA"
echo "Base de carga      : $BASE"
echo ".text  RVA $TEXT_RVA -> $TEXT"
echo ".data  RVA $DATA_RVA -> $DATA"
echo "EntryPoint - base  : $ENTRY_RVA   (_ModuleEntryPoint en el .debug: $(printf '0x%x' $((ENTRY_SYM))))"

cat > "$SALIDA" <<EOF
# Generado por scripts/simbolos.sh a partir de: $LINEA
add-symbol-file $DEBUG $TEXT -s .data $DATA
EOF
echo "Escrito $SALIDA"
