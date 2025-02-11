#!/bin/bash

round() {
    printf "%.${2}f" "${1}"
}

debug() {
    if [[ $debug -eq 1 ]]; then
        echo "[$(date)] [DEBUG] $1" >> "$2"
    fi
}

log() {
    echo "[$(date)] [LOG] $1" >> "$2"
}

# Default values
speed0=0.33
temp0=55

speed1=0.66
temp1=60

speed2=1.00
temp2=65

debug=0
logfile=/var/log/fancontrol

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Parse parameters
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s0 | --speed0 )
            speed0="$2"
            shift 2
            ;;
        -t0 | --temp0 )
            temp0="$2"
            shift 2
            ;;
        -s1 | --speed1 )
            speed1="$2"
            shift 2
            ;;
        -t1 | --temp1 )
            temp1="$2"
            shift 2
            ;;
        -s2 | --speed2 )
            speed2="$2"
            shift 2
            ;;
        -t2 | --temp2 )
            temp2="$2"
            shift 2
            ;;
        -d | --debug )
            debug=1
            shift
            ;;
        * )
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
done

# Main script logic using the parsed parameters
while true; do
    debug "Temps: $temp0,$temp1,$temp2" $logfile
    debug "Speeds: $speed0,$speed1,$speed2" $logfile

    cur_temp=$(round $(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1) 0)

    speed=$speed3
    if [[ $cur_temp -le $temp0 ]]; then
        speed=$speed0
    elif [[ $cur_temp -le $temp1 ]]; then
        speed=$speed1
    else
        speed=$speed2
    fi

    log "temp: $cur_temp - speed: $speed." $logfile

    # Hier könntest du den Befehl zum Einstellen der Lüftergeschwindigkeit einfügen
    # Beispiel: echo "Setze Lüftergeschwindigkeit auf $speed"
    
    sleep 5  # Wartezeit in Sekunden zwischen den Durchläufen
done
