# params
evox2_update_every=1
evox2_priority=1
evox2_path=/sys/class/evox2_ec
declare -a evox2_vars

# main metrics function
evox2_get() {
  if [ -d $evox2_path ]; then
    mapfile -t evox2_vars < <(cat $evox2_path/fan{1..3}/rpm $evox2_path/fan{1..3}/mode $evox2_path/fan{1..3}/level $evox2_path/temp1/{temp,min,max})
    for i in {3..5}; do
      if [ ${evox2_vars[i]} == "auto" ]; then
        evox2_vars[i]=1
        evox2_vars[(($i+3))]=6
      elif [ ${evox2_vars[i]} == "curve" ]; then
        evox2_vars[i]=2
      else
        evox2_vars[i]=3
      fi
    done
    return 0
  else
    return 1
  fi
}

# called once to find out if this chart should be enabled or not
evox2_check() {
  [ ! -d $evox2_path ] && error "can't find EVO-X2 class in $evox2_path" && return 1
  return 0
}

# called once to create the charts
evox2_create() {
  cat << EOF
CHART evox2.cputemp 'evox21' "CPU Temp" "Degrees" "CPU Temperature" '' line $((evox2_priority)) $evox2_update_every '' '' 'evox2'
DIMENSION cputemp '' absolute 1 1
DIMENSION cputempmin '' absolute 1 1
DIMENSION cputempmax '' absolute 1 1
CHART evox2.fanrpm 'evox22' "Fan RPMs" "rpm" "Fan RPMs" '' stacked $((evox2_priority+1)) $evox2_update_every '' '' 'evox2'
DIMENSION fan1rpm '' absolute 1 1
DIMENSION fan2rpm '' absolute 1 1
DIMENSION fan3rpm '' absolute 1 1
CHART evox2.fanmode 'evox23' "Fan Modes (1 = Auto, 2 = Curve, 3 = Manual)" "Mode" "Fan Modes" '' line $((evox2_priority+2)) $evox2_update_every '' '' 'evox2'
DIMENSION fan1mode '' absolute 1 1
DIMENSION fan2mode '' absolute 1 1
DIMENSION fan3mode '' absolute 1 1
CHART evox2.fanlevel 'evox24' "Fan Power Levels (6 = Auto)" "Level" "Fan Power Levels" '' line $((evox2_priority+3)) $evox2_update_every '' '' 'evox2'
DIMENSION fan1level '' absolute 1 1
DIMENSION fan2level '' absolute 1 1
DIMENSION fan3level '' absolute 1 1
EOF

  return 0
}

# called continuously to collect the values
evox2_update() {
  evox2_get || return 1

  cat << VALUESEOF
BEGIN evox2.fanrpm $1
SET fan1rpm = ${evox2_vars[0]}
SET fan2rpm = ${evox2_vars[1]}
SET fan3rpm = ${evox2_vars[2]}
END
BEGIN evox2.fanmode $1
SET fan1mode = ${evox2_vars[3]}
SET fan2mode = ${evox2_vars[4]}
SET fan3mode = ${evox2_vars[5]}
END
BEGIN evox2.fanlevel $1
SET fan1level = ${evox2_vars[6]}
SET fan2level = ${evox2_vars[7]}
SET fan3level = ${evox2_vars[8]}
END
BEGIN evox2.cputemp $1
SET cputemp = ${evox2_vars[9]}
SET cputempmin = ${evox2_vars[10]}
SET cputempmax = ${evox2_vars[11]}
END

VALUESEOF

  return 0
}
