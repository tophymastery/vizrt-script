#/home/adactus/script
echo "[INFO] - Start to change vmeo 2.5 ip"
echo "[INFO] - executing $0 with param $*"

CURRENT_IP=""
NEW_IP=""

HOSTS_PATH=/home/adactus/hosts
HOSTS_NAME=""
CURRENT_HOSTS_NAME=""

EAR_PATH=/usr/local/jboss/jboss-5.1.0.GA/server/vmeo/deploy

#Check command syntax and assign value
if [ $# -gt 0 ]; then
  while [ $# -gt 0 ]
  do
    if [ $1 == "--current_ip" ]; then
      CURRENT_IP=$2
      shift
      shift
    elif [ $1 == "--new_ip" ]; then
      NEW_IP=$2
      shift
      shift
    else
      echo "[WARN] - Unknown argument $1"
      shift
    fi
  done

  if [[ "$CURRENT_IP" == "" ]]; then
    CURRENT_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
  fi

  if [[ "$CURRENT_IP" == "" ]]; then
    CURRENT_IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}')
  fi

  if [[ "$CURRENT_IP" == "" ]]; then
    echo "[ERROR] - Can't retreive current ip, please set --current_ip param"
    exit 1
  fi

#CHeck param before starting process
  if [[ "$NEW_IP" == "" ]]; then
    echo "[ERROR] - Syntax error, please set --new_ip param"
    exit 1
  else
    echo "[INFO] - Will change ip $CURRENT_IP to $NEW_IP"
  fi
else
  echo "[ERROR] - Systax error status exit"
  exit 1
fi

#change host file
echo "[INFO] - Modifying $HOSTS_PATH"
HOSTS_NAME=$(hostname)
sed -i "s/$CURRENT_IP/$NEW_IP/g" $HOSTS_PATH
CURRENT_HOSTS_NAME=$(cat $HOSTS_PATH | grep $NEW_IP |  awk -F' ' '{print $2}')

if [[ $CURRENT_HOSTS_NAME != $HOSTS_NAME  ]]; then
  sed -i "s/$CURRENT_HOSTS_NAME/$HOSTS_NAME/g" $HOSTS_PATH
fi

echo "[INFO] - Stopping service vmeoController"
#/sbin/service vmeoController stop
backup_name=diactus.ear_$(date +%Y%m%d_%H%M%S)
echo "[INFO] - Backing up diactus.ear to $backup_name"
cd $EAR_PATH
cp $EAR_PATH/diactus.ear $EAR_PATH/$backup_name
echo "[INFO] - modifying $EAR_PATH/diactus.ear"
/usr/bin/jar -fx $EAR_PATH/diactus.ear
jboss_ip=$(cat $EAR_PATH/diactus.properties | grep "JBOSS_HOST =" | awk -F' ' '{print $3}')
if [[ $jboss_ip != $CURRENT_IP  ]]; then
  echo "[INFO] - Reading IP form diactus.propertoes"
  echo "[INFO] - Change current-ip to $jboss_ip"
  CURRENT_IP=$jboss_ip
fi
sed -i "s/$jboss_ip/$NEW_IP/g" $EAR_PATH/diactus.properties
#jar -uf diactus.ear diactus.properties

echo "[INFO] - Starting service vmeController"
#/sbin/service vmeoController start
