#!/bin/bash 
WORKDIR=/results
NAMESPACE=default
POD_NAME=zadara-pod-tc
PVC_NAME=zadara-pvc-tc
max_loop_start=`echo $max_loop_start`
max_loop_end=`echo $max_loop_end`
disk_size=`echo $disk_size`
kubefile=`ls -lrt /kubeconfig | grep -i "^l" |awk '{print $9 }'`
storage_class=`echo $storage_class`
export KUBECONFIG=/kubeconfig/$kubefile
mkdir -p $WORKDIR
echo -e  $input| tr " " "\n" > $WORKDIR/input.txt


read_write_complete() {
	for type  in {read,write}
	do
		loop_counter=0
		pod_name1=zadara-pod-1-$type
		sed " s/type/$type/g; s/disk_size/$disk_size/g; s/storage_class/$storage_class/g"  zadara_complete.yaml >zadara-$type.yaml
				kubectl  apply -f zadara-$type.yaml -n $NAMESPACE &>/dev/null
		sleep 30
			pod_status=`kubectl get pods -A | grep -i $pod_name1 | grep -i running| wc -l`
			if [ $pod_status -eq 1 ]
			then

			fio_count=`kubectl exec -i $pod_name1 -- ps -eaf| grep fio| grep -v "grep" | wc -l`
			declare -i counter=0
			declare -i sleep_counter=0
			if [ $fio_count -gt 0 ];
				then 
				while [[ $sleep_counter -eq 0 && $counter -lt 7 ]]
						do
							sleep 60
						       	sleep_counter=`kubectl exec -i $pod_name1  -- ps -eaf| grep "sleep" | grep -v "grep" | wc -l`
							counter=$(($counter + 1))

							file_check=`kubectl exec -i $pod_name1  -- cat /out.json| wc -l`
							if [[ $file_check -eq 0 && $sleep_counter -ne 0 ]]
								then
								sleep_counter=0
							fi

					       	done
				else
					echo " Issue with $pod_name1 "
			fi
			else
					echo " Pod $pod_name1 is not in running state after waiting for 30 seconds"
					exit 2
			fi
		kubectl exec -i pod/$pod_name1 -- cat /out.json > $WORKDIR/result-$type.json
		writeiops=`/usr/bin/jq '.jobs[] .write|.iops' $WORKDIR/result-$type.json| awk -F "." '{print $1}'`
		readiops=`/usr/bin/jq '.jobs[] .read|.iops' $WORKDIR/result-$type.json| awk -F "." '{print $1}'`
		let totaliops=$(( $writeiops+$readiops ))
		loop_counter=$(($loop_counter + 1))
			echo  '{ "test" : "'${pod_name1}'", "totaliops" : '${totaliops}' },' >> $WORKDIR/final_output.json
			kubectl delete -f zadara-$type.yaml -n $NAMESPACE &>/dev/null
	done
}


read_write_mix() {
	for i in `eval echo {$max_loop_start..$max_loop_end}`
	do
#		echo "Preparing setup for TC-$i"
		pod_name=$POD_NAME-$i
		pvc_name=$PVC_NAME-$i
		read io_depth bs_kb num_jobs <<<$(head -$i $WORKDIR/input.txt | tail +$i | awk -F "," '{print $1" "$2" "$3}')
		sed "s/io_depth/$io_depth/g; s/bs_kb/$bs_kb/g; s/num_jobs/$num_jobs/g; s/zadara-pod-tc/$pod_name/g; s/disk_size/$disk_size/g; s/zadara-pvc-tc/$pvc_name/g; s/storage_class/$storage_class/g" zadara_test.yaml >zadara-$i.yaml
				kubectl  apply -f zadara-$i.yaml -n $NAMESPACE &>/dev/null
		sleep 30
		pod_status=`kubectl get pods -A | grep -i  $pod_name | grep -i running | wc -l`
		if [ $pod_status -eq 1 ]
		then

			fio_count=`kubectl exec -i $pod_name  -- ps -eaf| grep fio| grep -v "grep" | wc -l`
			declare -i counter=0
			declare -i sleep_counter=0
			if [ $fio_count -gt 0 ];
				then #echo $counter
				while [[ $sleep_counter -eq 0 && $counter -lt 7 ]]
						do
							sleep 60
						       	sleep_counter=`kubectl exec -i $pod_name  -- ps -eaf| grep "sleep" | grep -v "grep" | wc -l`
							counter=$(($counter + 1))

							file_check=`kubectl exec -i $pod_name  -- cat /out.json| wc -l`
							if [[ $file_check -eq 0 && $sleep_counter -ne 0 ]]
								then
								sleep_counter=0
							fi

					       	done
				else
					echo " Issue with $pod_name "
			fi
		else
			echo " Pod $pod_name is not in running state exiting the script"
			exit 2
		fi
		kubectl exec -i pod/zadara-pod-tc-$i -- cat /out.json > $WORKDIR/result-$i.json
		writeiops=`/usr/bin/jq '.jobs[] .write|.iops' $WORKDIR/result-$i.json| awk -F "." '{print $1}'`
		readiops=`/usr/bin/jq '.jobs[] .read|.iops' $WORKDIR/result-$i.json| awk -F "." '{print $1}'`
		let totaliops=$(( $writeiops+$readiops ))
		if [ $i -lt $max_loop_end ]
		then
			echo  '{ "test" : "'${pod_name}'", "totaliops" : '${totaliops}' },' >> $WORKDIR/final_output.json
		else
			echo  '{ "test" : "'${pod_name}'", "totaliops" : '${totaliops}' }' >> $WORKDIR/final_output.json
		fi
			kubectl delete -f zadara-$i.yaml -n $NAMESPACE &>/dev/null
	done
}

echo -e "[" > $WORKDIR/final_output.json

## commenting read write 100% script 

#	./read_write_performance.sh
read_write_complete
read_write_mix

echo -e "]" >> $WORKDIR/final_output.json
cat $WORKDIR/final_output.json >  /proc/1/fd/1
echo "All tests completed"
echo "Exiting..."
exit 0
