#!/bin/bash

devReference="dev_reference.txt"
testReference="dev_reference_neutre.txt"

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

evalReference $1 $2