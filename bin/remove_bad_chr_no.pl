#!/usr/bin/perl -w
open (IN1,"<gene_loc_tmp.txt") or die "Cannot open gene_loc_tmp.txt!\n";
open (OUT1,">gene_location_file.txt") or die "Cannot write into gene_location_file.txt!\n";
open (OUT2,">bad_chr.txt") or die "Cannot write into bad_chr.txt!\n";
#to remove rows from the geneloc file that have bad chr_numbers (with _and | in them)
@geneloc=<IN1>;
chomp @geneloc;
for ($i=0;$i<@geneloc;$i++)
{
	$geneloc[$i]=~s/\r//g;
	@a=split('\t',$geneloc[$i]);
	if ($a[1]=~/_/g)
	{
		print OUT2 "$geneloc[$i]\n";
	}
	else
	{
		print OUT1 "$geneloc[$i]\n";
	}
}
