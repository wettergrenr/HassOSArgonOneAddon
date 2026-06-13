#!/usr/bin/with-contenv bashio

###
#Methods - methods called by script
###
##make everything into a float
mkfloat() {
  str=$1
  if [[ $str != *"."* ]]; then
    str=$str".0"
  fi
  echo "$str";
}

##Perform basic checks and return the port number of the detected device.  If the
## device is detected via rudamentary checks, then we will return that exit code.
## otherwise we return 255.
findCoolingDevice() {
  local max_attempts=15
  local attempt=1

  while [ $attempt -le $max_attempts ]; do
    for device in /sys/class/thermal/cooling_device*; do
      if [ -f "$device/type" ]; then
        type=$(cat "$device/type")
        if [ "$type" = "pwm-fan" ]; then
          coolingDevice=$device
          echo "Found PWM fan cooling device at $device"
          return 0
        fi
      fi
    done
    
    echo "Attempt $attempt/$max_attempts: Cannot find PWM fan cooling device. Retrying in 2 seconds..."
    sleep 2
    attempt=$((attempt + 1))
  done

  echo "Failed to find PWM fan cooling device after $max_attempts attempts. Make sure the fan is connected to the dedicated fan header."
  exit 1
} 

## Float comparison so that we don't need to call non-bash processes
fcomp() {
  local oldIFS="$IFS" op=$2 x y digitx digity
  IFS='.'
  x=( ${1##+([0]|[-]|[+])} )
  y=( ${3##+([0]|[-]|[+])} )
  IFS="$oldIFS"
  while [[ "${x[1]}${y[1]}" =~ [^0] ]]; do
    digitx=${x[1]:0:1}
    digity=${y[1]:0:1}
    (( x[0] = x[0] * 10 + ${digitx:-0} , y[0] = y[0] * 10 + ${digity:-0} ))
    x[1]=${x[1]:1} y[1]=${y[1]:1}
  done
  [[ ${1:0:1} == '-' ]] && (( x[0] *= -1 ))
  [[ ${3:0:1} == '-' ]] && (( y[0] *= -1 ))
  (( "${x:-0}" "$op" "${y:-0}" ))
}

fanSpeedReportLinear(){
  fanPercent=${1}
  cpuTemp=${2}
  CorF=${3}
  icon=mdi:fan
  reqBody='{"state": "'"${fanPercent}"'", "attributes": { "unit_of_measurement": "%", "icon": "'"${icon}"'", "Temperature '"${CorF}"'": "'"${cpuTemp}"'", "friendly_name": "Argon Fan Speed"}}'
  exec 3<>/dev/tcp/hassio/80
  echo -ne "POST /homeassistant/api/states/sensor.argon_one_addon_fan_speed HTTP/1.1\r\n" >&3
  echo -ne "Host: hassio\r\n" >&3
  echo -ne "Connection: close\r\n" >&3
  echo -ne "Authorization: Bearer ${SUPERVISOR_TOKEN}\r\n" >&3
  echo -ne "Content-Type: application/json\r\n" >&3
  echo -ne "Content-Length: $(echo -ne "${reqBody}" | wc -c)\r\n" >&3
  echo -ne "\r\n" >&3
  echo -ne "${reqBody}" >&3
  timeout=5
  while read -t "${timeout}" -r line; do
    echo "${line}">/dev/null
  done <&3
  exec 3>&-
}

actionLinear() {
  fanPercent=${1};
  cpuTemp=${2};
  CorF=${3};

  if [[ $fanPercent -lt 0 ]]; then
    fanPercent=0
  fi;

  if [[ $fanPercent -gt 100 ]]; then
    fanPercent=100
  fi;

  maxState=$(cat "${coolingDevice}/max_state" 2>/dev/null)
  curState=$(cat "${coolingDevice}/cur_state" 2>/dev/null)
  
  if ! [[ "$maxState" =~ ^[1-9][0-9]*$ ]] || ! [[ "$curState" =~ ^[0-9]+$ ]]; then
    echo "Warning: Invalid read from cooling device (curState=${curState}, maxState=${maxState}). Skipping."
    return 0
  fi
  
  actualFanPercent=$(( curState * 100 / maxState ))

  printf '%(%Y-%m-%d_%H:%M:%S)T'
  echo ": ${cpuTemp}${CorF} - Kernel Fan State: ${curState}/${maxState} (${actualFanPercent}%)";
  
  test "${createEntity}" == "true" && fanSpeedReportLinear "${actualFanPercent}" "${cpuTemp}" "${CorF}" &
  return 0
}

tmini=0
tmaxi=0
CorF=$(jq -r '."Celsius or Fahrenheit"'<options.json)
createEntity=$(jq -r '."Create a Fan Speed entity in Home Assistant"' <options.json)
logTemp=$(jq -r '."Log current temperature every 30 seconds"' <options.json)

###
#initial setup - prepare things for operation
###
fanPercent=-1;
echo "Detecting PWM Fan cooling device."
findCoolingDevice;

trap 'echo "Failed ${LINENO}: $BASH_COMMAND"' ERR
echo "Settings initialized. Argon One V5 Fan Detected. Beginning monitor.."

###
#Main Loop - read and react to changes in read temperature
###
until false; do
  read -r cpuRawTemp < /sys/class/thermal/thermal_zone0/temp #read instead of cat fpr process reduction
  cpuTemp=$(( cpuRawTemp/1000 )) #built-in bash math
  unit="C"

  if [ "$CorF" == "F" ]; then # convert to F
    cpuTemp=$(( ( cpuTemp *  9/5 ) + 32 ));
    unit="F"
  fi

  value=$cpuTemp
  test "${logTemp}" == "true" && echo "Current Temperature = $cpuTemp °$unit"
  actionLinear "" "${cpuTemp}" "${CorF}"
  sleep 30

done
