#!/bin/bash
devReference="dev-reference.txt"
trainDir="train-new"
ext=".txt"

createDevReference(){
	for f in $(ls dev/); do
		string=`cat dev/$f`
		if [[ $string == *+  ]];then
			echo "$f +" >> $devReference
		elif [[ $string == *=  ]];then
			echo "$f =" >> $devReference
		elif [[ $string == *-  ]];then
			echo "$f -" >> $devReference
		fi
	done
}

createTrainreference(){
	if [ ! -d  $trainDir ];then
		mkdir $trainDir
	fi
	
	for f in $(ls train/); do
		string=`cat train/$f`
		if [[ $string == *+  ]];then
			removeExt=${f%.txt}
			removeExt+="positif"
			removeExt+=$ext
			cp "train/$f" "$trainDir/$removeExt"
			echo "$f +"
		elif [[ $string == *=  ]];then
			removeExt=${f%.txt}
			removeExt+="neutre"
			removeExt+=$ext
			cp "train/$f" "$trainDir/$removeExt"
			echo "$f ="
		elif [[ $string == *-  ]];then
			removeExt=${f%.txt}
			removeExt+="negatif"
			removeExt+=$ext
			cp "train/$f" "$trainDir/$removeExt"
			echo "$f -"
		fi
	done
}

createDevReference
