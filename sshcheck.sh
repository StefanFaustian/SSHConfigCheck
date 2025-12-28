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
	"MaxAuthTries=4"
	"PermitUserEnvironment=no"
	"LoginGraceTime=30"
)	

for optiune in "${OPTIUNI[@]}"; do
	echo
	key="${optiune%%=*}"  ## elimina cel mai lung sufix
	recomandare="${optiune#*=}"   ## elimina cel mai lung prefix
	valoare=$(grep -E "^[[:space:]]*$key[[:space:]]+" "$fisier" | tail -n 1 | awk '{print $2}')
	potriviri=$(grep -cE "^[[:space:]]*$key[[:space:]]+" "$fisier")                                                         
	
	if (( potriviri >= 2 )); then
		awk -v key="$key" '
		$0 ~ /^[[:space:]]*#/ {next}  # omite liniile comentate
		$1 == key {
			if (!sw) {
				sw=1
				prima_ap=NR
				ultima_ap=NR
				ultima_val=$2
				next
			}
			
			
			if ($2 != ultima_val) {
				print "SUPRASCRIERE: \"" key " " $2 "\" la linia " NR " (conflict cu \"" key " " ultima_val "\")."
			}
			else {
				print "DUPLICAT: \"" key " " $2 "\" se repeta la linia " NR " (aparitie initiala la linia " prima_ap ")."
			}
			
			ultima_ap=NR
			ultima_val=$2
		}
		END {
			if (sw) print "IN EFECT: (" ultima_ap ") " key " " ultima_val 
		}
		
		' "$fisier"
	fi
	
	if [[ -z "$valoare" ]]; then                                               
		if grep -qE "^[[:space:]]*#[[:space:]]*$key[[:space:]]+" "$fisier"; then
      			echo "ATENTIE: optiunea $key este comentata (valoare implicita/nesetata explicit)."
    		else
      			echo "ATENTIE: optiunea $key nu a fost gasita."
    		fi
	elif [ "$recomandare" != "$valoare" ]; then
		echo "VULNERABILITATE: optiunea $key $valoare prezinta risc de securitate (recomandat: $key $recomandare)."
	else
		echo "VALID: optiunea $key este conforma."
	fi
done




