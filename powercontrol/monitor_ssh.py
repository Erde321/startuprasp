import subprocess  # Für das Ausführen von Systembefehlen
import psutil  # Für das Überwachen von Systemressourcen und Netzwerkverbindungen
import time  # Für zeitgesteuerte Pausen im Skript
import logging  # Für das Loggen von Nachrichten
from logging.handlers import RotatingFileHandler  # Handler für rotierende Logdateien

# Pfad zum Shell-Skript, das den Modus umschaltet
powersave_script = "./pi_power_mode.sh"
# Pfad zur Logdatei, die für das Protokollieren der Ereignisse verwendet wird
log_file = "/var/log/pi_power_mode.log"

# Konfiguration des Loggings:
logger = logging.getLogger("pi_power_mode")  # Logger für das Skript erstellen
logger.setLevel(logging.INFO)  # Log-Level auf INFO setzen (alle Nachrichten ab INFO und höher werden geloggt)

# Rotierendes Logdatei-Handler konfigurieren:
handler = RotatingFileHandler(log_file, maxBytes=1024000, backupCount=3)  # Logdatei wird auf 1 MB begrenzt, es gibt maximal 3 Backups
formatter = logging.Formatter('%(asctime)s - %(message)s')  # Format für Lognachrichten, das Datum und die Nachricht enthält
handler.setFormatter(formatter)  # Formatter für den Handler festlegen
logger.addHandler(handler)  # Handler zum Logger hinzufügen

# Funktion, die beim ersten Start die Logdatei leert
def clear_logfile():
    with open(log_file, 'w'):  # Öffnet die Logdatei im Schreibmodus ('w') und leert sie
        pass  # Keine weiteren Aktionen nötig, da die Datei durch den Modus geleert wird

# Funktion zum Ausführen von Befehlen mit Sudo-Rechten (einmalig zur Sicherung von Berechtigungen)
def run_with_sudo(command):
    subprocess.run(["sudo"] + command)  # Der Befehl wird mit "sudo" ausgeführt

# Funktion, um den Powersave-Modus zu aktivieren
def set_powersave_mode():
    logger.info("Switching to Powersave mode")  # Loggt die Umschaltung auf Powersave-Modus
    run_with_sudo([powersave_script, "powersave"])  # Führt das Skript im Powersave-Modus aus

# Funktion, um den Normalmodus zu aktivieren
def set_normal_mode():
    logger.info("Switching to Normal mode")  # Loggt die Umschaltung auf Normalmodus
    run_with_sudo([powersave_script, "normal"])  # Führt das Skript im Normalmodus aus

# Funktion, die überprüft, ob eine SSH- oder VNC-Verbindung besteht
def check_connection():
    connections = psutil.net_connections()  # Holt sich alle Netzwerkverbindungen
    for conn in connections:  # Überprüft jede Verbindung
        if conn.status == psutil.CONN_ESTABLISHED:  # Nur etablierte Verbindungen prüfen
            if conn.laddr.port in (22, 5900):  # Wenn die Verbindung auf Port 22 (SSH) oder 5900 (VNC) läuft
                return True  # Rückgabe True, wenn eine der beiden Verbindungen besteht
    return False  # Rückgabe False, wenn keine Verbindung besteht

if __name__ == "__main__":  # Wenn das Skript direkt ausgeführt wird
    powersave_mode = True  # Initialzustand ist Powersave-Modus

    # Logdatei beim ersten Start leeren
    clear_logfile()

    try:
        while True:  # Endlosschleife, die kontinuierlich läuft, bis das Skript unterbrochen wird
            try:
                if check_connection():  # Prüft, ob eine SSH- oder VNC-Verbindung besteht
                    if not powersave_mode:  # Wenn wir aktuell im Powersave-Modus sind und eine Verbindung gefunden wurde
                        set_normal_mode()  # Umschalten auf den Normalmodus
                        powersave_mode = False  # Setze den Zustand auf Normalmodus
                        time.sleep(300)  # Warte 5 Minuten, bevor erneut überprüft wird
                else:  # Wenn keine Verbindung besteht
                    if powersave_mode:  # Wenn wir schon im Powersave-Modus sind
                        set_powersave_mode()  # Setze den Powersave-Modus fort
                        powersave_mode = True  # Setze den Zustand auf Powersave-Modus
            except subprocess.CalledProcessError as e:  # Fehlerbehandlung für subprocess-Fehler
                logger.error(f"Error while switching mode: {e}")  # Loggt den Fehler, falls der Moduswechsel fehlschlägt

            time.sleep(15)  # Warte 15 Sekunden, bevor die Verbindung erneut überprüft wird
    except KeyboardInterrupt:  # Wenn das Skript durch den Benutzer unterbrochen wird (Strg+C)
        print("\nExiting script.")  # Gebe eine Nachricht aus, dass das Skript beendet wird
