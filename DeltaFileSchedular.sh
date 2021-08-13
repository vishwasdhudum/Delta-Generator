# receivedHRISfile=`ls /var/Integration/HRIS/Inbound/FormDelta/HRIS__*.csv`

receivedHRISfile=/Users/vdhudum/Documents/HRIS__WABASH__WabashTuition_20210628.csv
# receivedHRISfile=/Users/vdhudum/Documents/HRIS__WILEY__WBP_2021-07-26.csv

for eachfile in $receivedHRISfile
do
   myFile=$eachfile
done

fileNmWithExt=${myFile/\.\//};

echo "Original Filename-->$fileNmWithExt"

sh DeltaFileGenerator.sh $fileNmWithExt
