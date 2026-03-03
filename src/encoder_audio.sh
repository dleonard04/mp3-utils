#!/bin/sh
# author: nicola fankhauser (nicola.fankhauser@variant.ch)
# license: GPL
#
# about: encodes one wavefile to multiple versions
#        (here to MP3 and FLAC)
#
################################################################################
# Modified by dleonard@dleonard.net
# Shell variables that can be set externally
# DEBUG=1
# QUIET=1
# MUSIC=<DIR>
#
# grip setup
#  Config->MP3->Encoder
#   Encoder: Other
#   MP3 executable: encoder_audio.sh
#   MP3 command-line: "%w" "%m" %n %a %d %y %t %g
#   MP3 file format: ~/music/%A/%d/%t-%n
################################################################################

# Command line arguments (first is $1, second $2 etc.)
# Strip special chars grip doesn't strip if necessary
WAVSOURCE=$1
DESTINATION=$2
TITLE=`echo $3 | sed 's/[)(]//g'`
ARTIST=`echo $4 | sed 's/[)(]//g'`
ALBUM=`echo $5 | sed 's/[)(]//g'`
YEAR="$6"
TRACK="$7"
GENRE=`echo $8 | sed 's/[)(]//g'`

if [ ! "$MUSIC" ]; then
 MUSIC="$HOME/music"
fi

DEBUG_LOG="$MUSIC/debug.log"
FLAC_LOG="$MUSIC/flac.log"
MP3_LOG="$MUSIC/lame.log"

if [ "$QUIET" ]; then
 FLAC_LOG="/dev/null"
 MP3_LOG="/dev/null"
fi

# Set the mp3 and flac destinations based on subdirectories
mp3_dest=`echo $DESTINATION.mp3 | sed 's/music/music\/mp3/'`
flac_dest=`echo $DESTINATION.flac | sed 's/music/music\/flac/'`

# Make sure mp3 and flac directory structures exist
mp3_dir=`echo $mp3_dest | sed 's/[^\/]*$//'`
mkdir -p $mp3_dir
flac_dir=`echo $flac_dest | sed 's/[^\/]*$//'`
mkdir -p $flac_dir

if [ "$DEBUG" ]; then
 echo "mp3_dest: $mp3_dest" >>$DEBUG_LOG
 echo "mp3_dir: $mp3_dir" >>$DEBUG_LOG
 echo "flac_dest: $flac_dest" >>$DEBUG_LOG
 echo "flac_dir: $flac_dir" >>$DEBUG_LOG
fi

# MP3 encoding (max quality vbr settings)
MP3ENC="lame --vbr-new -q 0 -V 0 -b 32 -B 320 -S "

$MP3ENC "$WAVSOURCE" "$mp3_dest" 2>> $MP3_LOG

if [ "$DEBUG" ]; then
 echo "$MP3ENC $WAVSOURCE $mp3_dest" >>$DEBUG_LOG
fi

# Set id3 tag
id3v2 --song "$TITLE" --artist "$ARTIST" \
      --album "$ALBUM" --year $YEAR \
      --track $TRACK --genre "$GENRE" "$mp3_dest"

# FLAC encoding (best quality, slowest)
FLACENC="flac --best -s "

$FLACENC $WAVSOURCE -o $flac_dest 1>&2 2>> $FLAC_LOG

if [ "$DEBUG" ]; then
 echo "$FLACENC $WAVSOURCE -o $flac_dest"  >>$DEBUG_LOG
fi

# Set id3 tag
id3v2 --song "$TITLE" --artist "$ARTIST" \
      --album "$ALBUM" --year $YEAR \
      --track $TRACK --genre $GENRE "$flac_dest"
