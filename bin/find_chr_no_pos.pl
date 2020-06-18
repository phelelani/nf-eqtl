#!/usr/bin/perl -w
open (IN1,"<GPL_chr.txt") or die "Cannot open GPL_chr.txt!\n";
open (OUT1,">gene_loc_tmp.txt") or die "Cannot write into gene_loc_tmp.txt!\n";
#open (OUT2,">chr_position.txt") or die "Cannot write into chr_position.txt!\n";
#open (OUT3,">gene_name.txt") or die "Cannot write into gene_name.txt!\n";
@gpl=<IN1>;
chomp @gpl;
for($i=1;$i<@gpl;$i++)
{
	$gpl[$i]=~s/\r//g;
	@a=split('\t',$gpl[$i]);
	#print OUT1 "chr$a[18]\n";
	if ($a[20]=~/:/)
	{
		@c=split(':',$a[20]);
		for($j=0;$j<@c;$j++)
		{
			@d=split('-',$c[$j]);
			print OUT1 "$a[4]\tchr$a[18]\t$d[0]\t$d[1]\n";
		}
	}
	else
	{
		@b=split('-',$a[20]);
		print OUT1 "$a[4]\tchr$a[18]\t$b[0]\t$b[1]\n";
	}
	
}
