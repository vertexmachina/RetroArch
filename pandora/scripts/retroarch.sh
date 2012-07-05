#!/bin/sh

source "/mnt/utmp/retroarch/scripts/env-vars.sh"

# choose a libretro core.
cd /mnt/utmp/retroarch/lib
BACKEND=$(ls -1 libretro*.so | zenity --list --column=Backend)
cd $HOME

# if user didn't select a libretro, bail out.
[ -z "$BACKEND" ] && exit 0

# narrow down the available file formats for the file chooser.
FILTER='All files (*)|*'
case "$BACKEND" in
	libretro-fceu*.so)
		FILTER='NES (*.nes)|*.nes'
		;;
	libretro-pocketsnes.so | libretro-snes9x*.so)
		FILTER='SNES (*.sfc)|*.sfc'
		;;
	libretro-gambatte.so)
		FILTER='GBC (*.gb; *.gbc)|*.gb *.gbc'
		;;
	libretro-meteor.so | libretro-vba.so )
		FILTER='GBA (*.gba)|*.gba'
		;;
	libretro-imame4all.so) # does libretro-fba.so belong here?
		FILTER='Arcade (*.zip)|*.zip'
		;;
	libretro-genplus.so)
		FILTER='Genesis/MegaDrive (*.md; *.gen)|*.md *.gen'
		;;
	libretro-prboom.so)
		FILTER='Doom (*.wad)|*.wad'
		;;
esac

# try to point the file chooser at the last used path, if there is one.
LASTROM=
if [ -r "${BACKEND}-lastrom.txt" ] ; then
	LASTROM="--filename="$(head -1 "${BACKEND}-lastrom.txt")
fi

ROM=$(zenity --file-selection --file-filter="${FILTER}" "${LASTROM}")

# if user didn't select a ROM, bail out.
[ -z "$ROM" ] && exit 0

echo "$ROM" > "${BACKEND}-lastrom.txt"

# preload my modified SDL that knows what "pixelperfect" is
exec env LD_PRELOAD=/mnt/utmp/retroarch/lib/libSDL-1.2.so.0.11.3 retroarch "${ROM}" -L "/mnt/utmp/retroarch/lib/${BACKEND}" "${@}"

