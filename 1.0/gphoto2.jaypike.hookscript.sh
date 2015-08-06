#!/bin/sh

self=`basename $0`
date=$( date +%Y%m%d )

if [ -f /tmp/jay.file.txt ]; then
	directory=`cat /tmp/jay.file.txt`
else
	directory=$date
fi

if [ ! -d ./$directory ]; then
	mkdir -p $directory
fi

case "$ACTION" in
	init)
		#echo "$self: INIT"
		# exit 1 # non-null exit to make gphoto2 call fail
		;;
	start)
		#echo "$self: START"
		;;
	download)
		ext=$(echo "$ARGUMENT" | cut -d. -f2)
		name=$(echo "$ARGUMENT" | cut -d. -f1)
		capturetime=$(/opt/local/bin/exif -t 0x9003 "$ARGUMENT" | grep Value: | sed 's/[ :]//g' | sed 's/Value//')
		camera=$(/opt/local/bin/exif -t 0x0110 "$ARGUMENT" | grep Value: | sed 's/[ :]//g' | sed 's/Value//' | sed 's/NIKON/Nikon-/')
		new=$capturetime.$camera.$name.$ext
		echo "$self: DOWNLOADING to $directory/$new"
		#/opt/local/bin/convert $ARGUMENT -quality 75 -compress JPEG2000 $directory/$new && chmod a=r,ug+w $directory/$new && open -R $directory/$new &
		/opt/local/bin/convert $ARGUMENT -quality 75 -compress JPEG2000 $directory/$new && chmod a=r,ug+w $directory/$new && rm $ARGUMENT && open -R $directory/$new &
#		mv "$ARGUMENT" $directory/$new
		;;
	stop)
		#echo "$self: STOP"
		;;
	*)
		echo "$self: Unknown action: $ACTION"
		;;
esac

exit 0
