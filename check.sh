#!/bin/bash

if [ $# -ne 2 -a $# -ne 3 ]
then
	echo "usage: check program_name tests_folder [time_limit]"
	exit 1
fi

PROGRAM_NAME=$1
OUT_FILE=$PROGRAM_NAME.out
TEST_FOLDER=$2
IN_FOLDER="$TEST_FOLDER/in"
OUT_FOLDER="$TEST_FOLDER/out"
if [ $# -eq 2 ]
then
	TIME_LIMIT=0
else
	TIME_LIMIT=$3
fi

GREEN_COLOR="\033[0;32m"
YELLOW_COLOR="\033[1;33m"
RED_COLOR="\033[0;31m"
NO_COLOR="\033[0;m"

if !(g++ -O3 -static $PROGRAM_NAME.cpp -std=c++17 -o $PROGRAM_NAME)
then
	echo -e "${RED_COLOR}[COMPILATION ERROR]${NO_COLOR}"
	exit 1
fi

STATUS_OK=1
for test_in in $IN_FOLDER/*.in
do
	test_name=$(basename "$test_in" .in)
	test_out="$OUT_FOLDER/$test_name.out"

	if !(timeout $TIME_LIMIT ./$PROGRAM_NAME < $test_in > $OUT_FILE)
	then
		echo -e "$test_name\t${YELLOW_COLOR}[TIME LIMIT EXCEED]${NO_COLOR}"
		STATUS_OK=0
		break
	fi

	if !(diff -w $PROGRAM_NAME.out $test_out)
	 then
		echo -e "$test_name\t${RED_COLOR}[WRONG ANSWER]${NO_COLOR}"
		STATUS_OK=0
		break
	fi

	echo -e "$test_name\t${GREEN_COLOR}[OK]${NO_COLOR}"
done

rm $OUT_FILE
if [ $STATUS_OK -eq 0 ]
then
	exit 1
fi
