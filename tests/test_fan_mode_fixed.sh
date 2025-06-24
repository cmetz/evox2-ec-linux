#!/usr/bin/env bash

class_path=/sys/class/evox2_ec
declare -a fan1_rpms fan2_rpms fan3_rpms
declare -a original_modes original_levels

echo "Saving original fan settings..."
for i in {1..3}; do
    original_modes[$i]=$(cat $class_path/fan$i/mode)
    original_levels[$i]=$(cat $class_path/fan$i/level)
    echo "Fan $i: mode=${original_modes[$i]}, level=${original_levels[$i]}"
done
echo "------------------------"

echo "Setting fans to fixed mode..."
echo fixed | tee $class_path/fan{1..3}/mode > /dev/null

# Test each fan rpm level from 0 to 5
for level in {0..5}; do
    echo "Setting fans to level $level..."
    echo "$level" | tee $class_path/fan{1..3}/level > /dev/null

    echo "Waiting 5 seconds for fans to adjust..."
    sleep 5

    fan1_rpms[$level]=$(cat $class_path/fan1/rpm)
    fan2_rpms[$level]=$(cat $class_path/fan2/rpm)
    fan3_rpms[$level]=$(cat $class_path/fan3/rpm)

    echo "Fan 1 rpm: ${fan1_rpms[$level]}"
    echo "Fan 2 rpm: ${fan2_rpms[$level]}"
    echo "Fan 3 rpm: ${fan3_rpms[$level]}"
    echo "------------------------"
done

echo "Restoring original fan settings..."
for i in {1..3}; do
    echo "${original_modes[$i]}" > $class_path/fan$i/mode
    echo "${original_levels[$i]}" > $class_path/fan$i/level
    echo "Fan $i restored to: mode=${original_modes[$i]}, level=${original_levels[$i]}"
done

# Generate report
echo "
===========================================
|  Level  |  Fan 1  |  Fan 2  |  Fan 3  |
==========================================="

for level in {0..5}; do
    printf "|    %d    |   %4s  |   %4s  |   %4s  |\n" $level "${fan1_rpms[$level]}" "${fan2_rpms[$level]}" "${fan3_rpms[$level]}"
    echo "-------------------------------------------"
done

echo "Fan rpm test completed."
