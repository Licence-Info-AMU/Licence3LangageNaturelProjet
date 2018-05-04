#!/bin/bash
#database="database.csv"
database="database-test.csv"

createDatabase(){
	if [ ! -e  $database ];then
		echo -e "word,positif,neutre,negatif,total" >> $database
	fi
}

#${1} word ${2} polarity
addWordToDatabase(){
	searchOnDatabase "${1}"
	search=$?
	if [[ $search == 0 ]];then 
		if [[ "${2}" == "+" ]];then
			echo -e "${1},1,0,0,1" >> $database
		elif [[ "${2}" == "=" ]];then
			echo -e "${1},0,1,0,1" >> $database
		elif [[ "${2}" == "-" ]];then
			echo -e "${1},0,0,1,1" >> $database
		fi
	fi
}

#${1} word ${2} polarity
modifyWordInDatabase(){
	word="$1"
	searchOnDatabase "${1}"
	search=$?
	if [[ $search == 1 ]];then 
		if [[ "${2}" == "+" ]];then
			#awk -F, 'BEGIN{OFS=","}{if ($1 == $word) $2 = $2 + 1; $5 = $5 + 1; print}' $database > tmp.csv		
			declare -a array
			# Store the original input field separator
			OLD_IFS=$IFS
			while read line
			do
				# Load the comma separated fields into array
				IFS=','
				array=(`echo "$line"`)
				# Do arithmetics on 2 and 3 element
				if [[ ${array[0]} == $word ]] ; then
					array[1]=$((${array[1]} + 1))
					# Print a "comma separated" array
					array[4]=$((${array[4]} + 1))
					# Print a "comma separated" array
				fi
				printf "%s," ${array[@]} | sed 's/,$//'
				echo
			done < $database > "tmp.csv"
			# Restore the original input field separator
			IFS=$OLD_IFS
			
		elif [[ "${2}" == "=" ]];then
			#awk -F, 'BEGIN{OFS=","}{if ($1 == $word){ $3 += 1; $5 += 1; }print}' $database > tmp.csv
			declare -a array
			# Store the original input field separator
			OLD_IFS=$IFS
			while read line
			do
				# Load the comma separated fields into array
				IFS=','
				array=(`echo "$line"`)
				# Do arithmetics on 2 and 3 element
				if [[ ${array[0]} == $word ]] ; then
					array[2]=$((${array[2]} + 1))
					# Print a "comma separated" array
					array[4]=$((${array[4]} + 1))
					# Print a "comma separated" array
				fi
				printf "%s," ${array[@]} | sed 's/,$//'
				echo
			done < $database > "tmp.csv"
			# Restore the original input field separator
			IFS=$OLD_IFS
		elif [[ "${2}" == "-" ]];then
			#awk -F, 'BEGIN{OFS=","}{if ($1 == $word){ $4 += 1; $5 += 1; }print}' $database > tmp.csv
			declare -a array
			# Store the original input field separator
			OLD_IFS=$IFS
			while read line
			do
				# Load the comma separated fields into array
				IFS=','
				array=(`echo "$line"`)
				# Do arithmetics on 2 and 3 element
				if [[ ${array[0]} == $word ]] ; then
					array[3]=$((${array[3]} + 1))
					# Print a "comma separated" array
					array[4]=$((${array[4]} + 1))
					# Print a "comma separated" array
				fi
				printf "%s," ${array[@]} | sed 's/,$//'
				echo
			done < $database > "tmp.csv"
			# Restore the original input field separator
			IFS=$OLD_IFS
		fi
	fi
	mv "tmp.csv" $database
}

#${1} word
searchOnDatabase(){
	OLDIFS=$IFS
	IFS=,
	found=0
	{
		read
		while read -r col1 coll2 coll3 coll4 coll5;do
			if [ "${1}" == "$col1" ];then
				found=1
			fi
		done 
	} < $database
	IFS=$OLDIFS
	return $found
}

#${1} word
getStatsByWord(){
	OLDIFS=$IFS
	IFS=,
	while read -r col1 coll2 coll3 coll4 coll5;do
		if [ "${1}" == "$col1" ];then
			echo "$coll2 $coll3 $coll4 $coll5"
		fi
	done < $database
	IFS=$OLDIFS
}

learnNewWord(){
	for f in $(ls train-new-vec/); do
		polarity=${f//[[:digit:]]/}
		polarity=${polarity//.txt.vec/}
		while read -r word ; do
			searchOnDatabase "$word"
			search=$?
			if [[ $search == 1 ]];then
				if [[ $polarity == "positif" ]];then
					modifyWordInDatabase "$word" "+"
				elif [[ $polarity == "neutre" ]];then
					modifyWordInDatabase "$word" "="
				elif [[ $polarity == "negatif" ]];then
					modifyWordInDatabase "$word" "-"
				fi
			elif [[ $search == 0 ]];then
				if [[ $polarity == "positif" ]];then
					addWordToDatabase "$word" "+"
				elif [[ $polarity == "neutre" ]];then
					addWordToDatabase "$word" "="
				elif [[ $polarity == "negatif" ]];then
					addWordToDatabase "$word" "-"
				fi
			fi
		done < <(cat "train-new-vec/$f" | sed "s/[0-9]*//g" | grep -E "([^ ]+[ |$]+)|([ ]+[^ ]+)" -o)
	done
}

#createDatabase
#learnNewWord


addWordToDatabase "mars" "="
addWordToDatabase "départementales" "="
addWordToDatabase "auront" "="
addWordToDatabase "activement" "="
addWordToDatabase "lieu" "="
addWordToDatabase "élections" "="
addWordToDatabase "prépare" "="

modifyWordInDatabase "mars" "="
modifyWordInDatabase "départementales" "="
modifyWordInDatabase "auront" "="
modifyWordInDatabase "activement" "="
modifyWordInDatabase "lieu" "="
modifyWordInDatabase "élections" "="
modifyWordInDatabase "prépare" "="

echo $(getStatsByWord "mars")
echo $(getStatsByWord "départementales")
echo $(getStatsByWord "auront")
echo $(getStatsByWord "activement")
echo $(getStatsByWord "lieu")
echo $(getStatsByWord "élections")
echo $(getStatsByWord "prépare")
