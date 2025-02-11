# Definiert die Shell, die für die Befehle im Makefile verwendet wird
SHELL := /bin/bash

# Start-Ziel: Führt die erforderlichen Schritte aus, um ngrok zu starten, den Lüfter zu steuern und die SSH-Adresse zu senden
start:
	@make stop            # Beendet laufende ngrok-Prozesse, falls vorhanden
	@make fancontrol      # Startet das Lüftersteuerungsskript

	@/usr/local/bin/ngrok tcp 22 > /dev/null &  # Startet ngrok für SSH-Zugriff (Port 22)

	@sleep 5  # Kurze Wartezeit, damit ngrok den Tunnel initialisieren kann

	# Versucht bis zu 8-mal, die öffentliche ngrok-URL abzurufen
	@for ((i=1; i<=8; i++)); do \
		if curl -s http://localhost:4040/api/tunnels >/dev/null > /dev/null; then \
			echo "Ngrok successfully started."; \
			echo "🔍 Retrieving ngrok remote URL"; \
			NGROK_REMOTE_URL=$$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'); \
			if [ -z "$$NGROK_REMOTE_URL" ]; then \
				echo "❌ ERROR: ngrok doesn't seem to return a valid URL ($$NGROK_REMOTE_URL)"; \
				exit 1; \
			fi && \
			echo "✅ Ngrok remote URL: $$NGROK_REMOTE_URL" && \
			/usr/bin/python ./callmebot/sendtext.py "$$NGROK_REMOTE_URL"; \  # Sendet die URL per WhatsApp
			exit 0; \
		else \
			if [ $$i -eq 8 ]; then \
				echo "Failed to start Ngrok after 8 attempts."; \
				exit 1; \
			else \
				echo "Attempt $$i failed to start Ngrok."; \
			fi; \
			sleep 2; \  # Wartezeit zwischen den Versuchen
		fi \
	done

# Stop-Ziel: Beendet laufende ngrok-Prozesse
stop:
	@echo "Stopping background ngrok process"
	@PID=$$(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $$2}'); \
	if [ -n "$$PID" ]; then \
		kill -9 $$PID; \
		echo "ngrok stopped"; \
	else \
		echo "No ngrok process found"; \
	fi

# Shutdown-Ziel: Fährt den Raspberry Pi herunter
shutdown:
	@echo "Shutting down the Raspberry Pi"
	sudo shutdown -h now

# Markiert "fancontrol" als Phony-Target, damit Make nicht nach einer Datei mit diesem Namen sucht
.PHONY: fancontrol

# Fancontrol-Ziel: Startet das Lüftersteuerungsskript
fancontrol:
	@sudo ./fancontrol/fancontrol.sh &
