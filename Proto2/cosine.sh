#!/bin/bash

result=`LC_ALL=C join ${1} ${2}`

sumAiBi=`echo "${result}" | awk 'BEGIN{FS=" ";OFS=" "; sum=0;}
NR>1{ sum += $2 * $3 }
END{print sum}'` 

sumNormAi=`awk 'BEGIN {FS=" ";OFS=" "; sum=0;}
			NR>0{sum += ($2 * $2)}
			END{print sqrt(sum)}' $1` 
			
sumNormBi=`awk 'BEGIN {FS=" ";OFS=" "; sum=0;}
			NR>1{sum += ($2 * $2)}
			END{print sqrt(sum)}' $2` 

if [[ $sumNormAi == 0 || $sumNormBi == 0 ]];then
	final=0
else
	final=$(echo "$sumAiBi / ($sumNormAi * $sumNormBi)" | bc -l)
fi 

echo -e "${final} ${1} ${2}" 

exit 0
