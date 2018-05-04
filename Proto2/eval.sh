#!/bin/bash

devReference="dev-reference.txt"
testReference="dev-reference-test.txt"

evalReference(){
	if [ $# != 2 ]; then
	  echo "Please, provide exactly two arguments to this script"    
	  echo "Usage: eval.sh SYSTEM REFERENCE"
	  exit -1
	fi

	SYSTEM=$1
	REFERENCE=$2

	if [ ! -e $SYSTEM ]; then
	  echo "File $SYSTEM not found."
	  exit -1
	fi

	if [ ! -e $REFERENCE ]; then
	  echo "File $REFERENCE not found."
	  exit -1
	fi

	paste -d "\t" $SYSTEM $REFERENCE | 
	awk 'BEGIN{FS="\t"}{if($2==$1)tp++;c++}END{printf("Precision: %.2f%%\n", 100*tp/c)}'
}

if [ ! -e $testReference ];then
	for f in $(ls dev-vec/); do
		type=`./categorize.sh dev-vec/$f ${1}` 
		echo "${f//.vec} $type" >> $testReference
	done
	evalReference "$devReference" "$testReference"
else
	evalReference "$devReference" "$testReference"
fi
 
exit 0
