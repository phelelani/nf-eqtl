#!/usr/bin/perl -w
my ($probe) = @ARGV;

open (IN1,"<", "$probe") or die "Cannot open $probe !\n";
open (OUT1,">GPL_chr.txt") or die "Cannot write into GPL_chr.txt!\n"; #stores lines with choromosome coordinates
open (OUT2,">GPL_no_chr.txt") or die "Cannot write into GPL_no_chr.txt!\n"; #stores lines with no chromosome coordinates
@gpl=<IN1>;
chomp @gpl;
for ($i=0;$i<@gpl;$i++)
{
	$gpl[$i]=~s/\r//g;
	@a=split('\t',$gpl[$i]);
	if ($a[20]eq"")
	{
		print OUT2 "$gpl[$i]\n";
	}
	else
	{
		print OUT1 "$gpl[$i]\n";
	}
}
