#!/bin/bash
check="false"

echo "Remote url $build_id_url"
echo "Checking build number on remote host"

until [ $check = "true" ]
do

if curl -s "$build_id_url" | grep -w "$build_id";
then
    echo "Build id found"
    exit
else
    sleep 30;
    echo "Waiting for build number ${build_id} to be returned by remote host...";
fi
done
