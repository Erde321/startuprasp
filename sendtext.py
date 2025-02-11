import sys
import os

# Ermittelt den absoluten Pfad zur CallMeBot-Bibliothek basierend auf der Skript-Position
base_dir = os.path.dirname(os.path.abspath(__file__))
callmebot_path = os.path.join(base_dir, "callmebot/CallMeBot-Whatsapp-Signal")
sys.path.append(callmebot_path)

from callmebot import whatsapp

def send_whatsapp_message(message):
    # initialize library (run once)
    whatsapp.init("Your Number", "Your Token")
    # send text message to your whatsapp number
    whatsapp.send_message(message)

if __name__ == "__main__":
    # Überprüfe, ob ein Übergabeparameter vorhanden ist
    if len(sys.argv) != 2:
        print("Usage: python your_script.py 'message'")
        sys.exit(1)
    
    # Rufe die Funktion auf, um die WhatsApp-Nachricht zu senden
    message = sys.argv[1]
    send_whatsapp_message(message)
