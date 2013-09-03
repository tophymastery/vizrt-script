#!/bin/bash
MOBILE_TAG='<wf-mobile:detectDevice var=\"wireframe\" defaultWireFrame=\"\${defaultWireFrame}\"\/>'
PC_TAG='<%--<wf-mobile:detectDevice var=\"wireframe\" defaultWireFrame=\"\${defaultWireFrame}\"\/>--%>'

PUB_LIST="
tpbspo
tpbspr
tpbsco
"

declare -A local_server_address
local_server_address[1]="http://www.thaipbs.or.th/"
local_server_address[2]="http://program.thaipbs.or.th/"
local_server_address[3]="http://org.thaipbs.or.th/"

webapp_path=/
image_server_url=/
compress_javascript=false
compress_css=false

declare -A properties_list

for i in $(seq 3)
do
    properties_list[$i,'file']="/opt/tomcat/${i_pub}/ROOT/WEB-INF/classes/config/core.properties"
    properties_list[$i,'old_val1']="local_server_address"
    properties_list[$i,'new_val1']="local_server_address=${local_server_address[$i]}"
    properties_list[$i,'old_val2']="webapp_path"
    properties_list[$i,'new_val2']="webapp_path=/"
    properties_list[$i,'old_val3']="image_server_url"
    properties_list[$i,'new_val3']="image_server_url=/"
    properties_list[$i,'old_val4']="compress_javascript"
    properties_list[$i,'new_val4']="compress_javascript=false"
    properties_list[$i,'old_val5']="compress_css"
    properties_list[$i,'new_val5']="compress_css=false"
done

count=1
for i in $PUB_LIST
do
    properties_list[$count,'file']="/opt/tomcat/${i}/ROOT/WEB-INF/classes/config/core.properties"
    let "count++"
done

function usage() {
  echo "This script is used for TPBS enable/disable mobile version"
}

function enable_mobile() {
  echo "en"
  declare -A en_change_list
  for i in $(seq 3)
  do
    en_change_list[$i,'old_val']=$PC_TAG
    en_change_list[$i,'new_val']=$MOBILE_TAG
  done

  count=1
  for i_pub in $PUB_LIST
  do
      en_change_list[$count,'file']="/opt/tomcat/webapps/${i_pub}/template/common.jsp"
      let "count++"
  done

  for i in $(seq 3)
  do
    sed -ei "/${en_change_list[$i,old_val]}/c\${en_change_list[$i,new_val]}" ${en_change_list[$i,file]}
  done
}


function disenable_mobile() {
  echo "dis"
  declare -A dis_change_list
  for i in $(seq 3)
  do
    dis_change_list[$i,'old_val']=$MOBILE_TAG
    dis_change_list[$i,'new_val']=$PC_TAG
  done

  count=1
  for i_pub in $PUB_LIST
  do
      dis_change_list[$count,'file']="/opt/tomcat/webapps/${i_pub}/template/common.jsp"
      let "count++"
  done

  for i in $(seq 3)
  do
    sed -i "/${dis_change_list[$i,old_val]}/c\${dis_change_list[$i,new_val]}" ${dis_change_list[$i,file]}
  done
}
function change_properties() {
  for i in $(seq 3)
  do
    for i_arr in $(seq 5)
    do
      echo  sed -i "/${properties_list[$i,old_val$i_arr]}/c\${properties_list[$i,new_val$i_arr]}" ${properties_list[$i,'file']}
    done
  done
}

