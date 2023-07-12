#!/usr/bin/perl -w
use strict;
unless(@ARGV)
{
	die "<fa file> <output file>\n";
}
open(IN,"<$ARGV[0]")or die;
open(OUT,">$ARGV[1]")or die;
my $cnt;
while(<IN>)
{
	chomp;
	if($_=~/^>/){
		if(defined $cnt)
		{
			print OUT "$cnt\n";
		}
		print OUT "$_\t";
		$cnt=0;
	}
	else{$cnt+=length($_);}
}
print OUT "$cnt\n";

