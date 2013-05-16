#!/usr/bin/perl

# Prints an ordered number slist useful for ordered indexes.

sub error{
	$err = shift;
	print "Error: $err 
Usage return_index.pl <positive integer>
Return Cfengine module array from 0 to given argument";
}

# validate
if ( scalar @ARGV > 1 ){
	error( "Too many arguements.");
	exit 1
}

$index_length = $ARGV[0];

if ( $index_length !~ m/^\d+$/ ){
	error( "Invalid arguement, integer expected." );
	exit 2
}

# main matter
print '@i= { ';

foreach $i ( 0 .. ($index_length - 1) ){
	print "'$i'";
	if ( $i < ($index_length - 1)) {
		print ', ';
	}
}

print "}\n";
