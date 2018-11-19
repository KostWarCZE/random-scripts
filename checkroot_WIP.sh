# ROOT CHECK
CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)

# ROOT CHECK
checkroot_WIP () {
	if [[ "$UID" == 0 ]];
	then
		echo "Root is detected."
		avasile "$@"
	elif [[ "${CAN_I_RUN_SUDO}" -gt 0 ]]; then 
		echo "Avasile needs root permission to proceed, trying using sudo."
		sudo avasile "$@"
	else
		echo "Avasile needs root permission to proceed, trying to log-in as root."
		su -c "avasile $@" -m root
	fi
}
