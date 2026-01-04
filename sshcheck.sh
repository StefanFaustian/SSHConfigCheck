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
	echo "EROARE: Fisierul $fisier nu poate fi citit!"
	exit 1
fi

## Array cu setari de securitate importante avand valori recomandate
## cheie;;valori_permise;;valori_recomandate;;mesaj
OPTIUNI=(
	"PermitRootLogin;;^(yes|no|prohibit-password|forced-commands-only)$;;^(no|prohibit-password)$;;\"PermitRootLogin no\" sau \"PermitRootLogin prohibit-password\""
	"PasswordAuthentication;;^(yes|no)$;;^no$;;\"PasswordAuthentication no\""
	"PubkeyAuthentication;;^(yes|no)$;;^yes$;;\"PubkeyAuthentication yes\""
	"PermitEmptyPasswords;;^(yes|no)$;;^no$;;\"PermitEmptyPasswords no\""
	"KbdInteractiveAuthentication;;^(yes|no)$;;^no$;;\"KbdInteractiveAuthentication no\""
	"UsePAM;;^(yes|no)$;;^yes$;;\"UsePAM yes\""
	"AllowTcpForwarding;;^(yes|no)$;;^no$;;\"AllowTcpForwarding no\""
	"X11Forwarding;;^(yes|no)$;;^no$;;\"X11Forwarding no\""
	"PermitTunnel;;^(yes|no)$;;^no$;;\"PermitTunnel no\""
	"MaxAuthTries;;^[0-9]+$;;^([1-4])$;;\"MaxAuthTries [1-4]\""
	"LoginGraceTime;;^([0-9]+([smhdw])?)$;;^(3[0-9]|4[0-9]|5[0-9]|60|1m)$;;\"LoginGraceTime [30-60]\""
)	

for optiune in "${OPTIUNI[@]}"; do
	echo
	key="${optiune%%;;*}"  ## extrage cel mai lung prefix
	aux="${optiune#*;;}"   ## extrage cel mai lung sufix
	permis="${aux%%;;*}"
	aux="${aux#*;;}"
	recomandare="${aux%%;;*}"
	mesaj="${aux#*;;}"
	valoare=$(grep -E "^[[:space:]]*$key[[:space:]]+" "$fisier" | tail -n 1 | awk '{print $2}')
	potriviri=$(grep -cE "^[[:space:]]*$key[[:space:]]+" "$fisier")                                                         
	
	if (( potriviri >= 2 )); then
		awk -v key="$key" -v permis="$permis" '
		$0 ~ /^[[:space:]]*#/ {next}  # omite liniile comentate
		$1 == key {
			if ($2 !~ permis) {
			      print "EROARE: (" NR ") optiunea \"" key " " $2 "\" este invalida."
			      valid=1
   			}
   			
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
			if (sw && !valid) print "IN EFECT: (" ultima_ap ") " key " " ultima_val 
		}
		
		' "$fisier"
	fi
	
	if [[ -z "$valoare" ]]; then                                               
		if grep -qE "^[[:space:]]*#[[:space:]]*$key[[:space:]]+" "$fisier"; then
      			echo "ATENTIE: optiunea $key este comentata (valoare implicita/nesetata explicit)."
    		else
      			echo "ATENTIE: optiunea $key nu a fost gasita (valoare implicita/nesetata explicit)."
    		fi
    	elif [[ "$valoare" =~ $permis ]]; then 
    		if [[ "$valoare" =~ $recomandare ]]; then
    			echo "VALID: optiunea $key este conforma ($valoare)."
  		else
    			echo "VULNERABILITATE: optiunea \"$key $valoare\" prezinta risc de securitate (recomandat: $mesaj)."
  		fi	
  	elif [ "$potriviri" == 1 ]; then
  		echo "EROARE: optiunea \"$key $valoare\" este invalida."
  	fi
done




