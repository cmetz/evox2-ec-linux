# params
axb35_update_every=1
axb35_priority=1
axb35_path=/sys/class/ec_su_axb35
declare -a axb35_vars

# main metrics function
axb35_get() {
  if [ ! -d $axb35_path ]; then
    return 1
  fi

  # read all values from the module
  mapfile -t axb35_vars < <(
    cat \
      $axb35_path/fan{1..3}/rpm \
      $axb35_path/fan{1..3}/mode \
      $axb35_path/fan{1..3}/level \
      $axb35_path/temp1/{temp,min,max} \
      $axb35_path/apu/power_mode
  )
  
  # convert fan modes to numeric values
  for i in {3..5}; do
    case "${axb35_vars[i]}" in
      "fixed") axb35_vars[i]=3 ;;
      "curve") axb35_vars[i]=2 ;;
      "auto")
        axb35_vars[i]=1
        axb35_vars[(($i+3))]=6
        ;;
      *) axb35_vars[i]=0 ;; # unknown mode
    esac
  done
  
  # convert power mode to numeric value
  case "${axb35_vars[12]}" in
    "performance") axb35_vars[12]=3 ;;
    "balanced")    axb35_vars[12]=2 ;;
    "quiet")       axb35_vars[12]=1 ;;
    *)             axb35_vars[12]=0 ;; # unknown mode
  esac
  
  return 0
}

# called once to find out if this chart should be enabled or not
axb35_check() {
  [ ! -d $axb35_path ] && error "can't find AXB35 class in $axb35_path" && return 1
  return 0
}

# called once to create the charts
axb35_create() {
  cat << EOF
CHART axb35.cputemp 'axb351' "CPU Temp" "Degrees" "CPU Temperature" '' line $((axb35_priority)) $axb35_update_every '' '' 'axb35'
DIMENSION cputemp '' absolute 1 1
DIMENSION cputempmin '' absolute 1 1
DIMENSION cputempmax '' absolute 1 1
CHART axb35.fanrpm 'axb352' "Fan RPMs" "rpm" "Fan RPMs" '' stacked $((axb35_priority+1)) $axb35_update_every '' '' 'axb35'
DIMENSION fan1rpm '' absolute 1 1
DIMENSION fan2rpm '' absolute 1 1
DIMENSION fan3rpm '' absolute 1 1
CHART axb35.fanmode 'axb353' "Fan Modes (1 = Auto, 2 = Curve, 3 = Manual)" "Mode" "Fan Modes" '' line $((axb35_priority+2)) $axb35_update_every '' '' 'axb35'
DIMENSION fan1mode '' absolute 1 1
DIMENSION fan2mode '' absolute 1 1
DIMENSION fan3mode '' absolute 1 1
CHART axb35.fanlevel 'axb354' "Fan Power Levels (6 = Auto)" "Level" "Fan Power Levels" '' line $((axb35_priority+3)) $axb35_update_every '' '' 'axb35'
DIMENSION fan1level '' absolute 1 1
DIMENSION fan2level '' absolute 1 1
DIMENSION fan3level '' absolute 1 1
CHART axb35.powermode 'axb355' "Power Mode (1 = Quiet, 2 = Balanced, 3 = Performance)" "Mode" "Power Modes" '' line $((axb35_priority+4)) $axb35_update_every '' '' 'axb35'
DIMENSION powermode '' absolute 1 1
EOF

  return 0
}

# called continuously to collect the values
axb35_update() {
  axb35_get || return 1

  cat << VALUESEOF
BEGIN axb35.fanrpm $1
SET fan1rpm = ${axb35_vars[0]}
SET fan2rpm = ${axb35_vars[1]}
SET fan3rpm = ${axb35_vars[2]}
END
BEGIN axb35.fanmode $1
SET fan1mode = ${axb35_vars[3]}
SET fan2mode = ${axb35_vars[4]}
SET fan3mode = ${axb35_vars[5]}
END
BEGIN axb35.fanlevel $1
SET fan1level = ${axb35_vars[6]}
SET fan2level = ${axb35_vars[7]}
SET fan3level = ${axb35_vars[8]}
END
BEGIN axb35.cputemp $1
SET cputemp = ${axb35_vars[9]}
SET cputempmin = ${axb35_vars[10]}
SET cputempmax = ${axb35_vars[11]}
END
BEGIN axb35.powermode $1
SET powermode = ${axb35_vars[12]}
END

VALUESEOF

  return 0
}
