#! bin/bash
read -p "DID(UPPER CASE)=" DID
read -p "date_year=" date_year
read -p "week=" week

while IFS=" " read -r y1 y2 y3;
do 

	cp /vol/pye/MTI/OPS/$DID/$date_year$week/DATA/$y1/FAB$y2/X$y3/SDP/FIRST_PASS/SUMMARIES $DID-fab$y2-$y1-x$y3-SDP-ww$week

	echo Step=$y1 Fab=$y2 Configuration_Width=$y3 > temp_header
	echo "MPPR" "MPPR_Amount" "MPPR_Percentage(%)" "WAVE_ID" "WAVE_ID_Amount" "WAVE_ID_Percentage(%)" > temp_header_1

	tsums @$DID-fab$y2-$y1-x$y3-SDP-ww$week -format=MAJOR_PROBE_PROG_REV | sort | uniq -c  > temp_1

	cat temp_1 | awk '{b[$2]=$1;sum=sum+$1} END{for (i in b) print i,b[i],(b[i]/sum)*100}' | sort -n | sed 's/$/ /' > temp_11

	tsums @$DID-fab$y2-$y1-x$y3-SDP-ww$week -format=RETICLE_WAVE_ID | sort | uniq -c  > temp_2

	cat temp_2 | awk '{b[$2]=$1;sum=sum+$1} END{for (i in b) print i,b[i],(b[i]/sum)*100}' | sort -n > temp_22

	paste temp_11 temp_22 > temp_3

	cat temp_header temp_header_1 temp_3 > $DID-fab$y2-$y1-x$y3-SDP-ww$week.txt

	rm $DID-fab$y2-$y1-x$y3-SDP-ww$week

done < var

rm temp_1 temp_2 temp_3
rm temp_11 temp_22
rm temp_header temp_header_1

for f in *.txt;
do 
	cat *.txt | sed 's/ /,/g' > $DID-opsdata_$date_year$week.csv; 
done;

rm *.txt
