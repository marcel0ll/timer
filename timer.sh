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
    local DAY=$(date +%F)
    local DATE_TIME=$(date "+%Y/%m/%d %H:%M:%S")
    echo "i $DATE_TIME $1" >> "$TIME_TRACKING/time/$DAY.ledger"
    echo $1 > "$TIME_TRACKING/.data"
    echo $(date -u +%s) >> "$TIME_TRACKING/.data"

    shift
    if [[ ! -z $@ ]]; then
      echo $@ >> "$TIME_TRACKING/.data"
    fi
  else
    echo Already working in $(head -n 1 "$TIME_TRACKING/.data")
    tail -n +3 $TIME_TRACKING/.data 
  fi
}

timer_what() {
  if [[ -f $TIME_TRACKING/.data ]]; then
    local BEFORE=$(head -n 2 "$TIME_TRACKING/.data" | tail -n 1 )
    local NOW=$(date -u +%s)
    local ELAPSED=$((($NOW-$BEFORE)/60))
    echo $ELAPSED minutes since started working in $(head -n 1 "$TIME_TRACKING/.data")
    tail -n +3 $TIME_TRACKING/.data 
  else
    echo Not working atm.
  fi
}

timer_out() {
  if [[ -f $TIME_TRACKING/.data ]]; then
    local DAY=$(date +%F)
    local DESCRIPTION=$(tail -n +3 $TIME_TRACKING/.data)

    if [[ ! -z $DESCRIPTION ]]; then
      echo "; description: $DESCRIPTION" >> "$TIME_TRACKING/time/$DAY.ledger" 
    fi
    echo "o $(date "+%Y/%m/%d %H:%M:%S") $1" >> "$TIME_TRACKING/time/$DAY.ledger"
    echo "" >> "$TIME_TRACKING/time/$DAY.ledger"

    rm "$TIME_TRACKING/.data"
  else
    echo Not working atm.
  fi
}

timer_clear() {
  local DAY=$(date +%F)
  if [[ -f $TIME_TRACKING/.data ]]; then
    head -n -2 "$TIME_TRACKING/time/$DAY.ledger" > .tmp 
    mv .tmp "$TIME_TRACKING/time/$DAY.ledger"
    rm "$TIME_TRACKING/.data"
  else
    echo Not working atm.
  fi
}

timer_reg() {
  ledger -f "$TIME_TRACKING/main.ledger" reg -S date $@
}

timer_bal() {
  ledger -f "$TIME_TRACKING/main.ledger" bal $@
}

timer_complete() {
  if [[ $COMP_CWORD -le 1 ]]; then
    COMPREPLY=($(compgen -W "in out what clear reg bal" "${COMP_WORDS[1]}"));
  elif [ "${COMP_WORDS[1]}" == "in" ]; then
    local IFS=$'\n'
    COMPREPLY=($(compgen -W "$(ledger -f "$TIME_TRACKING/main.ledger" accounts)" "${COMP_WORDS[2]}"));
  fi
}

complete -F timer_complete timer
