# Erklärung des Makefiles

Dieses Makefile dient dazu, verschiedene Aufgaben auf einem Raspberry Pi zu automatisieren, insbesondere das Starten und Stoppen von `ngrok`, das Steuern eines Lüfters und das Herunterfahren des Systems. Hier ist eine detaillierte Erklärung der einzelnen Abschnitte:

---

## 1. **Shell-Definition**
```makefile
SHELL := /bin/bash
```
- Hier wird die Shell festgelegt, die für die Ausführung der Befehle verwendet wird. In diesem Fall ist es `/bin/bash`.

---

## 2. **`start`-Ziel**
```makefile
start:
        @make stop
        @make fancontrol

        @/usr/local/bin/ngrok tcp 22 > /dev/null &

        @sleep 5

        @for ((i=1; i<=8; i++)); do \
                if curl -s http://localhost:4040/api/tunnels >/dev/null; then \
                        echo "Ngrok successfully started."; \
                        echo "🔍 Retrieving ngrok remote URL"; \
                        NGROK_REMOTE_URL=$$(curl -s http://localhost:4040/api/tunnels | jq -r '.tunnels[0].public_url'); \
                        if [ -z "$$NGROK_REMOTE_URL" ]; then \
                                echo "❌ ERROR: ngrok doesn't seem to return a valid URL ($$NGROK_REMOTE_URL)"; \
                                exit 1; \
                        fi; \
                        echo "✅ Ngrok remote URL: $$NGROK_REMOTE_URL"; \
                        /usr/bin/python ./callmebot/sendtext.py "$$NGROK_REMOTE_URL"; \
                        exit 0; \
                else \
                        if [ $$i -eq 8 ]; then \
                                echo "Failed to start Ngrok after 8 attempts."; \
                                exit 1; \
                        else \
                                echo "Attempt $$i failed to start Ngrok."; \
                        fi; \
                        sleep 2; \
                fi; \
        done
```

### Erklärung:
- **`@make stop`**: Stoppt alle laufenden `ngrok`-Prozesse.
- **`@make fancontrol`**: Startet das Lüftersteuerungsskript.
- **`@/usr/local/bin/ngrok tcp 22 > /dev/null &`**: Startet `ngrok` im Hintergrund, um den SSH-Port (22) zu tunneln.
- **`@sleep 5`**: Wartet 5 Sekunden, um `ngrok` Zeit zum Starten zu geben.
- **`for`-Schleife**: Versucht 8 Mal, die `ngrok`-API zu erreichen:
  - Wenn die API erreichbar ist, wird die öffentliche URL von `ngrok` abgerufen und über ein Python-Skript (`callmebot/sendtext.py`) gesendet.
  - Wenn die API nach 8 Versuchen nicht erreichbar ist, wird ein Fehler ausgegeben.

---

## 3. **`stop`-Ziel**
```makefile
stop:
        @echo "Stopping background ngrok process"
        @PID=$$(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $$2}'); \
        if [ -n "$$PID" ]; then \
                kill -9 $$PID; \
                echo "ngrok stopped"; \
        else \
                echo "No ngrok process found"; \
        fi
```

### Erklärung:
- **`ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $$2}'`**: Sucht nach der Prozess-ID (PID) von `ngrok`.
- **`kill -9 $$PID`**: Beendet den `ngrok`-Prozess, falls er gefunden wurde.
- Falls kein `ngrok`-Prozess gefunden wird, wird eine entsprechende Meldung ausgegeben.

---

## 4. **`shutdown`-Ziel**
```makefile
shutdown:
        @echo "Shutting down the Raspberry Pi"
        sudo shutdown -h now
```

### Erklärung:
- Fährt den Raspberry Pi herunter.

---

## 5. **`fancontrol`-Ziel**
```makefile
.PHONY: fancontrol

fancontrol:
        @sudo ./fancontrol/fancontrol.sh &
```

### Erklärung:
- **`.PHONY`**: Markiert `fancontrol` als "Phony"-Ziel, um sicherzustellen, dass es immer ausgeführt wird, auch wenn eine Datei mit demselben Namen existiert.
- **`sudo ./fancontrol/fancontrol.sh &`**: Startet das Lüftersteuerungsskript im Hintergrund.

---

## 6. **Verwendung**
### Befehle:
- **`make start`**: Startet `ngrok`, überprüft den Status und sendet die öffentliche URL.
- **`make stop`**: Stoppt alle `ngrok`-Prozesse.
- **`make shutdown`**: Fährt den Raspberry Pi herunter.
- **`make fancontrol`**: Startet das Lüftersteuerungsskript.

---

## 7. **Voraussetzungen**
- **`ngrok`**: Muss installiert und konfiguriert sein.
- **`jq`**: Wird benötigt, um die JSON-Antwort der `ngrok`-API zu verarbeiten.
- **`callmebot/sendtext.py`**: Ein Python-Skript, um die `ngrok`-URL zu senden.
- **`fancontrol/fancontrol.sh`**: Ein Skript zur Steuerung des Lüfters.

---

## 8. **Beispielausführung**
```bash
make start
```
- Stoppt `ngrok`, startet den Lüfter und `ngrok`, ruft die öffentliche URL ab und sendet sie.

```bash
make stop
```
- Stoppt alle `ngrok`-Prozesse.

```bash
make shutdown
```
- Fährt den Raspberry Pi herunter.

---

Mit diesem Makefile kannst du die Verwaltung deines Raspberry Pi automatisieren und sicherstellen, dass `ngrok` und der Lüfter korrekt gesteuert werden.
