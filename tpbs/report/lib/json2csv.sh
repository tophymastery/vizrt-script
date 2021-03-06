date_range=30
jq_filter=".components[1].lineChart.dataTable.rows[0].c[][]"
source_path=/mnt/tmp/tpbs/report
desc_path=/mnt/tmp/tpbs/report
lib_path=/mnt/tmp/tpbs/report/lib

source_file=json2.txt
desc_file=test.txt

merge_file=0
merge_file1="result1"
merge_file2="result2"
merge_path=/mnt/tmp/tpbs/report
merge_file_output="result_out.csv"

purge=0

function set_config {
  while [ $# -gt 0 ]
  do
    if [ $1 == "--source_path" ]; then
      source_path=$2
      shift
      shift
    elif [ $1 == "--desc_path" ]; then
      desc_path=$2
      shift
      shift
    elif [ $1 == "--source_file" ]; then
      source_file=$2
      shift
      shift
    elif [ $1 == "--desc_file" ]; then
      desc_file=$2
      shift
      shift
    elif [ $1 == "--date_range" ]; then
      date_range=$2
      shift
      shift
    elif [ $1 == "--merge_file" ]; then
      merge_file=$2
      shift
      shift
    elif [ $1 == "--merge_file1" ]; then
      merge_file=$2
      shift
      shift
    elif [ $1 == "--merge_file2" ]; then
      merge_file=$2
      shift
      shift
    elif [ $1 == "--merge_path" ]; then
      merge_file=$2
      shift
      shift
    elif [ $1 == "--merge_file_output" ]; then
      merge_file=$2
      shift
      shift
    elif [ $1 == "--purge" ]; then
      purge=$2
      shift
      shift
    elif [ $1 == "--help" ]; then
      cat help.txt
      exit 0
    else 
      shift
    fi
  done
}

function verify_path_directory {
  verify_result=1
  is_source_path=-1
  is_desc_path=-1

  echo "[INFO] - Verifying path and directory."

  if [ ! -d $source_path ]; then
    echo "[ERROR] - Directory ${source_path} doesn't exist."
    echo "[ERROR] - Please set parameter --source_path"
    verify_result=-1
  else
    is_source_path=1
  fi

  if [ ! -d $desc_path ]; then
    echo "[ERROR] - Directory ${desc_path} doesn't exist."
    echo "[ERROR] - Please set parameter --desc_path"
    verify_result=-1
  else
    is_desc_path=1
  fi

  if [ ! -d $lib_path ]; then
    echo "[ERROR] - Directory ${lib_path} doesn't exist."
    echo "[ERROR] - Please set parameter --lib_path"
    verify_result=-1
  fi

  if [ ! -f $source_file ]; then
    echo "[ERROR] - File ${source_path}/${source_file} doesn't exist."
    echo "[ERROR] - Please set parameter --source_file"
    verify_result=-1
  fi
  
  if [ $merge_file -eq 1 ]; then
    verify_result=1
    if [ ! -d $merge_path ]; then
      echo "[ERROR] - Directory ${merge_path} doesn't exist."
      echo "[ERROR] - Please set parameter --merge_path"
      verify_result=-1
    fi

    if [ ! -f $merge_file1 ]; then
      echo "[ERROR] - File ${merge_path}/${merge_file1} doesn't exist."
      echo "[ERROR] - Please set parameter --merge_file1"
      verify_result=-1
    fi

    if [ ! -f $merge_file2 ]; then
      echo "[ERROR] - File ${merge_path}/${merge_file2} doesn't exist."
      echo "[ERROR] - Please set parameter --merge_file2"
      verify_result=-1
    fi
  fi

  if [ $purge -gt 0 ]; then
    echo "will purge"
    verify_result=1
    if [ $is_source_path -lt 1 ]; then
      echo "[ERROR] - Directory ${source_path} doesn't exist."
      verify_result=-1
    fi
  
    if [ $is_desc_path -lt 1 ]; then
      echo "[ERROR] - Directory ${desc_path} doesn't exist."
      verify_result=-1
    fi
  fi

  if [ $verify_result -lt 1 ]; then
    echo "[ERROR] - Will exit."
    exit 0
  fi

}

function extract_json {
  for i in $(seq ${date_range})
  do
    let jq_index=$i-1
    jq_filter=".components[1].lineChart.dataTable.rows[${jq_index}].c[]"
    $(cat ${source_path}/${source_file} | ${lib_path}/jq "${jq_filter}" | grep "v" | awk -F':' '{print $2}' > ${desc_path}/${desc_file}.${i})
  done
}

function merge_data {
  echo "[INFO] - Will merge data to ${desc_path}/${desc_file}"
  result=""
  line_num=$(cat ${desc_path}/${desc_file}.1 | wc -l)

  for line in $(seq ${line_num})
  do
    for i in $(seq ${date_range})
    do
      result="${result};$(head -${line} ${desc_path}/${desc_file}.${i} | tail -1)"
    done
    echo "${result}" >> ${desc_path}/${desc_file}
    result=""
  done
  echo "[INFO] - Merge data done."
}

function merge_file {
  num_line=0
  tmp_line=0
  result=""

  echo "[INFO] - Will merge ${merge_file1} and ${merge_file2} to ${merge_file_output}"
  num_line=$(cat ${merge_path}/${merge_file1} | wc -l)
  tmp_line=$(cat ${merge_path}/${merge_file2} | wc -l)
  if [ $num_line -lt $tmp_line ]; then
    num_line=$tmp_line
  fi

  for i in $(seq ${num_line})
  do
    result=$(head -${i} ${merge_path}/${merge_file1} | tail -1)
    result="${result};$(head -${i} ${merge_path}/${merge_file2} | tail -1)"
    echo "${result}" >> ${merge_path}/${merge_file_output}
    result=""
  done

  echo "[INFO] - Merge file done."
}

function purge {
  echo "[INFO] - Will delete all files in ${source_path}"
  $(find ${source_path}/ -maxdepth 1 -type f -delete)
  if [ $? -eq 0 ]; then
    echo "[INFO] - Done."
  fi

  echo "[INFO] - Will delete all files in ${desc_path}"
  $(find ${desc_path}/ -maxdepth 1 -type f -delete)
  if [ $? -eq 0 ]; then
    echo "[INFO] - Done."
  fi
}


set_config $*
verify_path_directory

if [ $purge -gt 0 ]; then
  purge
  exit 0
fi

if [ $merge_file -gt 0 ]; then
  merge_file
fi


#extract_json
#merge_data


