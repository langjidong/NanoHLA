#! /usr/bin/perl -w
use strict;
use warnings;
#Edit by Jidong Lang
#E-mail: langjidong@hotmail.com

if(@ARGV!=3)
{
	print "perl $0 <blast_m8_dir> <length_info> <output>\n";
	exit;
}
open IN1, "$ARGV[0]" or die;
open IN2, "$ARGV[1]" or die;
open OUT, ">$ARGV[2]" or die;

my (@tmp,@k1,@k2,@k3,@k4,@k5,@k6,@k7,@k8,@k9,@k10,@k11,@k12,@tmp1,@t1,@t2);
my ($i,$j,$cutoff);

while(<IN1>)
{
	chomp;
	@tmp=split;
	push @k1,$tmp[0];
        push @k2,$tmp[1];
        push @k3,$tmp[2];
        push @k4,$tmp[3];
        push @k5,$tmp[4];
        push @k6,$tmp[5];
        push @k7,$tmp[6];
        push @k8,$tmp[7];
        push @k9,$tmp[8];
        push @k10,$tmp[9];
        push @k11,$tmp[10];
        push @k12,$tmp[11];
}

while(<IN2>)
{
	chomp;
	@tmp1=split;
	$tmp1[0]=~s/^>//g;
	push @t1,$tmp1[0];
	push @t2,$tmp1[1];
}

for($i=0;$i<@k1;$i++)
{
	for($j=0;$j<@t1;$j++)
	{
		$cutoff=$t2[$j]-2;
		if($k1[$i] eq $t1[$j] && $k3[$i]>=90 && $k5[$i]<=1 && $k6[$i]<=1 && $k7[$i]<=2 && $k8[$i]>=$cutoff)
		{
			print OUT "$k1[$i]\t$k2[$i]\t$k3[$i]\t$k4[$i]\t$k5[$i]\t$k6[$i]\t$k7[$i]\t$k8[$i]\t$k9[$i]\t$k10[$i]\t$k11[$i]\t$k12[$i]\n";
		}
	}
}
