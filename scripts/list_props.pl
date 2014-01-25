#***********************************************************************
# Created by Andreas Paffenholz on 18/01/14.
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
# list_props.pl
# PolyViewer
#**************************************************************************/

use application "common";

my $p = shift;
my @props = ();

foreach ( @{$p->contents} ) {
    
	next if !defined($_) || $_->property->flags & $Core::Property::is_non_storable;

	my $prop = new Pair<String,Array<Bool>>;
    
	$prop->first=$_->property->qual_name;
	$prop->second = new Array<Bool>(2);

	if ( instanceof Core::Object($_->value) ) {
	    $prop->second->[0] = 1;
	}
    
	if ($_->property->flags & $Core::Property::is_multiple ) {
	    $prop->second->[1] = 1;
	}
    
	push @props, $prop;
}

return @props;
