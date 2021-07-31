#!/bin/bash

# csv1=/var/Integration/HRIS/Inbound/FormDelta/HRIS__WABASH__Delta_Test.csv
# csv1=HRIS__WABASH__WabashTuition_20210604.csv

csv1=$1
# csv2=/var/Integration/HRIS/Inbound/FormDelta/ContactsFromSalesforce_2021-Jun-28_134116.csv
csv2=ContactsFromSalesforce_2021-Jul-6_151215.csv

# csv2=ContactsFromSalesforce.csv

echo "received fileName-->$1"

# replace ".csv" in incoming file's name and replace it with "_DELTA.csv" to form the name of file to write delta
deltaFileName=${1/\.csv/_DELTA\.csv}


echo "FILE HEADER" > $deltaFileName;

while read line; do
    echo "************************************"
    # Read all row except the first one(i.e. the one that has FirstName keyword in it)
    if [[ "$line" != *"FirstName"* ]]; then
        echo "Line being read:--> $line"

        # Replace delimiter "," i.e. double quote - comma - double quote with colon(:) for simpler parsing later
        myLine=`echo ${line//\"\,\"/:}`
        echo "myLine-->$myLine"

        # Split each row(i.e. myLine) with delimiter and store it in an array(.i.e currRow)
        IFS=':'
        read -ra currRow <<< "$myLine"

        # Store 'company email' of current row in a varibale
        compEmail=${currRow[4]}
        echo "Email is --> $compEmail";
        emailLen=`echo $compEmail | wc -m`

        # Only process those HRIS records that has Company Email on them
        if [ $emailLen -gt 1 ]; then
            #Check if company email exist in SF export
            result=$(grep -i $compEmail "$csv2")
            if [ $? -eq 0 ]; then
                echo "Matching email found for $compEmail"

                # Unformat the work phone number(if its provided)
                phNo=${currRow[5]}
                phNoLen=`echo $phNo | wc -m`
                if [ $emailLen -gt 1 ]; then
                    phNo=`echo ${phNo//-/ }`
                    $phNo=`echo ${phNo// /}`
                    phNo=`echo ${phNo//(/}`
                    phNo=`echo ${phNo//)/}`
                fi
                echo "Unformatted Phone Number --> $phNo";

                #Check if entire employee record matches with SF data
                currentRow="${currRow[0]}\",\"${currRow[1]}\",\"${currRow[2]}\",\"${currRow[3]}\",\"${currRow[4]}\",\"$phNo\",\"${currRow[6]}\",\"${currRow[7]}\",\"${currRow[8]}\",\"${currRow[9]}\",\"${currRow[10]}\",\"${currRow[11]}\",\"${currRow[12]}\",\"${currRow[13]}\",\"${currRow[14]}\",\"${currRow[15]}\",\"${currRow[16]}\",\"${currRow[17]}\",\"${currRow[18]}\",\"${currRow[19]}\""

                #rowMatchResult=$(grep -q $line "$csv2");

                prefFNameLen=`echo ${currRow[2]} | wc -m`
                prefLNameLen=`echo ${currRow[3]} | wc -m`

                # Perform GREP with SF file based on whether Preferred FirstName and Preferred LastName has value in it or not. If there is no value in those(one or both) fields, exclude them while doing grep.
                if [ $prefFNameLen -le 1 ]; then
                    echo "${currRow[4]} has EMPTY Pref FirstName"
                    currentRow="${currRow[0]}\",\"${currRow[1]}\",\".*\",\"${currRow[3]}\",\"${currRow[4]}\",\"${currRow[5]}\",\"${currRow[6]}\",\"${currRow[7]}\",\"${currRow[8]}\",\"${currRow[9]}\",\"${currRow[10]}\",\"${currRow[11]}\",\"${currRow[12]}\",\"${currRow[13]}\",\"${currRow[14]}\",\"${currRow[15]}\",\"${currRow[16]}\",\"${currRow[17]}\",\"${currRow[18]}\",\"${currRow[19]}\""
                    if [ $prefLNameLen -le 1 ]; then
                        echo "${currRow[4]} has EMPTY lastName"
                        currentRow="${currRow[0]}\",\"${currRow[1]}\",\".*\",\"${currRow[4]}\",\"${currRow[5]}\",\"${currRow[6]}\",\"${currRow[7]}\",\"${currRow[8]}\",\"${currRow[9]}\",\"${currRow[10]}\",\"${currRow[11]}\",\"${currRow[12]}\",\"${currRow[13]}\",\"${currRow[14]}\",\"${currRow[15]}\",\"${currRow[16]}\",\"${currRow[17]}\",\"${currRow[18]}\",\"${currRow[19]}\""
                    fi
                else
                    if [ $prefLNameLen -le 1 ]; then
                        echo "${currRow[4]} has FirstName but EMPTY lastName"
                        currentRow="${currRow[0]}\",\"${currRow[1]}\",\"${currRow[2]}\",\".*\",\"${currRow[4]}\",\"${currRow[5]}\",\"${currRow[6]}\",\"${currRow[7]}\",\"${currRow[8]}\",\"${currRow[9]}\",\"${currRow[10]}\",\"${currRow[11]}\",\"${currRow[12]}\",\"${currRow[13]}\",\"${currRow[14]}\",\"${currRow[15]}\",\"${currRow[16]}\",\"${currRow[17]}\",\"${currRow[18]}\",\"${currRow[19]}\""
                    fi
                fi

                currRowLen=`echo ${currentRow} | wc -m`
                echo "Current row length-->$currRowLen"

                echo "currentRow from grep in SF--$currentRow"
                grep -i $currentRow "$csv2"
                if [ $? -eq 0 ]; then
                    echo "Exact match found for {$compEmail}";
                else
                    echo "Email found but no excat match";
                    echo "$line" >> $deltaFileName
                fi
            else
                echo "No match found. Write to delta file"
                echo "$line" >> $deltaFileName
            fi
        fi
    fi

    # Reset the delimiter
    IFS=''
done < "$csv1"
