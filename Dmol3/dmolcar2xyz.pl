#!/usr/bin/perl -w
#Time-stamp: <zhao240 11/08/2010 22:13:58>
# dmolcar2xyz.pl --- ZEVAN
# Author: zevan <zevan@zevan.tsinghua.edu.cn>
# Created: 08 Nov 2010
# Version: 0.01

use warnings;
use strict;
#This script is written to convert the dmollcar file to an XYZ file for geometry optimization.
#It is written for using cp2k.
#Well, Using an cif file-->POSCAR-->XYZ file also works. I just want to did it in another way.
#Just a little practice.

my $line;
my @array;
my @list;
my $num=0;
open (IN,"<","$ARGV[0]")|| die "Open file $ARGV[0] failed:$!";
while ($line=<IN>) {
    chomp($line);
    @array=split(/\s+/,$line);
    if (@array == 9) {
        $num++;
        push(@list,[$array[7],$array[1],$array[2],$array[3]]); 
        }
}
print "$num\n";
print "Generated with dmolcar2xyz.pl\n";
for my $atom(@list) {
    printf("%-6s%-10.6f %-10.6f %-10.6f\n",$atom->[0],$atom->[1],$atom->[2],$atom->[3] );
}

__END__

=head1 NAME

dmolcar2xyz.pl - Describe the usage of script briefly

=head1 SYNOPSIS

dmolcar2xyz.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for dmolcar2xyz.pl, 

=head1 AUTHOR

zevan, E<lt>zevan@zevan.tsinghua.edu.cnE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by zevan

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
