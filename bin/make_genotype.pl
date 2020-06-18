#!/usr/bin/perl -w

my ($genotype) = @ARGV;

open (IN1,"<", "$genotype") or die "Cannot open $genotype \n";
open (OUT,">tmp") or die "Cannot write into tmp \n";
#open (HEADER,">head.txt") or die "Cannot write into head.txt \n";
@geno=<IN1>;
chomp @geno;

# print HEADER "id\t";
# for ($j=1;$j<=@geno;$j++)
# {
	# print HEADER"#00$j\t";
# }
	
for ($i=0;$i<@geno;$i++)
{
	$geno[$i]=~s/\r//g;
	$geno[$i]=~s/AA/0/g;
	$geno[$i]=~s/AB/1/g;
	$geno[$i]=~s/BB/2/g;
	$geno[$i]=~s/"//g;
	$geno[$i]=~s/-\d*_._._\w+:.//g;
	print OUT "$geno[$i]\n";
}
	
	
