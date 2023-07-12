#!/usr/bin/perl -w
use strict;
use File::Basename;
use Getopt::Long;
use FindBin qw/$Bin/;

sub USAGE
{
    my $usage=<<USAGE;

===============================================
Edit by Jidong Lang; E-mail: langjidong\@hotmail.com;
===============================================

Option
        -fq 		<Input_File>    	Input .fastq .fq file's
        -read_len  	<Extract Read Length>   Extract sequencing read length. Suggest more than 75bp
	-time		<Number of Swipes>	The number of swipes for the extract the reads
	-overlap_len	<Overlap Length>	The overlap length between Read1 and Read2
        -help   				print HELP message

Example:

perl $0 -fq test.fq -read_len 100 -time 10 -overlap_len 10


USAGE
}

unless(@ARGV>3)
{
    die USAGE;
    exit 0;
}


my ($fq,$read_len,$time,$overlap_len);
GetOptions
(
    'fq=s'=>\$fq,
    'read_len=i'=>\$read_len,
    'time=i'=>\$time,
    'overlap_len=i'=>\$overlap_len,
    'help'=>\&USAGE,
);

my $path=`pwd`;
$path=~s/\n//g;

open IN, "$fq" or die;

my @num;

while(<IN>)
{
	chomp;
	if(/^@/)
	{
		#print "$_\n";
		my $seq=<IN>;
		chomp $seq;
		my $plus=<IN>;
		my $qual=<IN>;
		chomp $qual;
		my $len=length($seq);
		my $tmp=int($len/$time);
		for(my $i=0;$i<$time;$i++)
		{
			my $start=int(rand($tmp))+$i*$tmp;
			push @num,$start;
			my $sub_seq1=substr($seq,$start,$read_len);
			my $sub_qual1=substr($qual,$start,$read_len);
			my $start_tmp=$start+$read_len-$overlap_len;
			my $sub_seq2=substr($seq,$start_tmp,$read_len);
			$sub_seq2=~tr/ATCG/TAGC/;
			$sub_seq2=reverse($sub_seq2);
			my $sub_qual2=substr($qual,$start_tmp,$read_len);
			$sub_qual2=reverse($sub_qual2);
			my $sub_seq_len1=length($sub_seq1);
			my $sub_seq_len2=length($sub_seq2);
			if($sub_seq_len1>=$read_len && $sub_seq_len2>=$read_len)
			{
				open OUT1, ">>$path/tmp.$i\_1.fq" or die;
				open OUT2, ">>$path/tmp.$i\_2.fq" or die;
				my @title=split(/\s+/,$_,2);
				#$title[0]=~s/^@/\@/g;
				#my $tmp_qual= "K" x $sub_seq_len;
				print OUT1 "$title[0]/1\n$sub_seq1\n+\n$sub_qual1\n";
				print OUT2 "$title[0]/2\n$sub_seq2\n+\n$sub_qual2\n";
			}
		}
	}
}

