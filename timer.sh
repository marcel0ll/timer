# Script to help track time locally

# Variable that defines where files will be stores
export TIME_TRACKING=~/time_tracking

# Setup folders and files needed
[[ ! -d $TIME_TRACKING ]] && mkdir $TIME_TRACKING
[[ ! -d $TIME_TRACKING/time ]] && mkdir $TIME_TRACKING/time
[[ ! -f $TIME_TRACKING/main.ledger ]] && (cat <<EOF
include ./time/*.ledger
EOF
) > main.ledger

timer () {
  CMD=$1
  shift
  case $CMD in
    "in") timer_in $@;;
    "out") timer_out $@;;
    "what") timer_what $@;;
    "clear") timer_clear $@;;
    "reg") timer_reg $@;;
    "bal") timer_bal $@;;
    *) echo "Try in/out/what/clear/reg/bal";;
  esac
}

timer_in() {
  if [[ ! -f $TIME_TRACKING/.data ]]; then
    DAY=$(date +%F)
    DATE_TIME=$(date "+%Y/%m/%d %H:%M:%S")
    echo "i $DATE_TIME $1" >> "$TIME_TRACKING/time/$DAY.ledger"
    echo $1 > "$TIME_TRACKING/.data"
    echo $(date -u +%s) >> "$TIME_TRACKING/.data"
  else
    echo Already working in $(head -n 1 "$TIME_TRACKING/.data")
  fi
}

timer_what() {
  if [[ -f $TIME_TRACKING/.data ]]; then
    BEFORE=$(tail -n 1 "$TIME_TRACKING/.data")
    NOW=$(date -u +%s)
    ELAPSED=$((($NOW-$BEFORE)/60))
    echo $ELAPSED minutes since started working in $(head -n 1 "$TIME_TRACKING/.data")
  else
    echo Not working atm.
  fi
}

timer_out() {
  if [[ -f $TIME_TRACKING/.data ]]; then
    DAY=$(date +%F)
    echo "o $(date "+%Y/%m/%d %H:%M:%S") $1" >> "$TIME_TRACKING/time/$DAY.ledger"
    echo "" >> "$TIME_TRACKING/time/$DAY.ledger"

    rm "$TIME_TRACKING/.data"
  else
    echo Not working atm.
  fi
}

timer_clear() {
  DAY=$(date +%F)
  if [[ -f $TIME_TRACKING/.data ]]; then
    head -n -2 "$TIME_TRACKING/time/$DAY.ledger" > .tmp 
    mv .tmp "$TIME_TRACKING/time/$DAY.ledger"
    rm "$TIME_TRACKING/.data"
  else
    echo Not working atm.
  fi
}

timer_reg() {
  ledger -f "$TIME_TRACKING/main.ledger" reg
}

timer_bal() {
  ledger -f "$TIME_TRACKING/main.ledger" bal 
}

