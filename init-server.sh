#!/bin/bash

function setupSteamCMD() {
  mkdir -p /home/steam/Steam
  if [ ! -f "/home/steam/Steam/steamcmd.sh" ]; then
    echo 'Downloading SteamCMD...'
    curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - -C /home/steam/Steam
  fi
}

function installServer() {
  # Add '-beta experimental' before 'validate' to use the experimental branch
  FEXBash './steamcmd.sh +@sSteamCmdForcePlatformBitness 64 +force_install_dir "/satisfactory" +login anonymous +app_update 1690800 validate +quit'
}

function main() {
  setupSteamCMD

  # Fix for steamclient.so not being found
  mkdir -p /home/steam/.steam/sdk64
  ln -sfn /home/steam/Steam/linux64/steamclient.so /home/steam/.steam/sdk64/steamclient.so

  cd /home/steam/Steam

  echo 'Checking for SteamCMD updates...'
  FEXBash './steamcmd.sh +quit'

  if [ ! -f "/satisfactory/FactoryServer.sh" ]; then
    echo 'Server not found! Installing...'
    installServer
  fi

  if [ "$ALWAYS_UPDATE_ON_START" == "true" ]; then
    echo 'Checking for server updates...'
    installServer
  fi

  echo 'Starting server...'
  cd /satisfactory
  FEXBash "./FactoryServer.sh $EXTRA_PARAMS"
}

main
