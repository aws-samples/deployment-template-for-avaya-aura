#!/bin/bash
while getopts hr:b:f:is args; do
case ${args} in
	 h)
        echo "Import AMI from OVA file.";
        echo "Import Usage:";
        echo "import-ova.sh -i -r [REGION] -b [BUCKET] -f [FILENAME]";
        echo "Check on import task status:";
        echo "import-ova.sh -s -r [REGION] -f [FILENAME]";
        echo "Specify S3 prefixes as part of the FILENAME parameter: prefix/file.ova";
        exit;;
    i) 
      startJob=True;;
    b) bucket=${OPTARG};;
    f) filename=${OPTARG};;
    s) 
      checkJob=True;;
    r) region=${OPTARG};;
	:) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
esac
done

shift "$(( OPTIND - 1 ))"

if [ -z "$region" ]; then
  echo 'Region not specified.' >&2
  echo 'Try: import-ova.sh -h'
  exit 1
fi

if ! [ "$startJob"=="True" -o   "$checkJob"=="True" ]; then
  echo 'Operation not specified.' >&2
  echo 'Try: import-ova.sh -h'
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed or properly configured.' >&2
  exit 1
fi

if [ $startJob ]; then
  if [ -z "$bucket" ]; then
  echo 'Bucket not specified. Please enter bucket name.' >&2
  read bucket
  fi

  if [ -z "$filename" ]; then
    echo 'Filename not specified. Please enter filename.' >&2
    read filename
    
  fi
  aws ec2 import-image --region $region --tag-specifications "ResourceType=import-image-task,Tags=[{Key=Platform,Value=Aura},{Key=Image,Value= \"$filename \" }]" --cli-input-json "{\"Description\": \"${filename}\",\"DiskContainers\": [ { \"Description\": \"${filename}\",\"UserBucket\": { \"S3Bucket\": \"${bucket}\", \"S3Key\" : \"${filename}\" } } ]}"|jq
fi

if [ $checkJob ]; then
  if [ -z "$filename" ]; then
    echo 'Filename not specified. Please enter filename.' >&2
    read filename
  fi

  tasks=($(aws ec2 describe-import-image-tasks --region $region|jq -c --arg filename "${filename}" '.ImportImageTasks|map(select(.Description|startswith($filename)))|map(if .Status == "completed" then {Description,Status,ImageId} else {"Description": .Description,"Status": .Status} end)|.[]'))
  echo "Tasks for $filename:"
  echo "===================="
  echo -e "Status \t\t Description \t\t\t\t\t ImageId"
  for task in "${tasks[@]}"
  do
  taskStatus=$(echo ${task[Status]}|jq -r '.Status')
  if [[ $taskStatus == "completed" ]]; then
    echo -e "$taskStatus \t $(echo ${task}|jq -r '.Description') \t $(echo ${task}|jq -r '.ImageId')"
  else
    echo -e "$taskStatus \t\t $(echo ${task}|jq -r '.Description') \t"
  fi
  done
fi
