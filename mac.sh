#!/bin/bash 

### functions for adding characters according to request in $FORMAT
to2c () {
                sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1:/g' -e 's/\(.*\):$/\1/'
}

to4c () {
                sed -e 's/\([0-9A-Fa-f]\{4\}\)/\1:/g' -e 's/\(.*\):$/\1/'
}

to2d () {
                sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1./g' -e 's/\(.*\).$/\1/'
}

to4d () {
                sed -e 's/\([0-9A-Fa-f]\{4\}\)/\1./g' -e 's/\(.*\).$/\1/'
}

to2da () {
                sed -e 's/\([0-9A-Fa-f]\{2\}\)/\1-/g' -e 's/\(.*\)-$/\1/'
}

to4da () {
                sed -e 's/\([0-9A-Fa-f]\{4\}\)/\1-/g' -e 's/\(.*\)-$/\1/'
}

FORMATARRAY=( to2c to4c to2d to4d to2da to4da )
FORMAT=$1  
        if [ -z $FORMAT ]       # if first arg is missing, then default output format is to2c
                then FORMAT=to2c
        elif [[ "$FORMAT" == "t" || "$FORMAT" == "to" || "$FORMAT" == "to2" || "$FORMAT" == "to4" ]] || ! [[ "${FORMATARRAY[*]}" == *"$FORMAT"* ]]
                then
                cat << EOF

USSAGE:
$0 [to2c|to4c|to2d|to4d|to2da|to4da] 
to2c = Convert * to xx:xx:xx:xx:xx:xx
to4c = Convert * to xxxx:xxxx:xxxx
to2d = Convert * to xx.xx.xx.xx.xx.xx
to4d = Convert * to xxxx.xxxx.xxxx
to2da = Convert * to xx-xx-xx-xx-xx-xx
to4da = Convert * to xxxx-xxxx-xxxx

EOF
                exit
        fi


while read UI; do
        CLEAR=`echo $UI | sed 's/[.:-]//g'`
        if [[ $CLEAR == to2c ]] || [[ $CLEAR == to4c ]] || [[ $CLEAR == to2d ]] || [[ $CLEAR == to4d ]] || [[ $CLEAR == to2da ]] || [[ $CLEAR == to4da ]]
                then FORMAT=$CLEAR
        elif [ ${#CLEAR} -gt 12 -o ${#CLEAR} -lt 12 ] || [[ $CLEAR =~ [^0-9a-fA-F] ]]
                then
                        echo "MAC address must be exactly 12 char and/or contain char 0-9, a-f, A-F [HEX]"
                        echo "Your MAC address has ${#CLEAR} char"
                else
                        OUI=`echo $CLEAR |awk '{print toupper($0)}' | egrep -o "^[0-9a-fA-F]{6}"`
                        MACOUTPUT=`echo $CLEAR | $FORMAT | awk '{print tolower($0)}'`
                        OUIOUTPUT=`grep "$OUI" ~/scripts/oui.txt | sed -e 's/(base 16)//g' -e 's/\s\{3,\}/ /g'`
                        printf "${MACOUTPUT}\t$OUIOUTPUT\n\n"
        fi
        done
