#!/bin/sh -x
################################################################################
# m3u_creator.sh
#  Simplistic commandline script to crawl a specified directory structure and
#  create an m3u for each directory, and optionally its subdirectories.
#
# Copyright 2009 by dleonard@dleonard.net
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.  The author
# would appreciate it if any useful modifications performed were emailed
# to the maintainer as a unified dif in order to make the tool more useful
# to others.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
################################################################################
MUSIC_DIR=$1
if [ "$MUSIC_DIR" = "" ]; then
 MUSIC_DIR="$PWD"
fi

################################################################################
# generate_local_m3u
# I: dir
#
# cd into a directory, look up all files in that directory, and create an m3u
# relative to that directory structure, named the same thing as the directory
################################################################################
generate_local_m3u() {
 local dir="$1"

 local filename=`echo "$dir" | sed 's/\.\///' | sed 's/ /_/g'`
 filename="${filename}.m3u"

 cd $dir

 find . -type f |grep -v "\.m3u" >$filename

 local local_dirs=`find . -maxdepth 1 -type d`
 local i
 for i in $local_dirs; do
  if [ "$i" != "." ]; then
   generate_local_m3u $i
   cd $dir
  fi
 done
}

generate_local_m3u $MUSIC_DIR
