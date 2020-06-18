#!/usr/bin/perl -w
use POSIX qw/floor/;

my ($bim, $genotype) = @ARGV;

open (IN1,"<", "$bim") or die "Cannot open $bim!\n";
open (IN2,"<", "$genotype") or die "Cannot open $genotype!\n";
open (OUT1,">tmp") or die "Cannot write into tmp!\n";
#open (OUT2,">GE_nn_bad_chr.txt") or die "Cannot write into GE_nn_bad_chr.txt!\n";
#to remove rows from the GE_nn_1 file that have bad chr_numbers (from bad-chr.txt)
@gsesnp=<IN1>;
chomp @gsesnp;
@gen4=<IN2>;
chomp @gen4;
my @lines;
my @sorted;
my @index;


for ($j=0;$j<@gen4;$j++)
{
	$gen4[$j]=~s/\r//g;
	if ($gen4[$j] eq "")
	{
	}
	else
	{
		@splitgen4=split('\t',$gen4[$j]);
		@temparray= [$splitgen4[0], $j];
		push @lines, @temparray;
	}
}

#print "@lines";

@sorted = sort {$a->[0] cmp $b->[0]}  @lines; 

my @col = map $_->[0],@sorted;

for ($i=0;$i<@gsesnp;$i++)
{
	$gsesnp[$i]=~s/\r//g;
	@a=split('\t',$gsesnp[$i]);
	$low_idx = 0;
	$high_idx = @col;
	$c="";
	while ($low_idx <= $high_idx)
	{
		$mid_idx = floor(($low_idx+$high_idx)/2);
		print "$col[$mid_idx] \t $a[1] \t $high_idx \n";
		if ($col[$mid_idx] gt $a[1])
		{
			$high_idx = $mid_idx;
		}
		elsif ($col[$mid_idx] lt $a[1])
		{
			$low_idx = $mid_idx;
		}
		else
		{
			$correct_idx=$sorted[$mid_idx][1];
			#print "$sorted[$mid_idx][1]\n";
			$c="$gen4[$correct_idx]\n";
			$low_idx=$high_idx+1;
		}
#		$low_idx=$high_idx+1;

	}
	print OUT1 "$c";
}





