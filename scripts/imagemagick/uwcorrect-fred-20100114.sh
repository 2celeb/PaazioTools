#!/bin/bash
#
# Developed by Fred Weinhaus 1/14/2010 .......... revised 1/14/2010
#
# USAGE: uwcorrect [-m method] [-b bright] [-c contrast] [-s sat] [-h hue] [-S sharp] infile outfile
# USAGE: uwcorrect [-H or -help]
#
# OPTIONS:
# 
# -m      method           method of red substitution; method=1 or 2; 
#                          method 1 uses -tint, method 2 uses +level-colors;
#                          default=1
# -b      bright           brightness change in percent; -100<=integer<=100; 
#                          default=0 (no change)
# -c      contrast         contrast change in percent; -100<=integer<=100; 
#                          default=0 (no change)
# -s      sat              saturation change in percent; -100<=integer<=100; 
#                          default=0 (no change)
# -h      hue              hue change in percent; -100<=integer<=100; 
#                          default=0; +-100 corresponds to +-180 deg
# -S      sharp       	   sharpening in pixels; integer>=0; default=0
#
###
#
# NAME: UWCORRECT 
# 
# PURPOSE: To correct the color balance for red light attenuation in 
# pictures taken underwater.
# 
# DESCRIPTION: UWCORRECT corrects the color balance for red light attenuation in 
# pictures taken underwater. It uses a red colorized grayscale version 
# of the image to compensate for the nearly dark red channel. 
# 
# OPTIONS: 
# 
# -m method ... METHOD is the technique for red substitution. Choices are 
# method=1 or 2. Method 1 uses -tint. Method 2 uses -level-colors. The default=1
# 
# -b bright ...  BRIGHT is the percent change in brightness. Values are integers 
# between -100 and 100. Positive values increase brightnesss and negative values 
# decrease brightness. The default is zero or no change.
# 
# -c contrast ...  Contrast is the percent change in contrast. Values are 
# integers between -100 and 100. Positive values increase contrast and 
# negative values decrease contrast. The default is zero or no change.
# 
# -s sat ...  Sat is the percent change in saturation. Values are integers 
# between -100 and 100. Positive values increase contrast and negative 
# values decrease contrast. The default is zero or no change.
# 
# -h hue ...  HUE is the percent change in hue. Values are integers between 
# -100 and 100 (corresponding to -180 deg and +180 deg shifts). Positive values 
# shift red towards yellow and green and negative values shift red toward 
# magenta and blue. Similarly for other colors. The default is zero or no change.
# 
# -S sharp ...  SHARP is the change in sharpness expressed in pixels. Values 
# are integers greater than or equal to 0. The default=0 or no sharpening.
# 
# NOTE: This script requires IM 6.5.9-0 or higher due if using 
# -brightness-contrast; otherwise IM 6.5.5-1 due to the use of -auto-level.
# 
# Technique References:
# http://www.scubaboard.com/forums/digital-darkroom/269939-faster-mandrake-method.html
# http://www.divester.com/2005/03/08/how-to-editing-underwater-photos-with-adobe-photoshop/
#
# CAVEAT: No guarantee that this script will work on all platforms, 
# nor that trapping of inconsistent parameters is complete and 
# foolproof. Use At Your Own Risk. 
# 
######
#

# set default values
method=1
bright=0
contrast=0
sat=0
hue=0
sharp=0


# set directory for temporary files
dir="."    # suggestions are dir="." or dir="/tmp"

# set up functions to report Usage and Usage with Description
PROGNAME=`type $0 | awk '{print $3}'`  # search for executable on path
PROGDIR=`dirname $PROGNAME`            # extract directory of program
PROGNAME=`basename $PROGNAME`          # base name of program
usage1() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^###/q;  /^#/!q;  s/^#//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}
usage2() 
	{
	echo >&2 ""
	echo >&2 "$PROGNAME:" "$@"
	sed >&2 -n '/^######/q;  /^#/!q;  s/^#*//;  s/^ //;  4,$p' "$PROGDIR/$PROGNAME"
	}


# function to report error messages
errMsg()
	{
	echo ""
	echo $1
	echo ""
	usage1
	exit 1
	}


# function to test for minus at start of value of second part of option 1 or 2
checkMinus()
	{
	test=`echo "$1" | grep -c '^-.*$'`   # returns 1 if match; 0 otherwise
    [ $test -eq 1 ] && errMsg "$errorMsg"
	}

# test for correct number of arguments and get values
if [ $# -eq 0 ]
	then
	# help information
   echo ""
   usage2
   exit 0
elif [ $# -gt 14 ]
	then
	errMsg "--- TOO MANY ARGUMENTS WERE PROVIDED ---"
else
	while [ $# -gt 0 ]
		do
			# get parameter values
			case "$1" in
		  -H|-help)    # help information
					   echo ""
					   usage2
					   exit 0
					   ;;
				-m)    # method
					   shift  # to get the next parameter - edge
					   # test if parameter starts with minus sign 
					   errorMsg="--- INVALID EDGE METHOD SPECIFICATION ---"
					   checkMinus "$1"
					   edge="$1"
					   [ $method -ne 1 -a $method -ne 2 ] && errMsg "--- METHOD=$method MUST BE EITHER 1 OR 2 ---"
					   ;;
				-b)    # get bright
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID BRIGHT SPECIFICATION ---"
					   #checkMinus "$1"
					   bright=`expr "$1" : '\([-0-9]*\)'`
					   [ "$bright" = "" ] && errMsg "--- BRIGHT=$bright MUST BE A INTEGER ---"
					   brighttestA=`echo "$bright < -100" | bc`
					   brighttestB=`echo "$bright > 100" | bc`
					   [ $brighttestA -eq 1 -o $brighttestB -eq 1 ] && errMsg "--- BRIGHT=$bright MUST BE A INTEGER BETWEEN -100 AND 100 ---"
					   ;;
				-c)    # get contrast
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID CONTRAST SPECIFICATION ---"
					   #checkMinus "$1"
					   contrast=`expr "$1" : '\([-0-9]*\)'`
					   [ "$contrast" = "" ] && errMsg "--- CONTRAST=$contrast MUST BE A INTEGER ---"
					   contrasttestA=`echo "$contrast < -100" | bc`
					   contrasttestB=`echo "$contrast > 100" | bc`
					   [ $contrasttestA -eq 1 -o $contrasttestB -eq 1 ] && errMsg "--- CONTRAST=$contrast MUST BE A INTEGER BETWEEN -100 AND 100 ---"
					   ;;
				-s)    # get sat
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID SAT SPECIFICATION ---"
					   #checkMinus "$1"
					   sat=`expr "$1" : '\([-0-9]*\)'`
					   [ "$sat" = "" ] && errMsg "--- SAT=$sat MUST BE A INTEGER ---"
					   sattestA=`echo "$sat < -100" | bc`
					   sattestB=`echo "$sat > 100" | bc`
					   [ $sattestA -eq 1 -o $sattestB -eq 1 ] && errMsg "--- SAT=$sat MUST BE A INTEGER BETWEEN -100 AND 100 ---"
					   ;;
				-h)    # get hue
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID HUE SPECIFICATION ---"
					   #checkMinus "$1"
					   hue=`expr "$1" : '\([-0-9]*\)'`
					   [ "$hue" = "" ] && errMsg "--- HUE=$hue MUST BE A INTEGER ---"
					   huetestA=`echo "$hue < -100" | bc`
					   huetestB=`echo "$hue > 100" | bc`
					   [ $huetestA -eq 1 -o $huetestB -eq 1 ] && errMsg "--- HUE=$hue MUST BE A INTEGER BETWEEN -100 AND 100 ---"
					   ;;
				-S)    # get sharp
					   shift  # to get the next parameter
					   # test if parameter starts with minus sign 
					   #errorMsg="--- INVALID SHARP SPECIFICATION ---"
					   #checkMinus "$1"
					   sharp=`expr "$1" : '\([0-9]*\)'`
					   [ "$sharp" = "" ] && errMsg "--- SHARP=$sharp MUST BE A NON-NEGATIVE INTEGER ---"
					   ;;
				 -)    # STDIN and end of arguments
					   break
					   ;;
				-*)    # any other - argument
					   errMsg "--- UNKNOWN OPTION ---"
					   ;;
		     	 *)    # end of arguments
					   break
					   ;;
			esac
			shift   # next option
	done
	#
	# get infile and outfile
	infile=$1
	outfile=$2
fi

# test that infile provided
[ "$infile" = "" ] && errMsg "--- NO INFILE FILE SPECIFIED ---"

# test that outfile provided
[ "$outfile" = "" ] && errMsg "--- NO OUTPUT FILE SPECIFIED ---"

tmpA1="$dir/uwcorrect_A_$$.mpc"
tmpA2="$dir/uwcorrect_A_$$.cache"
trap "rm -f $tmpA1 $tmpA2; exit 0" 0
trap "rm -f $tmpA1 $tmpA2; exit 1" 1 2 3 15

# read the input image into the TMP cached image.
convert -quiet -regard-warnings "$infile" +repage "$tmpA1" ||
	errMsg "--- FILE $infile NOT READABLE OR HAS ZERO SIZE ---"

# get IM version
im_version=`convert -list configure | \
	sed '/^LIB_VERSION_NUMBER /!d; s//,/;  s/,/,0/g;  s/,0*\([0-9][0-9]\)/\1/g'`
[ "$im_version" -lt "06050501" ] && errMsg "--- IM 6.5.5.1 OR HIGHER IS REQUIRED ---"

# set up arguments
if [ $method -eq 1 ]; then
	proc="-fill red -tint 50"
elif [ $method -eq 2 ]; then
	proc="+level-colors black,red"
fi

[ "$bright" != "0" -a "$im_version" -lt "06050900" ] && errMsg "--- IM 6.5.9.0 OR HIGHER IS REQUIRED ---"
[ "$contrast" != "0" -a "$im_version" -lt "06050900" ] && errMsg "--- IM 6.5.9.0 OR HIGHER IS REQUIRED ---"

sat=`convert xc: -format "%[fx:100+$sat]" info:`
hue=`convert xc: -format "%[fx:100+$hue]" info:`

if [ "$sat" != "0" -o "$hue" != "0" ]; then
	modulation="-modulate 100,${sat},${hue}"
else
	modulation=""
fi

if [ "$bright" != "0" -o "$contrast" != "0" ]; then
	bricon="-brightness-contrast ${bright},${contrast}"
else
	bricon=""
fi

if [ "$sharp" != "0" ]; then
	sharpening="-sharpen 0x${sharp}"
else
	sharpening=""
fi

echo "b=$bright; c=$contrast; s=$sat; h=$hue; S=$sharp;"

echo "proc=$proc;"
echo "modulation=$modulation"
echo "bricon=$bricon"
echo "sharpening=$sharpening"


# process image
convert \( $tmpA1 -auto-level \) \
\( +clone -colorspace gray $proc \) \
-compose screen -composite -channel rgb -auto-level +channel \
$bricon $modulation $sharpening $outfile

exit 0
