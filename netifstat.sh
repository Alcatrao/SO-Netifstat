#!/bin/bash

function dor {
set -e -o pipefail
if [ $? -ne 0 ] && [ $? -ne 1 ] && [ $? -ne 130 ]; then trap 'luz' EXIT; fi
}
dor 


function luz {
echo "Uso: ./netifstat.sh [OPÇÃO]... <SUFIXO>"
echo "Este script apresenta estatísticas sobre a quantidade de dados transmitidos e recebidos nas interfaces de rede detetadas no sistema."
echo "	Opções:"
echo "	-p <NÚMERO>	nº (máximo) de interfaces a visualizar"
echo "	-c <EXPRESSÃO>	filtragem das interfaces a serem visualizadas"
echo "	-v		mostrar resultados por ordem inversa"
echo "	-{b|k|m}	representar quantidades em bytes|kylobytes|megabytes"
echo "	-{t|r|T|R}	ordenar resultado por quantidade de dados transmitidos, recebidos, ou as respetivas taxas de transferência"
echo "	-l		execução em loop"
}



function sono {
ini=( $(cat /proc/net/dev | awk {'print $1, $2, $10'} | grep -v -i 'bytes\|receive') ) # | sort -n | grep $OPTARG
sleep $alienmir
fim=($(cat /proc/net/dev | grep -v -i 'bytes\|receive' | awk {'for(i=1;i<3;i++) print $i;print $10'})) # | sort -n
}



function UFO {
NETIF=()
RX=()
TX=()
RRATE=()
TRATE=()

#NETIF
for ((i=0; i<${#ini[@]}; i=i+3)); do
	NETIF+=(${ini[i]})
done

#RX
for ((i=1; i<${#ini[@]}; i=i+3)); do
	RX+=($((${fim[i]}-${ini[i]})))
done

#TX
for ((i=2; i<${#ini[@]}; i=i+3)); do
	TX+=($((${fim[i]}-${ini[i]})))
done

#RRATE	
for ((i=0; i<${#RX[@]}; i++)); do
	conta=$(echo "${RX[i]}, $alienmir" | awk '{printf "%.1f \n", $1/$2}')
	RRATE+=( $conta )
done	

#TRATE	
for ((i=0; i<${#TX[@]}; i++)); do
	conta=$(echo "${TX[i]}, $alienmir" | awk '{printf "%.1f \n", $1/$2}')
	TRATE+=( $conta )
done	
}



function apparate {
for (( i=0; i<${#NETIF[@]}; i++ )); do
	echo ""${NETIF[i]}"	"${TX[i]}"	"${RX[i]}"	"${TRATE[i]}"	"${RRATE[i]}""
done
}



function mau {
if [[ ${#ini[@]} -ne ${#fim[@]} ]]; then
	echo "Novos dispositivos na rede" 
	exit
fi
for ((i=0; i<${#ini[@]}; i=i+3)); do
	coisa=${ini[i]}; coisa=${coisa%?}
	cena=${fim[i]}; cena=${cena%?}
	if [[ $coisa -ne $cena ]]; then
		echo "Novas interfaces na rede"
		exit
	fi
done
}



flag_c=0
flag_c_arg="tee"
flag_bytes_arg='{print $0}'
flag_p=0
flag_p_arg="tee"
flag_ordem_arg="tee"
flag_v=0
flag_v_arg="tee"
flag_l=0

flag_ordem=0
flag_bytes=0

while getopts "c:bkmp:trTRvl" option; do
	case $option in
		c) #filtro de redes
		if [ $flag_c -eq 0 ]; then
			flag_c=1
			if [[ -z "${OPTARG// }" ]]; then #ver se o argumento não existe ou é vazio ou é espaço branco
				echo "Providencie um parâmetro à opção -c"
				exit 1
			fi
			flag_c_arg="grep -i ^.*$OPTARG.*[[:blank:]].*[[:blank:]].*[[:blank:]].*[[:blank:]]"
		else
			echo "Insira apenas 1 filtro de redes"
			exit 1
		fi
		;;
		
		b) #imprimir em bytes (default)
		if [[ $flag_bytes -eq 0 ]]; then
			flag_bytes=1
		else
			echo "Especifique apenas 1 parâmetro de quantidade para representar os bytes transferidos"
			exit 1
		fi
		;;
		
		k) #imprimir em kilobytes
		if [[ $flag_bytes -eq 0 ]]; then
			flag_bytes_arg=' { printf ( "%s\t", $1) ; for ( i=2 ; i<=NF; i++ )  printf ("%.1f\t", $i/=1024 ); print ""  } '
			flag_bytes=1
		else
			echo "Especifique apenas 1 parâmetro de quantidade para representar os bytes transferidos"
			exit 1
		fi
		;;
		
		m) #imprimir em megabytes
		if [[ $flag_bytes -eq 0 ]]; then
			flag_bytes_arg=' { printf ( "%s\t", $1) ; for ( i=2 ; i<=NF; i++ )  printf ("%.1f\t", $i/=1024*1024 ); print ""  } '
			flag_bytes=1
		else
			echo "Especifique apenas 1 parâmetro de quantidade para representar os bytes transferidos"
			exit 1
		fi		
		;;
		
		p) #imprimir até 'p' interfaces
		if [[ $flag_p -eq 0 ]]; then
			flag_p=1
			if [[ ! $OPTARG =~ ^[0-9]+$ ]]; then
				echo "Indique um número natural à opção -p"
				exit 1
			fi
			flag_p_arg="head -"$OPTARG" "
		else
			echo "Insira apenas 1 (ou nenhum) nº (limite máximo) de interfaces a serem visualizadas"
			exit 1
		fi		
		;;
		
		t) #ordenar segundo TX
		if [[ $flag_ordem -eq 0 ]]; then
			flag_ordem=1
			flag_ordem_arg="sort -k2 -n -r "
		else
			echo "Parâmetros de ordenação inválidos (especifique apenas 1 ordem, com ou sem inverso)"
			exit 1
		fi			
		;;
		
		r) #ordenar segundo RX
		if [[ $flag_ordem -eq 0 ]]; then
			flag_ordem=1
			flag_ordem_arg="sort -k3 -n -r "
		else
			echo "Parâmetros de ordenação inválidos (especifique apenas 1 ordem, com ou sem inverso)"
			exit 1
		fi	
		;;
		
		T) #ordenar segundo TRATE
		if [[ $flag_ordem -eq 0 ]]; then
			flag_ordem=1
			flag_ordem_arg="sort -k4 -n -r "
		else
			echo "Parâmetros de ordenação inválidos (especifique apenas 1 ordem, com ou sem inverso)"
			exit 1
		fi			
		;;
		
		R) #ordenar segundo RRATE
		if [[ $flag_ordem -eq 0 ]]; then
			flag_ordem=1
			flag_ordem_arg="sort -k5 -n -r"
		else
			echo "Parâmetros de ordenação inválidos (especifique apenas 1 ordem, com ou sem inverso)"
			exit 1
		fi	
		;;
		
		v) #ordenar ordem decrescente
		if [[ $flag_v -eq 0 ]]; then
			flag_v=1
			flag_v_arg=" tac "
		else
			echo "Parâmetros de ordenação inválidos (só pode reverter 1x)"
			exit 1
		fi	
		;;
		
		l) #loop
		if [[ $flag_l -eq 0 ]]; then
			flag_l=1
		else
			echo "Insira apenas um parâmetro de loop"
			exit 1
		fi		
		;;
		
		*)
		echo "Parâmetro inválido"
		luz
		exit 1
		;;
	esac
done

shift $((OPTIND-1)) #descarta as opções depois de serem processadas; ficam apenas os argumentos de entrada



alienmir=$1
if [[ ! $alienmir =~ ^[0-9]+$ ]] || [[ $# -ne 1 ]] || [[ $alienmir -eq 0 ]]; then
	echo "Insira um (só) argumento válido (número inteiro positivo)"
	exit 1
fi



if [[ $flag_l -eq 0 ]]; then
	sono
	mau
	UFO
	echo "NETIF	TX	RX	TRATE	RRATE"
	apparate | $flag_c_arg | awk "$flag_bytes_arg" | $flag_ordem_arg | $flag_v_arg | $flag_p_arg 2> /dev/null
	
else
while true; do

	sono
	mau
	UFO
	echo "NETIF	TX	RX	TRATE	RRATE	TXTOT	RXTOT"
	
	#TXTOT
	for ((i=0; i<${#TX[@]}; i++)); do
		TXTOT[i]=$(( ${TXTOT[i]}+${TX[i]}))
	done

	#RXTOT
	for ((i=0; i<${#TX[@]}; i++)); do
		RXTOT[i]=$(( ${RXTOT[i]}+${RX[i]} ))
	done

	for (( i=0; i<${#NETIF[@]}; i++ )); do
		echo ""${NETIF[i]}"	"${TX[i]}"	"${RX[i]}"	"${TRATE[i]}"	"${RRATE[i]}"	"${TXTOT[i]}"	"${RXTOT[i]}""
	done | $flag_c_arg | awk "$flag_bytes_arg" | $flag_ordem_arg | $flag_v_arg | $flag_p_arg
	
	echo ""
	
done
fi


