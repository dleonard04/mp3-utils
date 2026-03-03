#!/usr/bin/perl
use strict;
################################################################################
# fix_mp3.pl
#  Crappy little script for getting rid of irritating characters in mp3 file and
#  directory names.
#
# Copyright 2004-13 by dleonard@dleonard.net
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

my $basedir = '.';

if (scalar @ARGV) {
 $basedir = shift @ARGV;
}

if (! -d $basedir) {
 fatal("Directory [$basedir] not present or not readable.");
}

my @dirs = get_dirs($basedir);
my @files = get_files($basedir);

foreach my $file (@files) {
 clean_name($file);
}

###############################################################################
# fatal
# I: @messages
###############################################################################
sub fatal {
 foreach (@_) {
  print STDERR "Error: $_\n";
 }
 exit 1;
}

###############################################################################
# Get dirs
# I: $dir
# O: array of subdirectories
###############################################################################
sub get_dirs {
 my $dir = shift;

 if (!opendir(DIR, $dir)) {
  fatal("Unable to open directory [$dir]; $!");
 }

 my @dirs = grep {-d $dir . '/' . $_ && !/^\.+/} readdir(DIR);
 close DIR;

 my @full_dirs = map {$dir . '/' . $_} @dirs;
 return @full_dirs;
}

###############################################################################
# Get files
# I: $dir
# O: array of files
###############################################################################
sub get_files {
 my $dir = shift;

 if (!opendir (DIR, $dir)) {
  fatal("Unable to open directory [$dir]; $!");
 }

 my @files = grep {-f $dir . '/' . $_ && !/^\.+/} readdir(DIR);
 close DIR;

 my @full_files = map {$dir . '/' . $_} @files;
 return @full_files;
}

###############################################################################
# Clean a file or directory name
# I: $entry
###############################################################################
sub clean_name {
 my $entry = shift;

 my $f_new = $entry;

 # Strip extra .mp3 or flac off end
 $f_new =~ s/(.+\.mp3)\.mp3/$1/;
 $f_new =~ s/(.+\.flac)\.flac/$1/;

 # Replace spaces or | w/ _
 $f_new =~ s/[|\s]+/_/g;

 # Get rid of ' " \ [ ] ( )
 $f_new =~ s/[\'\"\\\[\]\(\)]//g;

 # Replace & with and
 $f_new =~ s/\&+/and/g;

 # Escape the original file
 $entry =~ s#[ \\\(\)\&\"\']#\\$&#g;

 if ($entry ne $f_new) {
  `mv $entry $f_new`;

  if ($?) {
   fatal "Failed 'mv $entry $f_new'; $!";
  }
 }
}
