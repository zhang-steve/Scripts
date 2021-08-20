#! bin/bash
read -p "samereg=" samereg
read -p "configuration_width=" cw
read -p "dbase=" dbase
read -p "step=" step
read -p "RETICLE_WAVE_ID=" waveid

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
file=$date1
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

#while true
#do
#	read -p "configuration_width=" cw
#	case $cw in 
#			"x4"|"x8"|"X4"|"X8")
#		exit 1
#		;;
#
#		*)
#			echo "invalid input..."
#		;;
#	esac
#done

#q=$(($week % 7))
#if [ $q != 0 ]; then
#	week=$(($sum / 7))
#else
#	week=$(($sum / 7 -  1))
#fi

#a="ba =2 "
#b="ba=2"
#c=$(echo " $a" | sed "s/ //g")
#if [ "$c" == "$b" ]; then
#	echo "good"
#
#else
#	echo "bad"
#fi

frpt -all -dbase=$dbase -step=$step +debug +regwidth -xtu -hurl=/dread,char,eng/  +mesh -standard_flow=yes -tot +crop -sort=// +echo +nowrap\
 -mfg_workweek=$workweek -configuration_width=$cw -RETICLE_WAVE_ID=$waveid -samereg=/$samereg/ >| 1545
tail -n +2 1545  >| 15451
##判斷最後一行在哪
#temp =$(15451 |tail -n 1) 
temp=$(grep -n $samereg  15451 |cut -c 1-2  )
temp1=$(($temp - 2))
con=$(sed -n $temp'p' 15451 )

echo "reg:" $samereg >> lot
echo "configuration_width:" $cw >> lot
echo "dbase:" $dbase >> lot
echo "step:" $step >> lot
echo "RETICLE_WAVE_ID=" $waveid >> lot
##目標字串
#target="3"
###依空格分隔字元
#case "$target" in
#	[0-9]*)
#		echo "good"
#		;;
#	*)
#		echo "bad"
#		;;
#esac
#for  ((c =  1 ; c < $(($con - 3)) ; c++ ));do	
#找slash_lot
#for c in $con;do
#	
#	const=$(echo $c |sed "s/ //g")	
#	 
#	
#	if [ "$const" -gt 0 ] 2>/dev/null; then
		
#		name=$(sed -n $temp1'p' 15451 |awk   '{print $test}' test="$ab" |sed  "s/ //g")		
#		if [ "$name" == "$TTE" ] || [ "$name" != "$Unique" ]; then 
#			echo $name
#		fi
#	fi
#   ((ab ++))
#done >|1548 

#記錄欄數
j=2
#Unique="Unique"

#判斷每個批lot是否有值
for c in $con;do

        const=$(echo $c |sed "s/ //g")
        if [ "$j" -gt 6 ]; then #從第五個元素開始判
                if [ "$const" -gt 0 ] 2>/dev/null; then
                        sed -n $temp1'p' 15451 |awk   '{print $x}' x="$j"
                fi
        fi

#       echo $j
        ((j++))
done >| 1548


i=0
array=
while read line
do
   
	array[$i]=$line
    ((i++))
done < 1548 
#如果array內有存TTE 和UNIQUE資訊remove掉
array=( ${array[*]/TTE} )
array=( ${array[*]/Unique} )

for value in ${array[@]}
do
	echo "slash_lot=" $value >> lot
	#算空格有幾行
	num=$(tsums -c $value | grep "8 HSRT FAIL" | head -n 1 | sed 's/\s\+/ /g' |wc -w)
	#child_lot在倒數第二格
	num=$(($num- 2 ))
	tsums -c $value | grep "8 HSRT FAIL" | head -n 1 | sed 's/\s\+/ /g' |cut -d ' ' -f $num >> lot
	echo "fid=">> lot
	#重複的fid remove掉
	fdat95 $value +fidonly +slice17 -samereg=/$samereg/ -xt -RETICLE_WAVE_ID=$waveid > 1153
	sort -n 1153 | uniq > lott
   
   while IFS= read -r line
	 do
    	 ttmp=$(fid $line -reg |grep "$samereg" |tail -n 1 | sed 's/\s\+/ /g' | wc -w)
    	 if [ $ttmp -eq 3 ];  then
        	 echo $line"(unique lot)"
	   	else
			echo $line
	     fi

	 done < lott >> lot



	echo "-------------------------------------------- " >> lot

done 

cat lot >| $file


#fdat95 DQD1V2V.31U +fidonly +slice17 -samereg=/ddslfdd4038s160pawp_48B/ -xt


rm 1548
rm lott
rm 1153
rm lot
rm 1545
rm 15451






















