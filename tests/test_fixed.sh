#!/usr/bin/env bash

class_path=/sys/class/evox2_ec
declare -a fan1_rpms
declare -a fan2_rpms
declare -a fan3_rpms

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

echo "Setting fans back to auto mode..."
echo auto | tee $class_path/fan{1..3}/mode > /dev/null

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
