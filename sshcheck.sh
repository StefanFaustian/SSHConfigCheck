#!/bin/bash

if [[ $# -ne 1 ]]; then		## Verificare ca apelul cu parametru este conform cerintei
	echo "Eroare: Apel de script invalid"
	exit 1
fi

fisier=$1

if [[ ! -e "$fisier" ]]; then		## Verificarea existentei fisierului de configurare
	echo "Eroare: Fisierul $fisier nu exista!"
	exit 1
fi

if [[ ! -r "$fisier" ]]; then		# Verificarea permisiunii de citire a fisierului de configurare
	echo "Eroare: Fisierul $fisier nu poate fi citit!"
	exit 1
fi




