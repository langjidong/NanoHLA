#! /usr/bin/perl -w
use strict;
use warnings;
use List::Util "max";
#Edit by Jidong Lang
#E-mail: langjidong@hotmail.com

if(@ARGV!=2)
{
	print "perl $0 <Coverage_File> <output>\n";
	exit;
}
open IN, "head -n -6 $ARGV[0]|" or die;
open OUT, ">$ARGV[1]" or die;

my (@tmp,@k1,@k2,@k3,@k4);
my ($i,$j,@tmp1,$max);

while(<IN>)
{
	chomp;
	@tmp=split;
	push @k1,$tmp[0];
        push @k2,$tmp[1];
        push @k3,$tmp[2];
        push @k4,$tmp[3];
}

for($j=0;$j<@k4;$j++)
{
	$k4[$j]=~s/Depth://g;
	if($k4[$j]!~/nan/)
	{
		push @tmp1,$k4[$j];
	}
}

$max=max(@tmp1);

for($i=0;$i<@k1;$i++)
{
	$k1[$i]=~s/HLA://g;
	$k3[$i]=~s/Percentage://g;
	$k4[$i]=~s/Depth://g;
	#$max=~s/(.*)e\+(.*)/$2/g;
	if($k4[$i]!~/nan/ && $k3[$i]>=90 && $k4[$i]=~/e\+/)
	{
		print OUT "$k1[$i]\t$k3[$i]\t$k4[$i]\n";
	}
}
