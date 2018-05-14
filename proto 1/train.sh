#!/bin/bash

stop_word_file="stopwords.txt"
stop_word_sed="stopwords.sed"
file_all_word="word.txt"
file_all_word_uniq="word_uniq.txt"
file_all_word_neg="word_neg.txt"
file_all_word_neu="word_neu.txt"
file_all_word_pos="word_pos.txt"
file_polarization_neg="word_polarization_neg.txt"
file_polarization_neu="word_polarization_neu.txt"
file_polarization_pos="word_polarization_pos.txt"
file_word_polarity="word_polarity.txt"


build_stop_word_sed(){
	echo "build_stop_word_sed"
	local i
	echo -n "" > $stop_word_sed
	IFS=$'\n'
	for i in `cat $stop_word_file` ; do
		echo "s/  *$i  */ /gI" >> $stop_word_sed
	done
	IFS=$' \t\n'
}

# remove_stop_word(){		#version non optimiser avec plein de sed a la suite
# 	sed -s -i -f $stop_word_sed truc/*.txt
# 	for file_name in $dir_name/*.txt ;do
# 		sed -i "s/^/ /" ${file_name}
# 		sed -i "s/$/ /" ${file_name}
# 	done
# 	for stop_word in `cat $stop_word_file` ;do
# 		for file_name in $dir_name/*.txt ;do
# 			sed -i "s/  *${stop_word}  */ /g" ${file_name}
# 		done
# 	done
# }

# remove_stop_word(){		#version d'esssai avec grep
# 	for file_name in $dir_name/*.txt ;do
# 		grep -i -F -w -v -f $stop_word_file $file_name
# 	done
# }

remove_anoying_thing(){
	echo "remove_anoying_thing $dir_name"
	# sed -s -i -e "s/ http[^ \t]*//g;s/ #[^ \t]*//g;s/ @[^ \t]*//g" $dir_name/*.txt			#enlever les url (http) # et citation (@)
	sed -s -i -e "s/ http[^ \t]*//g" $dir_name/*.txt			#enlever les url (http)
	sed -s -i -e "s/\.\.\./ /g;s/[][…≠“”¥→⁰°ã©¨€²!\"$%&'()*,./:;«»’<>?\\^_\`{|}~ ]/ /g;s/\([+=-]\)/ \1 /g;s/ [@#] / /g;s/ [0-9][0-9]* / /g;s/ [a-zA-Z] / /g;s/^/ /;s/$/ /;s/  */ /g;s/ $//;s/^ //" $dir_name/*.txt
}

remove_stop_word(){		#version plus lisible avec pré traitement puis enlevement des stop word puis post traitement puis posttraitement
	build_stop_word_sed
	echo "remove_stop_word $dir_name"
	sed -s -i -e 's/$/ /;s/^/ /' $dir_name/*.txt
	sed -s -i -f "$stop_word_sed" $dir_name/*.txt
	sed -s -i -e 's/ $//;s/^ //' $dir_name/*.txt
}

build_word_polarity(){
	echo "build_word_polarity"
	local i word neg neu pos
	for i in `cat $file_all_word_uniq` ;do
		word=${i%%    *}
		neg=`sed -n "s/^ *\([0-9][0-9]*\) ${word}$/\1/p" $file_polarization_neg`
		[ "$neg" == "" ] && neg=0
		neu=`sed -n "s/^ *\([0-9][0-9]*\) ${word}$/\1/p" $file_polarization_neu`
		[ "$neu" == "" ] && neu=0
		pos=`sed -n "s/^ *\([0-9][0-9]*\) ${word}$/\1/p" $file_polarization_pos`
		[ "$pos" == "" ] && pos=0
		echo -e "$neg\t$neu\t$pos\t    $word" >> $file_word_polarity
	done
}

build_word_polarization(){
	dir_name="train"
	remove_anoying_thing
	#remove_stop_word
	echo "build_word_polarization"
	local file_name i polarity file_word_polarized
	touch $file_all_word
	touch $file_all_word_neg
	touch $file_all_word_pos
	touch $file_all_word_neu
	for file_name in $dir_name/*.txt ;do
		polarity=`sed -e "s/.*\t \([+=-]\)$/\1/g" ${file_name}`
		case $polarity in
			=)	file_word_polarized=$file_all_word_neu;;
			+)	file_word_polarized=$file_all_word_pos;;
			-)	file_word_polarized=$file_all_word_neg;;
			*)	echo "bad file ${file_name}"
				exit 1;;
		esac
		for i in `cat $file_name`; do
			if [ "$i" == "+" ] || [ "$i" == "=" ] || [ "$i" == "-" ]; then
				continue
			fi
			echo "${i,,}" >> $file_word_polarized
			echo "${i,,}" >> $file_all_word
		done
	done
	sort -u $file_all_word -o $file_all_word_uniq
	sort $file_all_word_neg -o $file_all_word_neg
	sort $file_all_word_neu -o $file_all_word_neu
	sort $file_all_word_pos -o $file_all_word_pos
	uniq -c $file_all_word_neg > $file_polarization_neg
	uniq -c $file_all_word_neu > $file_polarization_neu
	uniq -c $file_all_word_pos > $file_polarization_pos
	build_word_polarity
}

build_tweet_polarization(){
	dir_name="$1"
	sed -s -i -e "s/[+=-]//g" $dir_name/*.txt
	remove_anoying_thing
	remove_stop_word
	echo "build_tweet_polarization"
	local file_name
	for file_name in $dir_name/*.txt ;do
		local neg=0 neu=0 pos=0
		for i in `cat $file_name`; do
			local polarity word_polarity
			grep -i -q "    ${i}$" "$file_word_polarity"
			tmp=$?
			[ $tmp -eq 2 ] && echo -n "c'est ok tkt" && sleep 1 && grep -i -q "    ${i}$" "$file_word_polarity" && tmp=$? && echo " $tmp"
			if [ $tmp -eq 0 ]; then
				polarity=`sed -n "s/^\([0-9][0-9]*\t[0-9][0-9]*\t[0-9][0-9]*\)\t    ${i,,}$/\1/p" "$file_word_polarity"`
				word_polarity=($polarity)
				((neg+=word_polarity[0]))
				((neu+=word_polarity[1]))
				((pos+=word_polarity[2]))
			 elif [ $tmp -eq 1 ]; then
			 	continue
			# 	echo -e "polarité ${i,,} inconue"
			else
				echo "$tmp ${i}$file_name"
			fi
		done
		((neu=neu*100))
		((neu=neu/100))
		echo -e "$pos + \t $neg - \t $neu = \t$file_name "
		if [ $neg -gt $neu ] && [ $neg -gt $pos ] ; then
			sed -i "s/$/\t${neg}- ${neu}= ${pos}+\t-/" $file_name
		elif [ $pos -gt $neu ] && [ $pos -gt $neg ] ; then	
			sed -i "s/$/\t${neg}- ${neu}= ${pos}+\t+/" $file_name
		else
			sed -i "s/$/\t${neg}- ${neu}= ${pos}+\t=/" $file_name
		fi
	done
}

createDevReference(){
	eval_reference="eval_$1.txt"
	[ -f $eval_reference ] && rm $eval_reference
	for f in $1/*.txt; do
		string=`cat "$f"`
		if [[ $string == *+  ]];then
			echo "${f##*/} +" >> $eval_reference
		elif [[ $string == *=  ]];then
			echo "${f##*/} =" >> $eval_reference
		elif [[ $string == *-  ]];then
			echo "${f##*/} -" >> $eval_reference
		fi
	done
}

./detach.sh dev

#build_word_polarization
build_tweet_polarization dev
createDevReference dev

./eval.sh eval_reference_dev.txt eval_dev.txt 


exit 0