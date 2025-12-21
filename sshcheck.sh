#!/bin/bash

if [[ $# -ne 1 ]]; then		## Verificare ca apelul cu parametru este conform cerintei
	echo "EROARE: Apel de script invalid"
	exit 1
fi

fisier=$1

if [[ ! -e "$fisier" ]]; then		## Verificarea existentei fisierului de configurare
	echo "EROARE: Fisierul $fisier nu exista!"
	exit 1
fi

if [[ ! -r "$fisier" ]]; then		## Verificarea permisiunii de citire a fisierului de configurare
	echo "Eroare: Fisierul $fisier nu poate fi citit!"
	exit 1
fi

## Array cu setari de securitate importante avand valori recomandate
OPTIUNI=(						
	"PermitRootLogin=no"
	"PasswordAuthentication=no"
	"PubkeyAuthentication=yes"
	"PermitEmptyPasswords=no"
	"KbdInteractiveAuthentication=no"
	"UsePAM=yes"
	"AllowTcpForwarding=no"
	"X11Forwarding=no"
	"PermitTunnel=no"

)	

for optiune in "${OPTIUNI[@]}"; do
	key="${optiune%%=*}"  ## elimina cel mai lung sufix
	recomandare="${optiune#*=}"   ## elimina cel mai lung prefix
	valoare=$(grep "^[[:space:]]*$key" "$fisier" | awk '{print $2;}')
	
	
	
	if [[ -z "$valoare" ]]; then
		if grep -qiE "^[[:space:]]*#[[:space:]]*$key([[:space:]]+|$)" "$fisier"; then
      			echo "ATENTIE: optiunea $key este comentata (implicita/nesetata explicit)."
    		else
      			echo "ATENTIE: optiunea $key nu a fost gasita."
    		fi
	elif [ "$recomandare" != "$valoare" ]; then
		echo "VULNERABILITATE: optiunea $key $valoare prezinta risc de securitate (recomandat: $key $recomandare)."
	else
		echo "VALID: optiunea $key este conforma."
	fi
done




