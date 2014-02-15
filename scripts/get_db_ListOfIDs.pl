#***********************************************************************
# Created by Andreas Paffenholz on 05/02/14.
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
# get_type.pl
# PolyViewer
#**************************************************************************/


use application "common";

my $db_name = shift;
my $coll_name = shift;
my $amount = shift;
my $start = shift;
my $additional_props=shift;

my @ids = eval{ @{poly_db_ids({eval($additional_props)}, db=>$db_name, collection=>$coll_name, limit=>$amount, skip=>$start)}; };

if ( $@ ) {
    $ids[0] = "ERROR : $@";
}

return @ids;