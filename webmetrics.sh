#!/bin/bash

file=$1

# Check if #arguments is not equal to 1
if [[ $# -ne 1 ]]
then
        echo -e "Error: No log file given.\nUsage: ./webmetrics.sh <logfile>"
        exit 1
fi

# Check if argument 1 is a file
if [[ ! -f $1 ]]
then
        echo -e "Error: File 'this_file_does_not_exist' does not exist.\nUsage: ./webmetrics.sh <logfile>"
        exit 1
fi

# Should I check how many occurences or how many lines contain a occurence?
echo "Number of requests per web browser"

numberOfSafaris=$(grep -o 'Safari' $file | wc -l)
numberOfFirefox=$(grep -o 'Firefox' $file | wc -l)
numberOfChrome=$(grep 'Chrome' $file | wc -l)

echo "Safari,$numberOfSafaris"
echo "Firefox,$numberOfFirefox"
echo "Chrome,$numberOfChrome"



echo -e "\nNumber of distinct users per day"

uniqueDates=$(grep -o -u -i "[0-9][0-9]/[a-z][a-z][a-z]/[0-9][0-9][0-9][0-9]" $file | sort -u )

for date in $uniqueDates
do
       awk -v pat="$date" '$0~pat { print $1 }' < $file > ipdates.txt
       echo "$date,$(sort -u ipdates.txt | wc -l)"
done
rm ipdates.txt


echo -e "\nTop 20 popular product requests"

grep -o 'GET /product/[0-9]*/' $file > requests.txt

grep -o '[0-9]*' requests.txt > productIDs.txt

productIDs=$(sort -u productIDs.txt)

touch popularRequests.txt
for id in $productIDs
do
	count=$(grep -w $id productIDs.txt | wc -l)
	echo "$id, $count" >> popularRequests.txt 
done

sort -b -k2 -n -r -k1 -n -r popularRequests.txt > sortedPopularRequests.txt

sed -r 's/\s+//g' sortedPopularRequests.txt > results.txt

head -n 20 results.txt

rm results.txt
rm requests.txt
rm productIDs.txt
rm popularRequests.txt
rm sortedPopularRequests.txt

exit 0
