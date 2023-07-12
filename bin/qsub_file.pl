#!usr/bin/perl -w
use strict;
use File::Basename;
unless (@ARGV==1)
{
    die "perl $0 <filelist>\n";
}

my $sh_total_num = 0;
my @file = `less $ARGV[0]`;
chomp @file;
#print "@filename\n";
foreach (@file)
{
    my $filename = basename $_;
    chdir "$filename" or die "can't find the $filename.\n";
    `nohup ls *.sh|while read a;do sh \${a} > \${a}.log 2>\&1;done \&`;
    my $sh_num=`ls *.sh|wc -l`;
    chdir "../";
    $sh_total_num = $sh_total_num + $sh_num;
#    sleep 10;
}
    print "$sh_total_num\n";
