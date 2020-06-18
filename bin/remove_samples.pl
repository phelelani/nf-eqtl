#!/usr/bin/perl -w

my ($map_geno, $map_expr, $failed_geno, $failed_expr) = @ARGV;

open (IN1, "<", "$map_geno") or die "Cannot find the required genotype input file!\n";
open (IN2, "<", "$map_expr") or die "Cannot find the required gene expression file!\n";
open (IN3, "<", "$failed_geno") or die "Cannot find the file with genotyping samples that have to be removed!\n";
open (IN4, "<", "$failed_expr") or die "Cannot find the file with gene expression samples that have to be removed!\n";
open (OUT1,'>genotype_remove.txt') or die "Cannot write into genotype_samples.txt!\n";
open (OUT2,'>expression_remove.txt') or die "Cannot write into file gene_expression_samples.txt!\n";

@file1= <IN1>;
chomp @file1;


@file2= <IN2>;
chomp @file2;

@file3= <IN3>;
chomp @file3;

@file4= <IN4>;
chomp @file4;

foreach $_(@file1)
{
	$_=~s/\r//g;
	#print "hello\n";
	@elements1=split (/\t/,$_);
	#print "$elements1[2]\n";
	for ($i=0;$i<@file3;$i++)
	{
		# print "hi\n";
		$file3[$i]=~s/\r//g;
		if ($file3[$i] eq $elements1[1])
		{
			print "matched!\n";
			print OUT1 "$file3[$i]\t$elements1[0]\n";
		}
	}
		
}


foreach $_(@file2)
{
	$_=~s/\r//g;
	#print "hello\n";
	@elements2=split (/\t/,$_);
	#print "$elements2[2]\n";
	for ($j=0;$j<@file4;$j++)
	{
		# print "hi\n";
		$file4[$j]=~s/\r//g;
		if ($file4[$j] eq $elements2[1])
		{
			print OUT2 "$file4[$j]\t$elements2[0]\n";
		}
	}
		
}
