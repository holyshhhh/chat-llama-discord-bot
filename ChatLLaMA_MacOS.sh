#!/bin/bash

# Install not found
if [ ! -e "ChatLLaMA" ]; then
	mkdir ChatLLaMA
	cd ChatLLaMA

	# Downloads the Discord bot and webui files
	curl -L https://github.com/xNul/chat-llama-discord-bot/archive/refs/heads/main.zip --output chat-llama-discord-bot-main.zip
	curl -L https://github.com/oobabooga/text-generation-webui/releases/download/installers/oobabooga_macos.zip --output oobabooga_macos.zip

	# Extracts the Discord bot and webui files
	unzip chat-llama-discord-bot-main.zip
	unzip oobabooga_macos.zip

	# Installs webui and tricks it into not automatically running
	export OOBABOOGA_FLAGS="--fkdlsja >/dev/null 2>&1"
	bash oobabooga_macos/start_macos.sh

	# Activates the installed Miniconda environment for webui and installs the Discord bot library
	source "oobabooga_macos/installer_files/conda/etc/profile.d/conda.sh"
	conda activate "$(pwd)/oobabooga_macos/installer_files/env"
	python -m pip install discord

	# Changes webui to the latest commit ChatLLaMA supports
	cd oobabooga_macos/text-generation-webui
	git checkout 19f78684e6d32d43cd5ce3ae82d6f2216421b9ae
	cd ../..

	# Tricks webui into starting its model downloader
	export OOBABOOGA_FLAGS="--fkdlsja >/dev/null 2>&1; python download-model.py"
	bash oobabooga_macos/start_macos.sh

	# Moves ChatLLaMA's files to webui's directory for usage
	mv chat-llama-discord-bot-main/bot.py oobabooga_macos/text-generation-webui

	echo
	echo
	echo
	echo
	echo
	echo Installation has completed. Configuring the bot...
	echo

	# Obtains the user's Discord bot token and saves it to the disk for ease of use
	read -p "Enter your Discord bot's token: " token

	cd ..
	echo $token> token.cfg
fi

# Loads your Discord bot token
token=$(<token.cfg)

# Sets webui flags to trick webui into opening the bot instead
CHATLLAMA_FLAGS=""
export OOBABOOGA_FLAGS="--fkdlsja >/dev/null 2>&1; python bot.py --token $token --chat --model-menu $CHATLLAMA_FLAGS"

# Runs the Discord bot
bash ChatLLaMA/oobabooga_macos/start_macos.sh
