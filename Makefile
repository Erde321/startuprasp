SHELL := /bin/bash

start:

	@make stop
	@make fancontrol

	@/usr/local/bin/ngrok tcp 22 > /dev/null &

	@sleep 5

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
			/usr/bin/python ./sendtext.py "$$NGROK_REMOTE_URL"; \
			exit 0; \
		else \
			if [ $$i -eq 8 ]; then \
				echo "Failed to start Ngrok after 8 attempts."; \
				exit 1; \
			else \
				echo "Attempt $$i failed to start Ngrok."; \
			fi; \
			sleep 2; \
		fi \
	done

stop:
	@echo "Stopping background ngrok process"
	@PID=$$(ps -ef | grep 'ngrok' | grep -v 'grep' | awk '{print $$2}'); \
	if [ -n "$$PID" ]; then \
		kill -9 $$PID; \
		echo "ngrok stopped"; \
	else \
		echo "No ngrok process found"; \
	fi

shutdown:
	@echo "Shutting down the Rapsberry Pi"
	sudo shutdown -h now

.PHONY: fancontrol

fancontrol:
	@sudo ./fancontrol/fancontrol.sh &

