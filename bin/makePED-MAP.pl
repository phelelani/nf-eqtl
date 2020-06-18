#!/usr/bin/perl -w

## GET INPUT
my ($genotype, $snp) = @ARGV;

## ---------- STEP 1
open (IN, "<", "$genotype") or die "CANNOT OPEN < $genotype !";
open (FAM,">", "familyid.txt") or die "Cannot write into familyid.txt\n";
open (INDV, ">", "indvid.txt") or die "Cannot write into indvid.txt\n";
open (PAT, ">", "patid.txt") or die "Cannot write into patid.txt\n";
open (MAT, ">", "matid.txt") or die "Cannot write into matid.txt\n";
open (GEN, ">", "gender.txt") or die "Cannot write into gender.txt\n";
open (PHE, ">", "phenotype.txt") or die "Cannot write into phenotype.txt\n";

while (<IN>)
{
    $_=~s/\r//;
    if ($_=~m/Series_sample_id/)
    {
        @famid=split(/\t/,$_);
        @fam=split(/\s+/,$famid[1]);
        $p=pop(@fam); # because there is a space after the last famid, it creates an empty newline which has to be removed.
        foreach $_(@fam)
        {
            $_=~s/\"//;
            print FAM "$_\n";
            print INDV "$_\n";
        }

    }
    elsif ($_=~m/Sample_characteristics_ch1\t"g/)
    {
        @gender=split(/\t/,$_);
        for ($i=1;$i<@gender;$i++)
        {
            @gen=split (/:/,$gender[$i]);
            print PAT "0\n";
            print MAT "0\n";
            if ($gen[1]=~/female/)
            {
                print GEN "2\n";
            }
			else
			{
				print GEN "1\n";
			}
            print PHE "-9\n";
        }
    }
    else
    {
    }

}
system "paste familyid.txt indvid.txt patid.txt matid.txt gender.txt phenotype.txt > ped_1.tmp";

## ---------- STEP 2
open (IN,"<", "$genotype") or die "Cannot find $genotype !\n";
open (GENO,'>ped_2.tmp') or die "Cannot write into ped_2.tmp \n";
@in=<IN>;
chomp @in;
for ($i=0;$i<@in;$i++)
{
	$in[$i]=~s/\r//;
	if ($in[$i]=~/series_matrix_table_begin/)
	{
		$start=$i;
		$begin=($start+1);
		print "The genotype begins at row number $begin\n";
	}
	if ($in[$i]=~/series_matrix_table_end/)
	{
		$last=$i;
		$end=($last+1);
		print "The genotype info ends at row number $end\n";
	}
	
}
for ($j=$begin;$j<=@in;$j++)
{
	print GENO "$in[$j]\n";
}
system "sed -i '1d; /^\$/d; /^!series_matrix_table_end\$/d' ped_2.tmp";

 ## ---------- STEP 3
system "grep '^rs' $snp > clean_snp.txt";
open (IN1,"<clean_snp.txt") or die "Cannot open clean_snp.txt !\n";
open (IN2,"<ped_2.tmp") or die "Cannot open ped_2.tmp !\n";
open (TMP, ">convert_alleles.tmp") or  die "Cannot open convert_alleles.tmp !\n";
open (OUT,">ped_3.tmp") or die "Cannot write into ped_3.tmp !\n";

@gp=<IN1>;
@geno=<IN2>;
chomp @gp;
chomp @geno;
%rsid_alleles=();
for ($i=0;$i<@gp;$i++)
{
	$gp[$i]=~s/\r//g;
	@a=split(',',$gp[$i]);
	$rsid_alleles{$a[0]}=$a[3];
}
for($j=0;$j<@geno;$j++)
{
    $geno[$j]=~s/\r//g;
    @b=split("\t",$geno[$j]);
    $b[0]=~s/\"//g;
    if (exists($rsid_alleles{$b[0]}))
    {
        print TMP "$b[0]\t";
        $s1=substr($rsid_alleles{$b[0]},1,1);
        $s2=substr($rsid_alleles{$b[0]},3,1); 
        for ($k=1;$k<=149;$k++)
        {
            if ($b[$k]=~/AA/)
            {
                print TMP "$s1$s1\t";
            }
            elsif ($b[$k]=~/AB/)
            {
                print TMP "$s1$s2\t";
            }
            elsif ($b[$k]=~/BB/)
            {
                print TMP "$s2$s2\t";
            }
            elsif ($b[$k]=~/NC/)
            {
                print TMP "--\t";
            }
            else 
            {
                #
            }
        }
		print TMP "\n";
	}
}

system "cut -f 1 convert_alleles.tmp > rsid_list";
system "cut -f 2- convert_alleles.tmp > convert_alleles.tmp2";
system "datamash transpose < convert_alleles.tmp2 > ped_3.tmp";

## ---------- STEP 4
open (IN1,"<ped_3.tmp") or die "Cannot open ped_3.tmp \n";
open (TMP,">splitting.tmp") or die "Cannot write into splitting.tmp \n";
@geno=<IN1>;
chomp @geno;
for ($i=0;$i<@geno;$i++)
{
	#print "hello\n";
	$geno[$i]=~s/\r//g;
	@a=split('\t',$geno[$i]);
	for ($j=0;$j<@a;$j++)
	{
		@b=split(//,$a[$j]);
		print TMP "$b[0]\t$b[1]\t";
	}
	print TMP "\n";
}
system "sed -i '/^\$/d' splitting.tmp";
system "paste ped_1.tmp splitting.tmp > ped_4.tmp";
system "sed 's/\t\$//g' ped_4.tmp > dataset.ped";

## ---------- STEP 5
open (IN1,"<", "$snp") or die "Cannot open $snp !\n";
open (IN2,"<", "rsid_list") or die "Cannot open rsid_list !\n";
open (OUT,">", "dataset.map") or die "Cannot write into dataset.map !\n";
@gp=<IN1>;
@rs=<IN2>;
chomp @gp;
%rsid=();
for ($i=0;$i<@gp;$i++)
{
	$gp[$i]=~s/\r//g;
	@a=split(',',$gp[$i]);
	$rsid{$a[1]}="$a[9]\t$a[1]\t$a[10]";
}
for($j=0;$j<@rs;$j++)
{
    $rs[$j]=~s/\r//g;
    @b=split('-',$rs[$j]);
    if (exists($rsid{$b[0]}))
    {
		@c=split(/\t/,$rsid{$b[0]});
		print OUT "$c[0]\t$b[0]\t0\t$c[2]\n";
	}
}
