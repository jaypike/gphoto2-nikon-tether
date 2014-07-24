gphoto2-nikon-tether
====================

Multi Tethering for Nikon (though possibly any camera manufacturer) to Set Time and Auto Download Images

Date: July 24, 2014
Version: 1.0

Requirements:

	- Runs on MacOS (Should be able to run on others as well)
	- 'exif' from MacPorts installed in '/opt/local/bin'


Script: gphoto2.jaypike.hookscript.sh

	The primary function of this hook script is for the 'download'
action.  The download action performs the following functions:

	* Uses '/opt/local/bin/exif' to detemine the exact time the image was
	  captured
	* Also uses '/opt/local/bin/exif' to capture the camera model name
	* Renames the gphoto2 downloaded image to a potential directory name
	  listed in '/tmp/jay.files.txt' (feel free to change this) or it
	  writes to a YYYYMMDD named directory in the current working
	  directory
	* Issues the 'open' Mac command on any downloaded file to pull
	  up the most recently downloaded image in Finder.  This can be
	  commented out if not desired, but, if you open the image preview
	  function within Finder, each time a new image is downloaded, it
	  will show up in preveiw.  If you Full-Size the Preveiw application
	  this will give you a full screen image

Script: gphoto2.jaypike.pl

	This is the bulk of the functions:

	* Kills off any 'PTPCamera' daemons that may be locking any USB
	  camera ports
	* Detects all attached PTP cameras and forks background processes
	  for each of the following steps (in order):

  	  * Checks the date on each camera, determines a 'lagtime' delay for
	    writing information to the camera and sets the time to match the
	    local host's time
	  * Downloads any images on the camera using the hookscript
	  * Puts gphoto2 into 'capture-tethered' mode and uses the
	    'hookscript' to download and process each image


