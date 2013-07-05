#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  hg19tohg18.pl
#
#        USAGE:  ./hg19tohg18.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Ruoyan Chen (cry), chenruoyan@genomics.cn
#      COMPANY:  BGI Shenzhen
#      VERSION:  1.0
#      CREATED:  03/10/2011 10:04:09 AM
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

die "perl $0 <in.addref> <out.addref>\n"unless(@ARGV==2);
my $in = shift;
my $out = shift;

open I, "gzip -dc $in|"||die$!;
open OA, ">$out.pos"||die$!;
while (<I>){
	chomp;
	if (/pos|#/) {
		next;
	}
	my @line = split/\s+/,$_;
	#my ($chr,$pos) = split/:/, $line[0];
	#print OA "$chr:$pos-$pos\n";
	print OA "chr$line[0]:$line[1]-$line[1]\n";

}
close OA;
close I;

`/ifs1/ST_SYSBIO/USER/chenry/dustbin/hp/bin/pub/hg18hg19/liftOver.txt $out.pos /ifs1/ST_SYSBIO/USER/chenry/dustbin/hp/bin/pub/hg18hg19/hg18ToHg19.over.chain.gz $out.pos.map $out.pos.unmap -positions`;
#`/ifs1/HP/GROUP/chenry/bin/pub/hg18hg19/liftOver.txt $out.pos /ifs1/HP/GROUP/chenry/bin/pub/hg18hg19/hg18ToHg19.over.chain.gz $out.pos.map $out.pos.unmap -positions`;

my %unmap;
open U, "$out.pos.unmap"||die$!;
while (<U>){
	chomp;
	if (/(chr.*:\d+)-\d+/) {
		$unmap{$1} = "";
		#print "$1 ";
	}
}
close U;

my @pos;
open P, "$out.pos.map"||die$!;
while (<P>){
	chomp;
	push @pos, $_;
}
close P;

open I, "gzip -dc $in|"||die$!;
open O, ">$out"||die$!;
my $n = 0;
while (<I>){
	if (/pos|#/) {
		print O $_;
		next;
	}
	chomp;
	my @line = split/\s+/,$_;
	
	if (exists $unmap{"chr".$line[0].":".$line[1]}) {
		#print "$line[1] ";
		next;
	}

	shift @line;
	shift @line;
	my $ref = shift @line;
	my $geno = join"\t", @line;

	my $pos = $pos[$n];
	my ($chr,$posa)= split/:/,$pos;
	my $posb = (split/-/,$posa)[0];
	
	my $prt = join"\t",@line;
	#print O "$chr:$posb\t$prt\n";
	print O "$chr\t$posb\t$ref\t$geno\n";

	$n++;
}
close O;
close I;

=cut
if ($out =~ /\//) {
	my @out = split/\//,$out;
	pop @out;
	my $outdir = join"/",@out;
	`rm $outdir/liftOver*.bed*`;
}else{
	`rm liftOver*.bed*`;
}

`rm $out.pos*`;
