#!/bin/sh
system_json="/mnt/UDISK/system.json"
Current_Theme=$(/usr/trimui/bin/systemval theme)
Current_bg="$Current_Theme/skin/bg.png"
if [ ! -f "$Current_bg" ]; then
	Current_bg="/mnt/SDCARD/trimui/res/skin/transparent.png"
fi

version=$(cat /mnt/SDCARD/System/usr/trimui/crossmix-version.txt)
/mnt/SDCARD/System/bin/sdl2imgshow \
	-i "$Current_bg" \
	-f "/mnt/SDCARD/System/resources/DejaVuSans.ttf" \
	-s 30 \
	-c "220,220,220" \
	-t "CrossMix OS v$version" &
sleep 0.1
pkill -f sdl2imgshow

################ check min Firmware version required ################
FW_VERSION="$(cat /etc/version)"
CrossMix_MinFwVersion=$(cat /mnt/SDCARD/trimui/firmwares/MinFwVersion.txt)
if [ "$(printf '%s\n' "$FW_VERSION" "$CrossMix_MinFwVersion" | sort -V | head -n1)" != "$CrossMix_MinFwVersion" ]; then
	/usr/trimui/bin/trimui_inputd & # we need input
	Echo "Current firmware ($FW_VERSION) must be updated to $CrossMix_MinFwVersion to support CrossMix OS v$version."
	/mnt/SDCARD/System/bin/sdl2imgshow \
		-i "/mnt/SDCARD/trimui/firmwares/FW_Informations.png" \
		-f "/mnt/SDCARD/System/resources/DejaVuSans.ttf" \
		-s 30 \
		-c "220,220,220" \
		-t "Actual FW version: $FW_VERSION                                    Required FW version: $CrossMix_MinFwVersion" &
	sleep 2 # init input_d

	button=$("/mnt/SDCARD/System/usr/trimui/scripts/getkey.sh" A)
	pkill -f sdl2imgshow

	/mnt/SDCARD/System/bin/sdl2imgshow \
		-i "/mnt/SDCARD/trimui/firmwares/FW_Update_Instructions.png" \
		-f "/mnt/SDCARD/System/resources/DejaVuSans.ttf" \
		-s 30 \
		-c "220,220,220" \
		-t " " &

	button=$("/mnt/SDCARD/System/usr/trimui/scripts/getkey.sh" A B)
	pkill -f sdl2imgshow

	if [ "$button" = "A" ]; then
		/mnt/SDCARD/System/bin/sdl2imgshow \
			-i "/mnt/SDCARD/trimui/firmwares/FW_Copy.png" \
			-f "/mnt/SDCARD/System/resources/DejaVuSans.ttf" \
			-s 30 \
			-c "220,220,220" \
			-t "Please wait, copying Firmware v$CrossMix_MinFwVersion..." &
		FIRMWARE_PATH="/mnt/SDCARD/trimui/firmwares/1.0.4 hotfix - 20240413.awimg.7z"
		/mnt/SDCARD/System/bin/7zz x "$FIRMWARE_PATH" -o"/mnt/SDCARD" -y
		# cp "/mnt/SDCARD/trimui/firmwares/1.0.4 hotfix - 20240413.awimg" "/mnt/SDCARD/trimui_tg5040.awimg"
		sync
		sync
		pkill -f sdl2imgshow
		sleep 1
		sync
		poweroff
		sleep 30
		exit
	fi
	rm -f "/mnt/SDCARD/trimui_tg5040.awimg"
	pkill -f sdl2imgshow
else
	rm -f "/mnt/SDCARD/trimui_tg5040.awimg"

fi

################ CrossMix-OS Customization ################

if [ ! -e "/usr/trimui/fw_mod_done" ]; then
	# add pl language
	if [ ! -e "/usr/trimui/res/skin/pl.lang" ]; then

		cp "/mnt/SDCARD/trimui/res/lang/pl.lang" "/usr/trimui/res/lang/"
		cp "/mnt/SDCARD/trimui/res/lang/pl.lang.short" "/usr/trimui/res/lang/"
		cp "/mnt/SDCARD/trimui/res/lang/lang_pl.png" "/usr/trimui/res/skin/"
	fi

	# custom shutdown script from "Resume at Boot"
	cp "/mnt/SDCARD/System/usr/trimui/bin/kill_apps.sh" "/usr/trimui/bin/kill_apps.sh"

	touch "/usr/trimui/fw_mod_done"

	sync
fi
