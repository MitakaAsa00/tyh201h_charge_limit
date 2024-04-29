#/bin/sh
WORKDIR="/sys/class/power_supply/battery"

PATH_CAPACITY="${WORKDIR}/capacity"
PATH_STOP_CHARGE="${WORKDIR}/charger.0/stop_charge"
PATH_STATUS="${WORKDIR}/status"

TARGET_STOP_CHARGE_CAPACITY=80
TARGET_START_CHARGE_CAPACITY=70

FLAG_STOP_CHARGE=1
FLAG_START_CHARGE=0

# status
# Not charging 未充满 stop_charge=1
# Full 已充满 stop_charge=1 或 stop_charge=0
# Discharging 未接入充电器 stop_charge=1 或 stop_charge=0
# Charging 正在充电 stop_charge=0

SLEEP_TIME=1

function getCapacity(){
    echo $(cat "${PATH_CAPACITY}")
}

function getCharge(){
    echo $(cat "${PATH_STOP_CHARGE}")
}

function setCharge(){
    echo $1 > "${PATH_STOP_CHARGE}"
}


while true; do
    # 如果达到上限
    if [ $(getCapacity) -ge ${TARGET_STOP_CHARGE_CAPACITY} ]; then
        # 如果未停止充电
        if [ $(getCharge) -eq ${FLAG_START_CHARGE} ]; then
            # 停止充电
            setCharge ${FLAG_STOP_CHARGE}
        fi
    # 如果低于下限
    elif [ $(getCapacity) -lt ${TARGET_START_CHARGE_CAPACITY} ]; then
        # 如果已停止充电
        if [ $(getCharge) -eq ${FLAG_STOP_CHARGE} ]; then
            # 开始充电
            setCharge ${FLAG_START_CHARGE}
        fi
    fi
    sleep ${SLEEP_TIME}
done
    