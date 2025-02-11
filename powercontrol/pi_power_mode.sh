#!/bin/bash

# Funktion zum Aktivieren oder Deaktivieren von Komponenten
enable_components() {
    local mode=$1

    # Powersave-Modus: Alle Komponenten außer WLAN ausschalten und CPU drosseln
    if [ "$mode" == "powersave" ]; then
        echo "Setting Powersave Mode..."
        # Deaktiviere HDMI
        sudo /opt/vc/bin/tvservice -o

        # Deaktiviere LEDs
        sudo sh -c 'echo 0 > /sys/class/leds/led0/brightness'

        # Deaktiviere Audio (falls nicht benötigt)
        sudo sh -c 'echo "disable_audio=1" >> /boot/config.txt'

        # Deaktiviere Ethernet-Schnittstelle
        sudo ifconfig eth0 down

        # Deaktiviere Bluetooth
        sudo systemctl stop bluetooth
        sudo systemctl disable bluetooth

        # Deaktiviere WiFi Power Management
        sudo iwconfig wlan0 power on

        # Deaktiviere USB-Geräte (Beispiel)
        echo "1-1" | sudo tee /sys/bus/usb/drivers/usb/unbind > /dev/null
        
        # Drossle die CPU-Leistung auf 50% (Beispiel)
        sudo vcgencmd measure_clock arm | awk -F"=" '{printf "%.0f\n", $2 * 0.5}' | sudo xargs -I {} vcgencmd measure_clock arm={} > /dev/null
        
        # Weitere Komponenten können hier nach Bedarf hinzugefügt werden
    fi

    # Normaler Modus: Alle Komponenten aktivieren und CPU auf Performance-Modus setzen
    if [ "$mode" == "normal" ]; then
        echo "Setting Normal Mode..."
        # Aktiviere HDMI
        sudo /opt/vc/bin/tvservice -p

        # Aktiviere LEDs (falls zuvor deaktiviert)
        sudo sh -c 'echo 1 > /sys/class/leds/led0/brightness'

        # Aktiviere Audio (falls zuvor deaktiviert, entferne Zeile aus /boot/config.txt)
        sudo sed -i '/disable_audio=1/d' /boot/config.txt

        # Aktiviere Ethernet-Schnittstelle
        sudo ifconfig eth0 up

        # Aktiviere Bluetooth
        sudo systemctl enable bluetooth
        sudo systemctl start bluetooth

        # Aktiviere WiFi Power Management
        sudo iwconfig wlan0 power on

        # Aktiviere USB-Geräte (Beispiel)
        echo "1-1" | sudo tee /sys/bus/usb/drivers/usb/bind > /dev/null
        
        # Setze CPU auf Standard-Frequenz (Beispiel)
        sudo vcgencmd measure_clock arm | awk -F"=" '{print $2}' | sudo xargs -I {} vcgencmd measure_clock arm={} > /dev/null
        
        # Weitere Komponenten können hier nach Bedarf aktiviert werden
    fi
}

# Hauptprogramm
if [ "$1" == "powersave" ]; then
    enable_components "powersave"
elif [ "$1" == "normal" ]; then
    enable_components "normal"
else
    echo "Usage: $0 {powersave|normal}"
    exit 1
fi

exit 0
