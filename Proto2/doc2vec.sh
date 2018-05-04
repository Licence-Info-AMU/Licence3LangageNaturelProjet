#!/bin/bash

occurences=`sed -e "s/[[:punct:]]//g" -e "s/http[^ \t]*//g" -e "s/[0-9][0-9]*[a-zA-Z]* //g" ${1} | grep -E "([^ ]+[ |$]+)|([ ]+[^ ]+)" -o | sort -f | uniq -c | grep -i -v -w -f stopwords.txt |
			sed -r 's/[ ]*([0-9]+) ([^ ]*) /\2 \1/g' | LC_ALL=C sort`

echo -e "${occurences}"			

exit 0
