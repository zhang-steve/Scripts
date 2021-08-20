#!bin/bash
read -p "dbase=?" ddbase

filename=${ddbase:-"filename"}
date1=$(date +%Y'_'%m'_'%d'_'%H':'%M':'%S)
date_year=$(date +%Y)
month=$(date +%m)
fisrt=$(echo ${month:0:1})
second=$(echo ${month:1:2})
if [[ $first -eq 1 ]]; then
    date_month=$(echo ${month:0:2})
else
    date_month=$(echo ${month:1:2})
fi


date_day=$(date +%d)
a=0

if [ $(($date_year % 4)) -eq 0 -a $(($date_year % 100)) -ne 0 ]; then
	a=1
elif [ $(($date_year % 400)) -eq 0 ]; then
	a=1
else
	a=2
fi
sum=0
a=(31 28 31 30 31 30 31 31 30 31 30 31)
b=(31 29 31 30 31 30 31 31 30 31 30 31)
if [ $a -eq 1 ]; then
	for ((i = 0 ; i < $date_month ; i++))
	do
		sum=$(($sum + b[i]))
	done
else
	for ((i = 0 ; i < $date_month -1 ; i++))
	do
		sum=$(($sum + a[i]))
	done
fi
sum=$(($sum + $date_day))
week=$(($sum / 7))
workweek=$date_year$week


#取得行數
line=$(tsums  -dbase=$ddbase -all -step=pgsrt,hsrt,cfin -mfg_workweek=$workweek -standard_flow=yes -format=step,configuration_width,'sum(uin)' |awk 'END {print NR}')
name=${ddbase}${workweek}
mkdir $name
cd $name

for ((i = 1 ; i <= $line ; i++))
do
	step=$(tsums -dbase=$ddbase -all -step=pgsrt,hsrt,cfin -mfg_workweek=$workweek -standard_flow=yes -format=step,configuration_width,'sum(uin)'\
 |sort -t ' '  -r -n -k1 |sed -n $i'p'| cut -c 1-5 |sed s/[[:space:]]//g )

	config=$(tsums  -dbase=$ddbase  -all -step=pgsrt,hsrt,cfin -mfg_workweek=$workweek -standard_flow=yes -format=step,configuration_width,'sum(uin)'\
 |sort -t ' '  -r -n -k1 |sed -n $i'p'| cut -c 6-9 |sed s/[[:space:]]//g)
	file="${filename}${date1}_${step}_${config}"
	frpt -all -dbase=$ddbase -step=$step \
 -hurl=/dread,eng,char/  -standard_flow=yes +regwidth -xtu +debug +# +mesh  -quick=/configuration_width/ -configuration_width=$config -mfg_workweek=$workweek -sort=// +nowrap +echo  >| $file
	tail -n +12 $file >| tempfile
	temp=$(grep -n  "$config" tempfile   |head -n 1 | awk '{print $2" yield:" $6"% " }  ')
	#判斷是否良率為100%
	if [ ${temp%.*} -eq "00" ]; then
		file=yield_${file}		
	fi
	temp2=$(echo "$step $config qty=" $temp)
	#查詢register name在哪行
	temp3=$(grep -n  "Register Name" tempfile |cut -c 1-2 )
	temp3=+$(($temp3+2))

	tail -n $temp3  tempfile | head -n 3 >| tempfile2
	while IFS=" "  read -r con1 con2 con3 con4 con5
	do
		echo register name: "$con1" ,"$con3"%  TTE:"$con2"  Uni:"$con4"
	done <  tempfile2  >| tmp
	echo $temp2
	cat tmp
	echo "----------------------------------------------"
	rm tmp
	rm tempfile
	rm tempfile2

done > $name

