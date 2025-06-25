#!/usr/bin/env bash


printf "+--------------------------------------------------------------+\n"
# APU Power Mode
apu_mode=$(cat /sys/class/ec_su_axb35/apu/power_mode)
# Temperature
temp=$(cat /sys/class/ec_su_axb35/temp1/temp)
printf "| %-26s | %-31s |\n" "CPU-Temp: ${temp} C" "Power mode: $apu_mode"


# Fan Table
printf "+-----+-------+-------+------+----------------+----------------+\n"
printf "| %-3s | %-5s | %-5s | %-4s | %-14s | %-14s |\n" "FAN" "MODE" "LEVEL" "RPM" "RAMPUP" "RAMPDOWN"
for i in 1 2 3; do
    mode=$(cat /sys/class/ec_su_axb35/fan${i}/mode)
    level=$(cat /sys/class/ec_su_axb35/fan${i}/level)
    rpm=$(cat /sys/class/ec_su_axb35/fan${i}/rpm)
    rampup=$(cat /sys/class/ec_su_axb35/fan${i}/rampup_curve)
    rampdown=$(cat /sys/class/ec_su_axb35/fan${i}/rampdown_curve)
    printf "| %-3d | %-5s | %-5d | %4d | %14s | %14s |\n" $i "$mode" "$level" "$rpm" "$rampup" "$rampdown"
    
done
printf "+-----+-------+-------+------+----------------+----------------+\n"
