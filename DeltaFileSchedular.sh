# receivedHRISfile=`ls /var/Integration/HRIS/Inbound/FormDelta/HRIS__*.csv`
receivedHRISfile=HRIS__WABASH__WabashTuition_20210628.csv
for eachfile in $receivedHRISfile
do
   myFile=$eachfile
done

fileNmWithExt=${myFile/\.\//};

echo "Original Filename-->$fileNmWithExt"

sh DeltaFileGenerator.sh $fileNmWithExt
