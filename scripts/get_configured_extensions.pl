#***********************************************************************
# Created by Andreas Paffenholz on 14/02/14.
# Copyright 2012-2014 by Andreas Paffenholz.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 2, or (at your option) any
# later version: http://www.gnu.org/licenses/gpl.txt.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# get_configured_extensions.pl
# PolyViewer
#**************************************************************************/


use application "common";

# list of extensions that have been installed
my @a = @extensions;

# we need to remove all extensions not configured for the current architecture
foreach (reverse 0..$#extensions) {
    if ( $disabled_extensions{$a[$_]} == 1 ) {
        splice(@a,$_,1);
    }
}
    
foreach (@a) { $_=`cat $_/polymake.ext | egrep ^URI`; $_=~ s/.*\///; $_=~s/\#.*//; chomp; }

return @a;