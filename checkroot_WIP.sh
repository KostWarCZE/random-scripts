# ROOT CHECK
checkroot_WIP () {
	if [ $UID == 0 ]; then
	echo "Root is detected."

	# Using `sudo`
	#CONTEPT: elif type sudo &>/dev/null ; then
	elif [ $UID != 0 ] && [[ -x sudo ]]; then 
	echo "Avasile needs root permission to proceed, trying using sudo."
	sudo avasile $@

	# Using `su`
	elif [ $UID != 0 ]; then 
		echo "Avasile needs root permission to proceed, trying to log-in as root."
		echo DEBUG: avasile $@
		su root -s "$0" -- "$@"
		#su -c "avasile $@"   
fi
}
