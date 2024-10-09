#!/bin/bash
# -> El signo de dólar se usa para referenciar el valor almacenado en una variable

ip_ingresada=$1 # -> Primer argumento ingresado

# <-------------------- Verificación de privilegios --------------------> #
if [[ $EUID -ne 0 ]]; then
    echo "Este script debe ser ejecutado como root. Usa 'sudo'." 
    exit 1
fi

#<-------------------- Chequeo de instalacion de Nmap --------------------># 

test -f /usr/bin/nmap

if [ $? -eq 0 ]; then # -> Alternativa: "$(echo $?)" == 0
    echo "Nmap ya esta instalado"
else
    echo "Nmap no esta instalado" && 
    sudo apt update > /dev/null && # -> La ruta es para tirar el resultado a la basura de Linux
    sudo apt install nmap -y  > /dev/null
fi

#<-------------------- Escaneo de SO --------------------># 

ping -c 1 $ip_ingresada > ping.log

for i in $(seq 60 70) $(seq 100 200); do
    valor_ttl=$(grep -oP '(?<=ttl=)\d+' ping.log)

    if [ "$i" -le 70 ] && [ "$valor_ttl" -eq "$i" ]; then
        echo "La maquina usa un SO Linux" 
        break
    fi

    if [ "$i" -ge 100 ] && [ "$valor_ttl" -eq "$i" ]; then
        echo "La maquina usa un SO Windows"
        break
    fi
done

rm ping.log

#<-------------------- Escaneo con Nmap --------------------># 

nmap -p 1-65535 -sV -sC --open -sS -n -Pn $ip_ingresada -oN resultado_escaneo


# Alternativa para chequear si Nmap esta instalado: 

# if command -v nmap > /dev/null; then
#     echo "Nmap ya está instalado"
# else
#     echo "Nmap no está instalado, instalando ahora..." && 
#     sudo apt update > /dev/null && 
#     sudo apt install nmap -y  > /dev/null
# fi