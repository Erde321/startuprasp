import subprocess
import psutil
import time
import logging
from logging.handlers import RotatingFileHandler

powersave_script = "./pi_power_mode.sh"
log_file = "/var/log/pi_power_mode.log"

# Konfiguration des Loggings
logger = logging.getLogger("pi_power_mode")
logger.setLevel(logging.INFO)

# Rotierendes Logdatei-Handler konfigurieren
handler = RotatingFileHandler(log_file, maxBytes=1024000, backupCount=3)
formatter = logging.Formatter('%(asctime)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

# Funktion zum Leeren der Logdatei beim ersten Start
def clear_logfile():
    with open(log_file, 'w'):
        pass

# Sudo einmalig verwenden, um die Berechtigung zu sichern
def run_with_sudo(command):
    subprocess.run(["sudo"] + command)

def set_powersave_mode():
    logger.info("Switching to Powersave mode")
    run_with_sudo([powersave_script, "powersave"])

def set_normal_mode():
    logger.info("Switching to Normal mode")
    run_with_sudo([powersave_script, "normal"])

def check_connection():
    # Überprüfe, ob eine SSH- oder VNC-Verbindung besteht
    connections = psutil.net_connections()
    for conn in connections:
        if conn.status == psutil.CONN_ESTABLISHED:
            if conn.laddr.port in (22, 5900):
                return True
    return False

if __name__ == "__main__":
    powersave_mode = True

    # Logdatei beim ersten Start leeren
    clear_logfile()

    try:
        while True:
            try:
                if check_connection():
                    if not powersave_mode:
                        set_normal_mode()
                        powersave_mode = True
                        time.sleep(300)  # Überprüfe alle 300 Sekunden die Verbindung
                else:
                    if powersave_mode:
                        set_powersave_mode()
                        powersave_mode = False
            except subprocess.CalledProcessError as e:
                logger.error(f"Error while switching mode: {e}")

            time.sleep(15)  # Überprüfe alle 15 Sekunden die Verbindung
    except KeyboardInterrupt:
        print("\nExiting script.")
