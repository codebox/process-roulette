#!/usr/bin/env bash

SCORE=0
ROUND=1
ME=$(whoami)
COLS=$(tput cols)
BAR=$(printf '=%.0s' $(seq 1 $COLS))
NUMERIC='^[0-9]+$'
STOP_NOW='i am a coward'
ROOT_USER='root'

function center_text {
    TEXT=${1:- }
    PRE_SPACES=$(( (COLS - ${#TEXT} - 2) / 2 ))
    POST_SPACES=$(( COLS - 2 - ${#TEXT} - PRE_SPACES ))
    printf '#'
    printf "%0.s " $(seq 1 $PRE_SPACES)
    printf -- "$TEXT"
    printf "%0.s " $(seq 1 $POST_SPACES)
    printf '#\n'
}

function intro {
    clear

    echo $BAR
    center_text 
    center_text "--==[ PROCESS ROULETTE ]==--"
    center_text 
    center_text "This game randomly kills processes running on your computer"
    center_text "Other users' processes are worth more points"
    center_text "To get the highest scores play as the '${ROOT_USER}' user"
    center_text "If the game kills itself, or crashes your computer, you score nothing"
    center_text
    center_text "!!! Playing this game may crash or destabilise your computer !!!"
    center_text "When you finish playing you should probably reboot"
    center_text 
    if [[ $ME == $ROOT_USER ]]; then
        center_text "!!! You are playing as ${ROOT_USER} !!!"
        center_text 
    fi
    center_text "Enter the number of rounds you wish to play"
    center_text "To stop now enter '$STOP_NOW'"
    center_text 
    echo $BAR

    while true; do
        read -p "How many rounds? > " ANSWER
        if [[ $ANSWER == $STOP_NOW ]]; then
            echo "Game aborted, that's probably for the best."
            exit 1
        elif [[ $ANSWER =~ $NUMERIC ]]; then
            ROUNDS=$ANSWER
            echo "Playing $ROUNDS rounds..."
            break
        fi
    done
}

function select_random {
    VICTIM_INFO=$(ps -eo pid,user,comm | tail -n +2 | sort -R | head -1 | xargs)
    PID=$(echo $VICTIM_INFO | cut -f1 -d' ')
    USR=$(echo $VICTIM_INFO | cut -f2 -d' ')
    CMD=$(echo $VICTIM_INFO | cut -f3- -d' ' | sed 's/.*\///')
    if [[ $USR == $ROOT_USER ]]; then
        POINTS=5
    elif [[ $USR == $ME ]]; then
        POINTS=1
    else
        POINTS=2
    fi
}

function print_details {
    CLEAR_LINE="\r\033[K"
    PREFIX=${1-    }
    SUFFIX=${2-    }
    printf "$CLEAR_LINE $PREFIX $PID $CMD $SUFFIX"
}

function spin {
    SLEEP=0.02
    COUNT=0
    MAX_COUNT=12
    FRICTION="1.3000"
    ARROW_RIGHT="==> "
    ARROW_LEFT=" <=="

    while true; do
        select_random
        print_details
        sleep $SLEEP
        SLEEP=$(echo "$SLEEP * $FRICTION" | bc)
        COUNT=$(( COUNT + 1 ))
        if [[ $COUNT -gt $MAX_COUNT ]]; then
            break
        fi
    done

    print_details "$ARROW_RIGHT" "$ARROW_LEFT"
    sleep 0.5
    print_details
    sleep 0.5
    print_details "$ARROW_RIGHT" "$ARROW_LEFT"

    if kill -9 $PID 2>/dev/null ; then
        SCORE=$(( SCORE + POINTS ))        
        printf " KILLED for ${POINTS} point"
        if [[ $POINTS -gt 1 ]]; then
            printf "s"
        fi
        printf " [${USR}]"
    else
        printf " FAILED 0 points"
        if [[ $ME != $ROOT_USER ]]; then
            printf " (try running as ${ROOT_USER})"
        fi
    fi
    sleep 1
    echo
}

intro

while [[ $ROUND -le $ROUNDS ]]; do
    spin
    ROUND=$(( ROUND + 1 ))
done

echo "You survived ${ROUNDS} round/s and scored ${SCORE} points"

