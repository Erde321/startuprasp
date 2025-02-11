#!/bin/bash

# Eine Funktion zum Runden von Zahlen auf eine bestimmte Anzahl von Dezimalstellen
round() {
    printf "%.${2}f" "${1}"  # Gibt die Zahl mit einer Anzahl von Dezimalstellen zurück
}

# Funktion zum Debuggen, nur wenn der Debug-Modus aktiviert ist
debug() {
    if [[ $debug -eq 1 ]]; then
        echo "[$(date)] [DEBUG] $1" >> "$2"  # Schreibt Debug-Informationen in eine Logdatei
    fi
}

# Funktion zum Loggen von Informationen
log() {
    echo "[$(date)] [LOG] $1" >> "$2"  # Schreibt Log-Nachrichten in die Logdatei
}

# Standardwerte für Lüftergeschwindigkeit und Temperaturgrenzen
speed0=0.33  # Lüftergeschwindigkeit bei niedriger Temperatur
temp0=55     # Temperaturgrenze für speed0

speed1=0.66  # Lüftergeschwindigkeit bei mittlerer Temperatur
temp1=60     # Temperaturgrenze für speed1

speed2=1.00  # Lüftergeschwindigkeit bei hoher Temperatur
temp2=65     # Temperaturgrenze für speed2

debug=0  # Debug-Modus standardmäßig aus
logfile=/var/log/fancontrol  # Pfad zur Logdatei

# Überprüfe, ob das Skript mit Root-Rechten ausgeführt wird
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"  # Gibt eine Fehlermeldung aus, wenn das Skript nicht als root ausgeführt wird
    exit  # Beendet das Skript
fi

# Verarbeite Eingabeparameter
while [[ $# -gt 0 ]]; do
    case "$1" in
        -s0 | --speed0 )  # Setzt die Lüftergeschwindigkeit bei der ersten Temperaturgrenze
            speed0="$2"
            shift 2
            ;;
        -t0 | --temp0 )   # Setzt die Temperaturgrenze für speed0
            temp0="$2"
            shift 2
            ;;
        -s1 | --speed1 )  # Setzt die Lüftergeschwindigkeit bei der zweiten Temperaturgrenze
            speed1="$2"
            shift 2
            ;;
        -t1 | --temp1 )   # Setzt die Temperaturgrenze für speed1
            temp1="$2"
            shift 2
            ;;
        -s2 | --speed2 )  # Setzt die Lüftergeschwindigkeit bei der dritten Temperaturgrenze
            speed2="$2"
            shift 2
            ;;
        -t2 | --temp2 )   # Setzt die Temperaturgrenze für speed2
            temp2="$2"
            shift 2
            ;;
        -d | --debug )    # Aktiviert den Debug-Modus
            debug=1
            shift
            ;;
        * )  # Wenn ein unbekannter Parameter eingegeben wird
            echo "Unknown parameter: $1"
            exit 1  # Beendet das Skript mit einem Fehler
            ;;
    esac
done

# Hauptlogik des Skripts (führt die Steuerung der Lüftergeschwindigkeit basierend auf der Temperatur durch)
while true; do
    # Debugging-Informationen, die die gesetzten Temperaturen und Lüftergeschwindigkeiten anzeigen
    debug "Temps: $temp0,$temp1,$temp2" $logfile
    debug "Speeds: $speed0,$speed1,$speed2" $logfile

    # Liest die aktuelle Temperatur aus und rundet sie auf eine Ganzzahl
    cur_temp=$(round $(vcgencmd measure_temp | cut -d'=' -f2 | cut -d"'" -f1) 0)

    # Initialisiert die Lüftergeschwindigkeit mit einem ungültigen Wert (speed3 wird nicht definiert)
    speed=$speed3
    # Prüft, bei welcher Temperatur die Lüftergeschwindigkeit gesetzt werden soll
    if [[ $cur_temp -le $temp0 ]]; then
        speed=$speed0  # Wenn die Temperatur unter oder gleich temp0 ist, setze speed auf speed0
    elif [[ $cur_temp -le $temp1 ]]; then
        speed=$speed1  # Wenn die Temperatur unter oder gleich temp1, aber über temp0 ist, setze speed auf speed1
    else
        speed=$speed2  # Wenn die Temperatur über temp1 liegt, setze speed auf speed2
    fi

    # Protokolliert die aktuelle Temperatur und die berechnete Lüftergeschwindigkeit
    log "temp: $cur_temp - speed: $speed." $logfile

    # Hier könntest du den Befehl zum Einstellen der Lüftergeschwindigkeit einfügen
    # Beispiel: echo "Setze Lüftergeschwindigkeit auf $speed"
    
    sleep 5  # Wartezeit von 5 Sekunden, bevor die Temperatur erneut überprüft wird
done
