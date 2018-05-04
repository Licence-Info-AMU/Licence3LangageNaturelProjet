#!/bin/bash


usage(){
	echo -e "usage: \t \"$0 <FLAG>\" \n\
	$0 h | help | u | usage : For help\n\
	<FLAG> :\n\
	\tdev     / for sent-dev.txt file    (use to test the development)\n\
	\ttest    / for sent-test.txt file   (use to final test)\n\
	\ttrain   / for sent-train.txt file  (use to train before the test)\n\
	"
}

#	$1=dirname
initialisedir(){
	[ -d "${1}" ] || mkdir "${1}"
}

if [ $# -ne 1 ]; then
	usage
	exit 1
fi
case $1 in
	h|u|help|usage)		usage
						exit 0;;
	dev|test|train)		element=$1;;
	*)					usage
						exit 1;;
esac
echo "sent-${element}.txt" >&2
initialisedir "${element}"
IFS=$'\n'
cpt=0
for i in `cat sent-${element}.txt` ; do
	((cpt++))
	echo "${i}" > "${element}/${cpt}.txt"
done
IFS=$' \t\n'
exit 0
