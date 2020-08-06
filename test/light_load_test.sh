#!/bin/bash
echo "Starting the test..."
 seq 1 100 | xargs -n1 -P 10 bash -c "curl --request POST \
    --url http://localhost:8085/api/images/upload \
    --header 'content-type: multipart/form-data;' \
    --form device_id=999 \
    --form image=new_image"
