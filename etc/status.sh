#!/usr/bin/env bash

SCRIPT=$(basename "$0")

# header
echo ""
echo "System Status:"

# divider
echo "---"

# display model info
echo -n "SBC: $(cat /sys/firmware/devicetree/base/model | tr -d '\0')"

# calculate and display physical memory size
MEMSIZE=$(vcgencmd get_config total_mem|cut -d= -f2)
if [ $MEMSIZE -lt 1024 ]; then
  FMEMSIZE="${MEMSIZE}MB"
else
  FMEMSIZE="$(expr $MEMSIZE / 1024)GB"
fi
echo ", $FMEMSIZE"

# divider
echo "---"

# display bootloader info
BOOTVER=$(vcgencmd bootloader_version | grep "timestamp" | cut -d " " -f 2)
if [ -z "$BOOTVER" ]; then
  echo "Bootloader not used on this Pi model"
else
  BOOTLONGVER=$(date -u -d @$BOOTVER)
echo "Bootloader date: $BOOTLONGVER"
fi

# display OS info
echo "OS: $(cat /proc/version | cut -d " " -f 1-3,21)"

# divider
echo "---"

# fetch status
STATUS=$(vcgencmd get_throttled | cut -d "=" -f 2)

# decode - https://www.raspberrypi.com/documentation/computers/os.html#get_throttled
if [ "$STATUS" == "0x0" ]; then
  echo "Never throttled since last reboot"
else
  echo "Throttle status=($STATUS), decoded as: "
fi
IFS=","
for BITMAP in \
   00,"currently under-voltage" \
   01,"ARM frequency currently capped" \
   02,"currently throttled" \
   03,"soft temperature limit reached" \
   16,"under-voltage has occurred since last reboot" \
   17,"ARM frequency capping has occurred since last reboot" \
   18,"throttling has occurred since last reboot" \
   19,"soft temperature reached since last reboot"
do set -- $BITMAP
   if [ $(($STATUS & 1 << $1)) -ne 0 ] ; then echo "  $2" ; fi
done

# divider
echo "---"

# display voltage info
for S in core sdram_c sdram_i sdram_p ; do printf '%7s voltage: %s\n' "$S" "$(vcgencmd measure_volts $S | cut -d "=" -f2)" ; done

# divider
echo "---"

echo "Temperature: $(vcgencmd measure_temp | tr -d "temp=")"

# display fan speed (if present and monitored)
if test -f /sys/devices/platform/cooling_fan/hwmon/*/fan1_input; then
  echo "Fan Speed: $(cat /sys/devices/platform/cooling_fan/hwmon/*/fan1_input) RPM"
else
  echo "Fan not present or without speed monitoring capability"
fi

# divider
echo "---"

# display current / minimum / maximum CPU speeds
cur_val=`cat /sys/devices/system/cpu/cpufreq/policy0/scaling_cur_freq`
float_val=$(echo "scale=4; $cur_val / 1000000" | bc)
printf "Current CPU clock: %.2g GHz\n" "$float_val"
cur_val=`cat /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq`
float_val=$(echo "scale=4; $cur_val / 1000000" | bc)
printf "Minimum CPU clock: %.2g GHz\n" "$float_val"
cur_val=`cat /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq`
float_val=$(echo "scale=4; $cur_val / 1000000" | bc)
printf "Maximum CPU clock: %.2g GHz\n" "$float_val"

# end
echo ""
