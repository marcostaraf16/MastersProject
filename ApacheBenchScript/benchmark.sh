#!/bin/bash                                                                                                        
firstvm=""
secondvm=""
thirdvm="34.74.51.25"
fourthvm="35.238.45.252"
swvalue=0
swdivision=0

scalingval=7

dot="."
declare -i num
num=0
declare -i vm
vm=0
declare -i zero
zero=0
declare -i serv
serv=0
declare -i one
one=1
declare -i down
down=0
declare -i two
two=2


#getting time                                                                                                      
curtime=$(date +'%M')
echo "Current time: " $curtime
tenmin=$(($curtime + 20))
assurance=$(($curtime + 21))

echo "New window: " $tenmin

#ab scripts                                                                                                        
while :
do
    cat /dev/null > result.txt
    
    current=$(date +'%M')
    if [ $current == $tenmin ] || [ $current == $assurance ]; then
        echo "Adjusting to new scaling value"
        scalingval=$((swvalue / swdivision))
        echo "New scaling value: "
        echo $scalingval >> scalingvalues.txt
        tenmin=$(($current + 10))
        assurance=$(($current + 11))
        swvalue=$zero
        swdivision=$zero
    fi

    if [ $serv = $zero ]; then
        echo "VM:" >> data.txt
        if [ $vm = $zero ]; then
            sudo ab -n 4000 -c 50 -k -g onevm.data http://35.211.63.30/ > result.txt 2>&1
        elif [ $vm = $one ]; then
            sudo ab -n 4000 -c 50 -k -g twovm.data http://35.211.63.30/ > result.txt 2>&1
        else
            sudo ab -n 8000 -c 50 -k -g threevm.data http://35.211.63.30/ > result.txt 2>&1
        fi
    else
        echo "Serverless:" >> data.txt
        sudo ab -n 8000 -c 50 -k -g serverless.data http://cloudautoscaler.ue.r.appspot.com/ >result.txt 2>&1
    fi

    y=$(grep -w "(mean," result.txt)
    grep -w "(mean," result.txt >> data.txt
    grep -w "80%" result.txt >> data.txt
    grep -w "90%" result.txt >> data.txt
    grep -w "95%" result.txt >> data.txt
    grep -w "100%" result.txt >> data.txt
    grep -w "Requests" result.txt >> data.txt
    x=$(echo $y |awk '{print $4}')
    a=${x:0:2}
    secondcharacter=${a:1:2}
    firstcharacter=${a:0:1}
    echo $a
    #firstvalue=$(( $firstcharacter + $zero ))                                                                     
    if [ $secondcharacter = "." ]; then
        echo "hello"
        swvalue=$(($swvalue + $firstcharacter))
        swdivision=$(($swdivision + $one))
        a=$firstcharacter
        echo $a
    else
        swvalue=$(($swvalue + $a))
        swdivision=$(($swdivision + $one))
    fi
    echo $swvalue
    echo $swdivision

    if [ $serv == $one ]; then
        serv=$zero
    else
        if [ $a -le $scalingval ] || [ $num = $zero ] || [ $num = $one ]; then
            if [ $a -le $scalingval ]; then
                num=0
                if [ $down = $zero ] || [ $down = $one ]; then
                     down=$((down+1))
                    echo "Preparing to scale down"
                else
                    echo "Stopping VM"
                    gcloud compute instances stop additionalvm1 --zone=us-east1-b
                    sudo cp -f nginxconfig2vm.conf /etc/nginx/nginx.conf
                    sudo systemctl restart nginx
                    down=0
                fi
            else
                echo "Preparing to scale"
                num=$((num+1))
                serv=$one
                down=$zero
            fi
        else
            down=0
            if [ $vm -eq $zero ]; then
                echo "additional vm 1 starting"
                gcloud compute instances start start-upvm2 --zone=us-east1-b
                sudo cp -f nginxconfig2vm.conf /etc/nginx/nginx.conf
                sudo systemctl restart nginx
                vm=1
                serv=$one
            else
                echo "additional vm 2 starting"
                gcloud compute instances start additionalvm1 --zone=us-east1-b
                sudo cp -f nginxconfig3vm.conf /etc/nginx/nginx.conf
                sudo systemctl restart nginx
                vm=2
                serv=$one
            fi
            num=0
            down=0
            #gcloud compute instances start additionalvm1 --zone=us-east1-b                                        
        fi
    fi
done
