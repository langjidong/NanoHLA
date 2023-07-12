#! /usr/bin/perl -w
use strict;
use warnings;
use List::Util "max";
#Edit by Jidong Lang
#E-mail: langjidong@hotmail.com

if(@ARGV!=2)
{
	print "perl $0 <input> <output>\n";
	exit;
}
open TMP, "less $ARGV[0]|awk '{print \$2}'|sort|uniq -c|sort -rnk1|" or die;
open OUT, ">$ARGV[1]" or die;

my (@tmp,@k1,@k2);
my ($i,$j,$max);

while(<TMP>)
{
	chomp;
	@tmp=split;
	push @k1,$tmp[0];
        push @k2,$tmp[1];
}

$max=max(@k1);

for($i=0;$i<@k1;$i++)
{
	if($k1[$i]==$max)
	{
		print OUT "$k1[$i]\t$k2[$i]\n";
	}
}
