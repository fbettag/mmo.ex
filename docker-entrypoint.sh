#!/bin/sh
echo "[*] starting the server"
trap 'exit' INT; /opt/app/bin/mmo foreground