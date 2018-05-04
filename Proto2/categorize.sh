#!/bin/bash
. database.sh
k=$2
result=""

if [ -z $2 ] 
then
	k=10
fi

for f in `ls train-new-vec/`; do
	result+=`./cosine.sh $1 train-new-vec/$f`
	result+="\n";
done
result=`echo -e $result | sort -r | head -n $k`
echo -e "$result" > temp.txt
echo -e `sed -E 's/.*train-new-vec\/[0-9]+([a-zA-Z]+).txt.vec.*/\1/g' temp.txt | sort` > temp.txt
positif=`grep -o 'positif' temp.txt | wc -l`
neutre=`grep -o 'neutre' temp.txt | wc -l`
negatif=`grep -o 'negatif' temp.txt | wc -l`

if [ $negatif -gt $positif ] && [ $negatif -gt $neutre ];then
	echo "-"
elif [ $positif -gt $negatif ] && [ $positif -gt $neutre ];then
	echo "+"
elif [ $neutre -gt $positif ] && [ $neutre -gt $negatif ];then
	echo "="
else
	positifStats=0
	neutreStats=0
	negatifStats=0
	while read -r word ; do
		searchOnDatabase "$word"
		search=$?
		if [[ $search == 1 ]];then
			var=$(getStatsByWord "$word")
			stringarray=($var)
			positif=${stringarray[0]}
			neutre=${stringarray[1]}
			negatif=${stringarray[2]}
			total=${stringarray[3]}

			positifStats=$(echo "$positifStats + ($positif/$total)" |bc -l)
			neutreStats=$(echo "$neutreStats + ($neutre/$total)" |bc -l)
			negatifStats=$(echo "$negatifStats + ($negatif/$total)" |bc -l)
		fi
	done < <(cat "${1}" | sed "s/[0-9]*//g" | grep -E "([^ ]+[ |$]+)|([ ]+[^ ]+)" -o)

	if [[ $positifStats > $neutreStats ]] && [[ $positifStats > $negatifStats ]];then
		echo "+"
	elif [[ $neutreStats > $neutreStats ]] && [[ $positifStats > $negatifStats ]];then
		echo "="
	elif [[ $negatifStats > $neutreStats ]] && [[ $negatifStats > $positifStats ]];then
		echo "-"
	else
		echo "?"
	fi
fi

rm temp.txt

exit 0
