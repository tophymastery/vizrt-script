mysql_user=""
mysql_password=""
mysql_dbname=""
start_date="1378001528268"
end_date="1379910333541"

tmp_return=""
result_file="result"

function getSourceVideoID {
  sql_tmp="sql.tmp"
  sql="use diactus;SELECT id FROM DigitalItemVariant WHERE createdTime between ${start_date} and ${end_date};"
  $(echo ${sql} > ${sql_tmp})
  echo "[INFO] - Query video Id in date range"
  echo "[INFO] - Will run sql command: ${sql}"  
 
  mysql --batch < ${sql_tmp} > ${result_file}
}

function getVideoList {
  sql_tmp="sql.tmp"
  start_id=$(head -n 2 ${result_file} | tail -n 1)
  end_id=$(tail -n 1 ${result_file})
  sql="use diactus;"
  sql="${sql}SELECT adaptation, id, fileSize, fileNamePrefix, mediaResourceId FROM MediaResource WHERE "
  sql="${sql}  substring_index(fileNamePrefix, \"_\",1) > ${start_id} AND "
  sql="${sql}  substring_index(fileNamePrefix, \"_\",1) < ${end_id}"
  $(echo ${sql} > ${sql_tmp})
  echo "[INFO] - Query video size in date range"
  echo "[INFO] - Will run sql command: ${sql}"
  mysql --batch < ${sql_tmp} > ${result_file}.csv
  echo "[INFO] - Created report to ${result_file}.csv"
}

function dateToTimestamp {
  get_date=$1
  timestamp=""
  timestamp=$(date -d ${get_date} +%s)
  timestamp=`expr $timestamp \\* 1000`
  echo "[INFO] - Convert date to timestamp: $1 to $timestamp"
  tmp_return=$timestamp
}

function setParam {
  echo "[INFO] - Checking argument"
  while [ $# -gt 0 ]
  do
    if [ $1 == "--start_date" ]; then
      start_date=$2
      shift
      shift
    elif [ $1 == "--end_date" ]; then
      end_date=$2
      shift
      shift
    elif [ $1 == "--file" ]; then
      result_file=$2
      shift
      shift
    fi
  done
  echo "[INFO] - Done"
}

setParam $*
dateToTimestamp ${start_date}
start_date=${tmp_return}

dateToTimestamp ${end_date}
end_date=${tmp_return}
getSourceVideoID
getVideoList

