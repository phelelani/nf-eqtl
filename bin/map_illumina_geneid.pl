#!/usr/bin/perl -w

my ($probe, $matrix) = @ARGV;

open (IN1,"<", "$probe") or die "Cannot open $probe !\n";
open (IN2,"<", "$matrix") or die "Cannot open $matrix !\n";
open (OUT,">tmp_list") or die "Cannot write into tmp_list!\n";
@p_c=<IN1>;
@genexp=<IN2>;
chomp @p_c;
chomp @genexp;
%ilmn_gene=();
for ($i=1;$i<@p_c;$i++)
{
	$p_c[$i]=~s/\r//g;
	@a=split('\t',$p_c[$i]);
	#print "$a[13]\t$a[4]\n";
	$ilmn_gene{$a[13]}=$a[4];
}

for($j=0;$j<@genexp;$j++)
{
	$genexp[$j]=~s/\r//g;
	@b=split("\t",$genexp[$j]);
	print OUT "$ilmn_gene{$b[0]}\n";
}
