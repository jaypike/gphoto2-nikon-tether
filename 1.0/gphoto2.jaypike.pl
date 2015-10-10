#!/usr/bin/env perl

# Author: Jay Pike <me@jpike.net>
# Date: June 14, 2013
# Purpose: To control cameras using gphoto2

use strict;
use Symbol qw( gensym );        # Get gensym for file handles

# Global Defines
my $pid = $$;
my $programname = $0;
my $SUCCESS = 0;
my $FAILURE = 1;
my %hash = ();
my $filehandle = gensym();
my $lagtime = 0;

# Commands
my $gphoto2_command			= '/opt/local/bin/gphoto2';
my $date_command				= '/bin/date';
my $pgrep_command				= '/usr/bin/pgrep';

# Main Subroutine (top down)
if ( -x $gphoto2_command ) {
	system ( "sudo pkill -9 -f usbd usbmuxd USBAgent PTPCamera" );

	# Lets get a list of the current cameras
	open $filehandle, "$gphoto2_command --auto-detect |" or die "Error executing command: $gphoto2_command! $!\n";

	while ( my $aline = <$filehandle> ) {
		chomp $aline;

		# Let's skip the tag lines
		next if ( $aline =~ m/^(Model|\-\-\-)/ );

		if ( $aline =~ m/^.*(usb:\d+.*)$/ ) {
			my $temp = $1;
			$temp =~ s/\s//g;
			$hash{'device'}{$temp}++;
		}
	}

	close $filehandle;	

	open $filehandle, "$date_command +%z |" or die "Error executing command: $date_command! $!\n";

	my ( $sign, $hours, $mins ) = ( <$filehandle> =~ m/^(.)(..)(..)/ );

	close $filehandle;

	my $offset = 60 * ($hours * 60 + $mins);
	
	$offset = -$offset if ($sign eq '-');

# Having TZ issues with newer Nikons - THey like to be set to GMT
$offset=0;

	foreach my $usbid ( sort keys %{ $hash{'device'} } ) {
		open $filehandle, "$pgrep_command -f $usbid | wc -l |" or die "Error running pgrep! $!";

		my ( $proc_count ) = ( <$filehandle> =~ m/(\d+)/ );

		close $filehandle;

		if ( $proc_count == 0 ) {
			my $foundtime; 

			my $lagtime_start = time;

			open $filehandle, "$gphoto2_command --port $usbid --get-config /main/settings/datetime |" or die "Error executing command $gphoto2_command! $!";

			while ( my $aline = <$filehandle> ) {
				chomp $aline;

				if ( $aline =~ m/^Current: (\d+)/ ) {
					$foundtime = $1;
				}
			}

			close $filehandle;

			my $lagtime_stop = time;

			$lagtime = $lagtime_stop - $lagtime_start;

			$lagtime = $lagtime - 9 if $lagtime > 15;

			my $time = time;
			my $t = $time + $offset + $lagtime;

			if ( $foundtime != $t ) {
				my $adjust;
				$adjust = '+' . $foundtime-$t if $foundtime > $t;
				$adjust = '-' . $t-$foundtime if $t > $foundtime;

				print "Adjusting camera time by $adjust seconds for $usbid\n";
				print "Offset: $offset, time $time and adjtime: $t and lagtime: $lagtime\n";

				system("$gphoto2_command --port $usbid --set-config /main/settings/datetime=$t");
			}

			system("$gphoto2_command --port $usbid -P -D -R --hook-script=/Users/jaypike/Camera/gphoto2.jaypike.hookscript.sh 2>&1 1>>gphoto2.log");
			system("$gphoto2_command --port $usbid --hook-script=/Users/jaypike/Camera/gphoto2.jaypike.hookscript.sh --capture-tethered --folder=/tmp  2>&1 1>>gphoto2.log &");
		}
		else {
			print "Skipping $usbid: Process already attached\n";
		}
	}
}
else {
	die "Error locating command: $gphoto2_command!";
	exit $FAILURE;
}
