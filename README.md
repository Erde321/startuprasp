# Ngrok SSH & Power Control with CallMeBot

## Overview
This repository provides a Makefile-based automation system for managing remote SSH access using ngrok and sending connection details via WhatsApp through CallMeBot. Additionally, it includes power-saving and cooling control scripts to optimize energy consumption on a Raspberry Pi.

## Features
- **Remote SSH Access:** Uses ngrok to expose port 22 for SSH.
- **WhatsApp Notifications:** Sends the ngrok connection URL via CallMeBot.
- **Power Management:** Monitors SSH activity to toggle power-saving modes.
- **Cooling Control:** Manages fan speed based on CPU temperature.

## Installation & Setup
### Prerequisites
Ensure the following dependencies are installed:
- `ngrok`
- `jq`
- `psutil` (Python package)
- `CallMeBot-Whatsapp-Signal` ([GitHub Repository](https://github.com/stonatm/CallMeBot-Whatsapp-Signal))

### Clone Repository
```bash
git clone <your-repository-url>
cd <your-repository>
```

### Configure ngrok
Create an ngrok authentication token:
```bash
ngrok authtoken <your-ngrok-token>
```

### Set Up CallMeBot
Follow the setup instructions from the [CallMeBot repository](https://github.com/stonatm/CallMeBot-Whatsapp-Signal) to configure message sending.

## Usage
### Start ngrok & Fan Control
```bash
make start
```
This will:
- Stop any existing ngrok process
- Start the fan control script
- Launch ngrok and extract the public SSH address
- Send the SSH address to a predefined WhatsApp number

### Stop ngrok
```bash
make stop
```
This will terminate any running ngrok process.

### Enable Automatic Startup
To start the script at boot, add the following cron job:
```bash
crontab -e
```
Add this line:
```bash
@reboot cd /path/to/repository && make start
```

## Power Management
### Monitor SSH Connections
The `monitor_ssh.py` script continuously checks for active SSH/VNC sessions:
- If a session is detected, normal power mode is enabled.
- If no session is active, the Raspberry Pi enters power-saving mode.

To start the monitoring script manually:
```bash
python powercontrol/monitor_ssh.py
```

### Power Modes
To manually switch power modes, run:
```bash
sudo ./powercontrol/pi_power_mode.sh powersave
sudo ./powercontrol/pi_power_mode.sh normal
```

## Fan Control
The `fancontrol.sh` script adjusts fan speed based on CPU temperature.

### Default Temperature Thresholds:
- **55°C** → Low speed (33%)
- **60°C** → Medium speed (66%)
- **65°C** → High speed (100%)

Run the fan control script manually:
```bash
sudo ./fancontrol/fancontrol.sh
```

## License
This project is open-source. Feel free to modify and improve!

