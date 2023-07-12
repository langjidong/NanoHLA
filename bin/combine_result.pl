#! /usr/bin/perl -w
use strict;
use warnings;
use List::Util "max";
#Edit by Jidong Lang
#E-mail: langjidong@hotmail.com

if(@ARGV!=3)
{
	print "perl $0 <result_file> <coverage_file> <output>\n";
	exit;
}
open TMP1, "less $ARGV[0]|awk '{print \$2}'|sort|uniq -c|sort -rnk1|" or die;
open TMP2, "less $ARGV[1]|sed '\$d'|sed '\$d'|sed '\$d'|sed '\$d'|sed '\$d'|sed '\$d'|" or die;
open OUT, ">$ARGV[2]" or die;

my (@tmp1,@k1,@k2,@tmp2,@t1,@t2,@t3);
my ($i,$j);

while(<TMP1>)
{
	chomp;
	@tmp1=split;
	push @k1,$tmp1[0];
        push @k2,$tmp1[1];
}

while(<TMP2>)
{
	chomp;
	@tmp2=split;
	$tmp2[0]=~s/:$//g;
	$tmp2[2]=~s/Percentage://g;
	$tmp2[3]=~s/Depth://g;
	push @t1,$tmp2[0];
	push @t2,$tmp2[2];
	push @t3,$tmp2[3];
}

for($i=0;$i<@k1;$i++)
{
	for($j=0;$j<@t1;$j++)
	{
		if($k2[$i] eq $t1[$j])
		{
			print OUT "$k2[$i]\t$k1[$i]\t$t1[$j]\t$t2[$j]\t$t3[$j]\n";
		}
	}
}
