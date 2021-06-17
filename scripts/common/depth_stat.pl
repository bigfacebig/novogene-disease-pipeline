#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use List::Util qw(max);

=pod

=head1 Usage
	perl $0 [option] <bam> <outdir>
		-q	base quality [default 0]
		-Q	mapping quality [default 0]
		-s	sample name[default 'sample']
		-r 	region file(bed format, just for WES. WGS need not this file)
		-g	refgenome, can only be b37, hg19 or hg38 at present [default b37]
		-m	statistic MT or not,can only be N or T [default N]
		-h	help
	# Any bugs please report to yuhuan@novogene.com
=cut

##add ref genome hg by yuhuan
my ($basethres,$mapQthres,$total_chr,$bedfile,$sample_name,$ref,$addnFile,$mt,$help);
GetOptions("q:i"=>\$basethres,"Q:i"=>\$mapQthres,"r:s"=>\$bedfile,"g:s"=>\$ref,"s:s"=>\$sample_name,"n:s"=>\$addnFile,"m:s"=>\$mt,"h"=>\$help);

#$total_chr ||= 2471805657;
$sample_name ||= 'sample';
$basethres ||= 0;
$mapQthres ||= 0;
$ref ||='b37';
$mt ||='N';
die `pod2text $0` if(@ARGV<2 || $help);


my $bam=shift;
my $outdir=shift;

####################### init
my %depth=();
my $maxCov=0;
my $Average_sequencing_depth=0;
my $Average_sequencing_depth4=0;
my $Average_sequencing_depth10=0;
my $Average_sequencing_depth20=0;
my $Average_sequencing_depth50=0;
my $Average_sequencing_depth100=0;

my $Coverage=0;
my $Coverage4=0;
my $Coverage10=0;
my $Coverage20=0;
my $Coverage50=0;
my $Coverage100=0;

my $Coverage_bases=0;
my $Coverage_bases_4=0;
my $Coverage_bases_10=0;
my $Coverage_bases_20=0;
my $Coverage_bases_50=0;
my $Coverage_bases_100=0;

my $total_Coverage_bases=0;
my $total_Coverage_bases_4=0;
my $total_Coverage_bases_10=0;
my $total_Coverage_bases_20=0;
my $total_Coverage_bases_50=0;
my $total_Coverage_bases_100=0;



######################## end init

my %bychr_depth = ();
my %bychr_coverage = ();
my %length_chr_WES = ();

##calcualte genome length
my %length_chr = ();
open CHR,"samtools-1.6 view -H $bam | " or die;
while (<CHR>)
{
	chomp;
	if($ref eq "b37")
	{
		if($_ =~ /SQ\s+SN\:([\d|X|Y|MT]+)\s+LN\:(\d+)/)
		{
			$length_chr{$1} = $2;
		}
	}
	elsif($ref eq "hg19")
	{
		if($_ =~ /SQ\s+SN\:([chr\d|chrX|chrY|chrMT]+)\s+LN\:(\d+)/)
		{
			$length_chr{$1} = $2;
		}
	}
	elsif($ref eq "hg38")
	{
		if($_ =~ /SQ\s+SN\:([chr\d|chrX|chrY|chrM]+)\s+LN\:(\d+)/)
		{
			$length_chr{$1} = $2;
	    }
    }
    elsif($ref eq "mm10")
    {
        if($_ =~ /SQ\s+SN\:([chr\d|chrX|chrY|chrM]+)\s+LN\:(\d+)/)
        {
            $length_chr{$1} = $2;
        }
	}
    elsif($ref eq "mm9")
    {
        if($_ =~ /SQ\s+SN\:([chr\d|chrX|chrY|chrM]+)\s+LN\:(\d+)/)
        {
            $length_chr{$1} = $2;
        }
    }
    elsif($ref eq "macFas5" || $ref eq "rheMac10")
    {
        if($_ =~ /SQ\s+SN\:([chr\d|chrX|chrM]+)\s+LN\:(\d+)/)
        {
            $length_chr{$1} = $2;
        }
    }
	else
	{
	die("Wrong reference genome,reference can only be b37, hg19 or hg38 or mm10 at present.")
	}
	if($_ =~ /LN\:(\d+)/)
	{
		$total_chr += $1;
	}

}


print "total_chr_ori:\t$total_chr\n";

my %length_nblock = ();
#print $ref;
## the N base in each chromosome
if($ref eq "b37")
{
%length_nblock = ('1' => 23970000,
			'2' => 4994855,
			'3' => 3225292,
			'4' => 3492600,
			'5' => 3220000,
			'6' => 3720001,
			'7' => 3785000,
			'8' => 3475100,
			'9' => 21070000,
			'10' => 4220009,
			'11' => 3877000,
			'12' => 3370502,
			'13' => 19580000,
			'14' => 19060000,
			'15' => 20836626,
			'16' => 11470000,
			'17' => 3400000,
			'18' => 3420019,
			'19' => 3320000,
			'20' => 3520000,
			'21' => 13023253,
			'22' => 16410021,
			'X' => 4170000,
			'Y' => 36389037,
			'MT' => 1,
			'hs37d5' => 570);
}
elsif($ref eq "hg19")
{
%length_nblock = (
			'chr1' => 23970000,
			'chr2' => 4994855,
			'chr3' => 3225292,
			'chr4' => 3492600,
			'chr5' => 3220000,
 			'chr6' => 3720001,
 			'chr7' => 3785000,
 			'chr8' => 3475100,
 			'chr9' => 21070000,
 			'chr10' => 4220009,
 			'chr11' => 3877000,
 			'chr12' => 3370502,
 			'chr13' => 19580000,
 			'chr14' => 19060000,
			'chr15' => 20836626,
			'chr16' => 11470000,
			'chr17' => 3400000,
			'chr18' => 3420019,
			'chr19' => 3320000,
			'chr20' => 3520000,
			'chr21' => 13023253,
			'chr22' => 16410021,
			'chrX' => 4170000,
			'chrY' => 36389037,
			'chrMT' => 1);
}
elsif($ref eq "hg38")
{
%length_nblock = (
	"chr1" => 18475408,
	"chr2" => 1645292,
	"chr3" => 195417,
	"chr4" => 461888,
	"chr5" => 2555066,
	"chr6" => 727456,
	"chr7" => 375838,
	"chr8" => 370500,
	"chr9" => 16604164,
	"chr10" => 534424,
	"chr11" => 552880,
	"chr12" => 137490,
	"chr13" => 16381200,
	"chr14" => 18525617,
	"chr15" => 17349864,
	"chr16" => 8532401,
	"chr17" => 337225,
	"chr18" => 283680,
	"chr19" => 2851219,
	"chr20" => 499910,
	"chr21" => 8671409,
	"chr22" => 13746483,
	"chrX" => 1147861,
	"chrY" => 33591060,
	"chrM" => 1
);
}
elsif($ref eq "mm10")
{
%length_nblock = (
            'chr1' => 3562553,
            'chr2' => 3786573,
            'chr3' => 3640823,
            'chr4' => 4452405,
            'chr5' => 3914910,
            'chr6' => 3400001,
            'chr7' => 3585785,
            'chr8' => 3789781,
            'chr9' => 3437870,
            'chr10' => 3627131,
            'chr11' => 3336598,
            'chr12' => 3206601,
            'chr13' => 3300446,
            'chr14' => 3460132,
            'chr15' => 3390370,
            'chr16' => 3188006,
            'chr17' => 3279608,
            'chr18' => 3250001,
            'chr19' => 3225710,
            'chrX' => 7541634,
            'chrY' => 3620000,
            'chrMT' => 0);
}
elsif($ref eq "mm9")
{
%length_nblock = (
            'chr1' => 5717877,
            'chr2' => 3355363,
            'chr3' => 3205869,
            'chr4' => 3743176,
            'chr5' => 4816074,
            'chr6' => 3200001,
            'chr7' => 10646034,
            'chr8' => 6942100,
            'chr9' => 3355215,
            'chr10' => 3145205,
            'chr11' => 3100300,
            'chr12' => 3796609,
            'chr13' => 3913132,
            'chr14' => 3559453,
            'chr15' => 3055000,
            'chr16' => 3314017,
            'chr17' => 3374134,
            'chr18' => 3171930,
            'chr19' => 3200200,
            'chrX' => 4568757,
            'chrY' => 13200000,
            'chrMT' => 0);
}
elsif($ref eq "macFas5")
{
%length_nblock = (
	'chr1' => 10122926,
	'chr2' => 5901047,
	'chr3' => 11883556,
	'chr4' => 6073907,
	'chr5' => 5926815,
	'chr6' => 6337365,
	'chr7' => 7810776,
	'chr8' => 6193092,
	'chr9' => 5922798,
	'chr10'  => 5748244,
	'chr11'  => 5613903,
	'chr12'  => 5395555,
	'chr13'  => 4857529,
	'chr14'  => 6837939,
	'chr15'  => 4899936,
	'chr16'  => 6894067,
	'chr17'  => 4856810,
	'chr18'  => 3945324,
	'chr19'  => 7856772,
	'chr20'  => 6148011,
	'chrX' => 8478409,
	'chrM' => 0
);
}
elsif($ref eq "rheMac10")
{
%length_nblock = (
	'chr1' => 1411374,
	'chr2' => 1337441,
	'chr3' => 1106764,
	'chr4' => 1292034,
	'chr5 ' => 1037295,
	'chr6' => 1184336,
	'chr7' => 1411499,
	'chr8' => 2125612,
	'chr9' => 2086086,
	'chr10'  => 3396924,
	'chr11'  => 1654985,
	'chr12'  => 1109079,
	'chr13'  => 1039392,
	'chr14'  => 1061020,
	'chr15'  => 2727597,
	'chr16'  => 1791771,
	'chr17'  => 1402654,
	'chr18'  => 1037550,
	'chr19'  => 1932183,
	'chr20'  => 1000100,
	'chrX' => 703929,
	'chrY' => 600000,
	'chrM' => 0

);
}
close CHR;

my $countN=0;
foreach (keys %length_nblock)
    {
	$countN += $length_nblock{$_};
    }

print "N_block:\t$countN\n";


if (!defined($bedfile))
{

	foreach (keys %length_nblock)
	{
		$total_chr -= $length_nblock{$_};
	}

	`mkdir -p $outdir` unless -d $outdir;


	open DEPTH,"samtools-1.6 depth -q $basethres -Q $mapQthres $bam | " or die;
	while(<DEPTH>)
	{
		chomp;
		my @arr = split;
		next if ($arr[2] == 0);
		$depth{$arr[2]}+=1;

		#for coverage bychr
		$bychr_depth{$arr[0]} += $arr[2];
		$bychr_coverage{$arr[0]} += 1;
	}
	close DEPTH;


	my @depth=sort {$a<=>$b} keys %depth;
	my %counts = ();

	open HIS,">$outdir/depth_frequency.xls" or die;
	open CUM,">$outdir/cumu.xls" or die;
	open CUN,">$outdir/$sample_name\.sample_cumulative_coverage_counts" or die;
	print CUM "Depth\tPercent\n0\t1\n";

	for my $i (0..500)
	{
		print CUN "\tget_$i";
	}
	print CUN "\n$sample_name";
	$counts{"0"} = $total_chr;

	foreach my $depth1 (@depth)
	{

		my $per=$depth{$depth1}/$total_chr;
		$total_Coverage_bases += $depth1*$depth{$depth1};
		$Coverage_bases += $depth{$depth1};

		if($depth1>=4)
		{
			$total_Coverage_bases_4 += $depth1 * $depth{$depth1};
			$Coverage_bases_4 += $depth{$depth1};
		}
		if($depth1>=10)
		{
			$total_Coverage_bases_10 += $depth1 * $depth{$depth1};
			$Coverage_bases_10 += $depth{$depth1};
		}
		if($depth1>=20)
		{
			$total_Coverage_bases_20 += $depth1 * $depth{$depth1};
			$Coverage_bases_20 += $depth{$depth1};
		}
		if($depth1>=50)
		{
			$total_Coverage_bases_50 += $depth1 * $depth{$depth1};
			$Coverage_bases_50 += $depth{$depth1};
		}
		if($depth1>=100)
		{
			$total_Coverage_bases_100 += $depth1 * $depth{$depth1};
			$Coverage_bases_100 += $depth{$depth1};
		}

		$maxCov=$per if($maxCov<$per);
		my $tmp=0;
		print HIS "$depth1\t$per\t$depth{$depth1}\n";
		foreach my $depth2(@depth)
		{
			$tmp+=$depth{$depth2} if($depth2 >= $depth1);
		}
		$counts{$depth1} = $tmp;
		$tmp=$tmp/$total_chr;
		print CUM "$depth1\t$tmp\n";


	}

	for my $i (0..500)
	{
	if($counts{$i})
	{
		print CUN "\t$counts{$i}";
	}
	else
	{
		for my $b ($i..500)
		{
			if($counts{$b})
			{
				print CUN "\t$counts{$b}";
				last
			}
		}
	}
	}
	close HIS;
	close CUM;
	close CUN;


	$Average_sequencing_depth=$total_Coverage_bases/$total_chr;
	$Coverage=$Coverage_bases/$total_chr;
	$Average_sequencing_depth4=$total_Coverage_bases_4/$total_chr;
	$Coverage4=$Coverage_bases_4/$total_chr;
	$Average_sequencing_depth10=$total_Coverage_bases_10/$total_chr;
	$Coverage10=$Coverage_bases_10/$total_chr;
	$Average_sequencing_depth20=$total_Coverage_bases_20/$total_chr;
	$Coverage20=$Coverage_bases_20/$total_chr;
	$Average_sequencing_depth50=$total_Coverage_bases_50/$total_chr;
	$Coverage50=$Coverage_bases_50/$total_chr;
	$Average_sequencing_depth100=$total_Coverage_bases_100/$total_chr;
	$Coverage100=$Coverage_bases_100/$total_chr;


	#calculate sd
    $depth{0} = 0;
## all_base = total not actually sequenced?
    my $all_base = $total_chr;
    print "total_chr:\t$total_chr\ncovered_base:\t$Coverage_bases\n";
    foreach my $d (keys %depth)
    {
        $all_base -= $depth{$d};
    }
    $depth{0} = $all_base;
    print "not sequenecd base:\t$all_base\n";
    my $pingfanghe = 0;

## why pingfanghe need * $depth?
## why sd = pingfanghe/total_chr not Coverage_bases?
    foreach my $d (keys %depth)
    {
        $pingfanghe += ($d - $Average_sequencing_depth)**2 * $depth{$d};
    }
	my $sd = sprintf("%.5f", $pingfanghe/$total_chr);
	my $sd2 = sprintf("%.5f", $pingfanghe/$Coverage_bases);
	$sd = sqrt($sd);
	$sd2 = sqrt($sd2);

	#calculate Median
    my $middle = int($total_chr/2);
    print "zhangchao:mid\t$middle\n";
    my $add = 0;
    my $Median = 0;
    my $Median2 = 0;
    foreach my $d ( sort {$a <=> $b} keys %depth)
    {
        $add += $depth{$d};
        if ($add >= $middle)
        {
            $Median = $d;
	    print "zhangchao_above_midian:\t$add\n";
			last;
        }
    }

    my $medsite = int($Coverage_bases/2);
    print "yuhuan:mid\t$medsite\n";
    my $add2 = 0;
    foreach my $d ( sort {$a <=> $b} keys %depth)
    {
	$add2 += $depth{$d};
	if ($add2 >= $medsite)
	{
		$Median2 = $d;
		print "yuhuan_above_midian:\t$add2\n";
			last;
	}
    }

	open SD_MD,">$outdir/SD_MD.xls" or die $!;
	printf SD_MD "SD_y_z:\t%.2f\t%.2f\n",$sd2,$sd;
	print SD_MD "Median_y_z:\t$Median2\t$Median\n";
	#print SD_MD "Coverage_at_least_50X:\t",sprintf("%.2f%%",100*$Coverage50),"\n";
	#print SD_MD "Coverage_at_least_100X:\t",sprintf("%.2f%%",100*$Coverage100),"\n";
	#close SD_MD;

	open STAT,">$outdir/information.xlsx" or die $!;
	print STAT "Average_sequencing_depth:\t",sprintf("%.2f",$Average_sequencing_depth),"\n";
	print STAT "Coverage:\t",sprintf("%.2f%%",100*$Coverage),"\n";
	print STAT "Coverage_at_least_4X:\t",sprintf("%.2f%%",100*$Coverage4),"\n";
	print STAT "Coverage_at_least_10X:\t",sprintf("%.2f%%",100*$Coverage10),"\n";
	print STAT "Coverage_at_least_20X:\t",sprintf("%.2f%%",100*$Coverage20),"\n";
	print SD_MD "Coverage_at_least_50X:\t",sprintf("%.2f%%",100*$Coverage50),"\n";
	print SD_MD "Coverage_at_least_100X:\t",sprintf("%.2f%%",100*$Coverage100),"\n";
	close STAT;
	close SD_MD;

}



###for WES
my $Initial_bases_on_target=0;
my $Initial_bases_near_target=0;
my $Initial_bases_on_or_near_target=0;
my $Total_effective_reads=0;
my $Total_effective_yield=0;   # = $total_Coverage_bases
my $Average_read_length=0;
my $Effective_sequences_on_target=0;
my $Effective_sequences_near_target=0;
my $Effective_sequences_on_or_near_target=0;
my $Fraction_of_effective_bases_on_target=0;
my $Fraction_of_effective_bases_on_or_near_target=0;
my $Average_sequencing_depth_on_target=0;
my $Average_sequencing_depth_near_target=0;
my $Mismatch_rate_in_target_region=0;
my $Mismatch_rate_in_all_effective_sequence=0;
my $Base_covered_on_target=0;
my $Coverage_of_target_region=0;
my $Base_covered_near_target=0;
my $Coverage_of_flanking_region=0;
my $Fraction_of_target_covered_with_at_least_100x=0;
my $Fraction_of_target_covered_with_at_least_50x=0;
my $Fraction_of_target_covered_with_at_least_20x=0;
my $Fraction_of_target_covered_with_at_least_10x=0;
my $Fraction_of_target_covered_with_at_least_4x=0;
#my $Fraction_of_flanking_region_covered_with_at_least_100x=0;
#my $Fraction_of_flanking_region_covered_with_at_least_50x=0;
my $Fraction_of_flanking_region_covered_with_at_least_20x=0;
my $Fraction_of_flanking_region_covered_with_at_least_10x=0;
my $Fraction_of_flanking_region_covered_with_at_least_4x=0;


##init
my %length_flank_chr_WES = ();
my $Mismatch_base_in_all_effective_sequence = 0;
my $Mismatch_base_in_target_region = 0;


if (defined($bedfile))
{


	open CHRWES,"$bedfile" or die;
	##tmp.region.bed expand 200 bp region to bedfile start and end position,then get the 200bp region.
	open TMP,">$outdir/tmp.region.bed";
	while(<CHRWES>)
	{
		chomp;
		my @info = split;
		$length_chr_WES{$info[0]} += $info[2] - $info[1];
		$Initial_bases_on_target += $info[2]-$info[1];
		if($info[1]>200){
			my $pri_beg_pos=$info[1]-200;
		}
		else{
			my $pri_beg_pos=0;
		}
		my $pri_beg_pos=$info[1]-200;
		my $pri_end_pos=$info[1];
		my $next_beg_pos=$info[2];
		my $next_end_pos=$info[2]+200;
		if($pri_beg_pos<0) { $pri_beg_pos=0; }
		if ($info[1] eq 0){
			print TMP "$info[0]\t$next_beg_pos\t$next_end_pos\n";
			}
		else{
			print TMP "$info[0]\t$pri_beg_pos\t$pri_end_pos\n";
			print TMP "$info[0]\t$next_beg_pos\t$next_end_pos\n";
		}
	}
	close TMP;
	close CHRWES;

	##Get only flank_region.bed by merge and subtractBed bedfile and flank_region.bed,then the flank region can't overlap target region.
	##Get target_and_flank_region bed by merge bedfile and flank_region.bed,then the flank_target_region include target and flank region.
	`sortBed -i $outdir/tmp.region.bed | mergeBed -i stdin | subtractBed -a stdin -b $bedfile > $outdir/flank_region.bed`;
	`cat $outdir/flank_region.bed $bedfile | sortBed -i stdin | mergeBed -i stdin > $outdir/flank_target_region.bed`;

	##Calculate depth of flank_region  and target_region
	`samtools-1.6 depth -q $basethres -Q $mapQthres -b $outdir/flank_region.bed $bam > $outdir/flank_region.depth`;
	`samtools-1.6 depth -q $basethres -Q $mapQthres -b $bedfile $bam > $outdir/target_region.depth`;
    ## change from "samtools-1.6 depth -a" to "samtools-1.6 depth -aa" by uso 20170217
    ## -aa output absolutely all positions, including unused ref. sequences
    #`samtools-1.6 depth -aa -q $basethres -Q $mapQthres -b $bedfile $bam > $outdir/target_region-1.3.1.depth`;
    `awk -F '\t' '{if(\$3=="0")print}' $outdir/target_region.depth > $outdir/target_region.00.depth`;
    #`awk -F '\t' '{if(\$3=="0")print}' $outdir/target_region-1.3.1.depth > $outdir/target_region_all.0.depth`;
    #`grep -wvf $outdir/target_region.00.depth $outdir/target_region_all.0.depth > target_region.0.depth`;

	$Total_effective_yield=`samtools-1.6 depth -q $basethres -Q $mapQthres  $bam | awk '{total+=\$3};END{print total}'`;

	open FLANK,"$outdir/flank_region.bed" or die;
    while(<FLANK>)
    {
        chomp;
        my @info = split;
        #$length_flank_chr_WES{$info[0]} += $info[2] - $info[1];

        $Initial_bases_near_target += $info[2] - $info[1];
    }
    close FLANK;

	%bychr_depth = ();
	%bychr_coverage = ();
	%depth = ();

	open DEPTH,"$outdir/target_region.depth" or die;
	while(<DEPTH>)
	{
		chomp;
		my @arr = split;
		next if ($arr[2] == 0);
		$depth{$arr[2]}+=1;

		#for coverage bychr
		$bychr_depth{$arr[0]} += $arr[2];
		$bychr_coverage{$arr[0]} += 1;
	}
	close DEPTH;

	$Initial_bases_on_or_near_target = $Initial_bases_on_target + $Initial_bases_near_target;
	my $tmp1=`awk '{total4++};{total+=\$3};\$3 >=20 {total1++};\$3 >=10 {total2++};\$3 >=4 {total3++};\$3 >= 50 {total5++};\$3 >= 100 {total6++};END{print total"\t"total6"\t"total5"\t"total1"\t"total2"\t"total3"\t"total4}' $outdir/target_region.depth`;
	chomp($tmp1);
	my @info1;
	@info1 = split /\t/, $tmp1;

	$Effective_sequences_on_target = $info1[0];
	if(defined($info1[1]) or $info1[1]=0 )
	{
		$Fraction_of_target_covered_with_at_least_100x = $info1[1]/$Initial_bases_on_target;
	}
	if(defined($info1[2]) or $info1[2]=0 )
	{
		$Fraction_of_target_covered_with_at_least_50x = $info1[2]/$Initial_bases_on_target;
	}
	if(defined($info1[3]) or $info1[3]=0 )
	{
		$Fraction_of_target_covered_with_at_least_20x = $info1[3]/$Initial_bases_on_target;
	}

	if(defined($info1[4]) or $info1[4]=0 )
	{
		$Fraction_of_target_covered_with_at_least_10x = $info1[4]/$Initial_bases_on_target;
	}
	if(defined($info1[5]) or $info1[5]=0 )
	{
		$Fraction_of_target_covered_with_at_least_4x = $info1[5]/$Initial_bases_on_target;
	}



	$Base_covered_on_target = $info1[6];


	my $tmp2 = `awk '{total4++};{total+=\$3};\$3 >=20 {total1++};\$3 >=10 {total2++};\$3 >=4 {total3++};END{print total"\t"total1"\t"total2"\t"total3"\t"total4}' $outdir/flank_region.depth`;
	chomp($tmp2);
	my @info2;
	@info2 = split /\t/, $tmp2;

	$Effective_sequences_near_target = $info2[0];
	if(defined($info2[1]) or $info2[1]=0 )
	{
		$Fraction_of_flanking_region_covered_with_at_least_20x=$info2[1]/$Initial_bases_near_target;
	}
	if(defined($info2[2]) or $info2[2]=0 )
	{
		$Fraction_of_flanking_region_covered_with_at_least_10x=$info2[2]/$Initial_bases_near_target;
	}
	if(defined($info2[3]) or $info2[3]=0 )
	{
		$Fraction_of_flanking_region_covered_with_at_least_4x=$info2[3]/$Initial_bases_near_target;
	}

	$Base_covered_near_target = $info2[4];

	$Effective_sequences_on_or_near_target = $Effective_sequences_on_target + $Effective_sequences_near_target;



	#Total_effective_reads
	open BAM,"samtools-1.6 view -F 0x0004 $bam | " or die $!;
	while(<BAM>)
	{
		chomp;
		my @_F=split /\t/;
		#if($_F[1]=~/d/) { next; }
		$Total_effective_reads++;
		if($_ =~ /MD:Z:([\d|A|T|C|G|N]+)\t/)
		{
			my $count=()=$1=~/\d[A|T|C|G|N]/g;
			$Mismatch_base_in_all_effective_sequence += $count;
    	}
	}
	close BAM;

	open BAM,"samtools-1.6 view -F 0x0004 -L $bedfile $bam | " or die $!;
	while(<BAM>)
	{
		chomp;
		my @_F=split /\t/;
		if($_ =~ /MD:Z:([\d|A|T|C|G|N]+)\t/)
		{
			my $count=()=$1=~/\d[A|T|C|G|N]/g;
			$Mismatch_base_in_target_region += $count;
    	}
	}
	close BAM;

	$Average_read_length = $Total_effective_yield/$Total_effective_reads;

	$Fraction_of_effective_bases_on_target = $Effective_sequences_on_target/$Total_effective_yield;

	$Fraction_of_effective_bases_on_or_near_target = $Effective_sequences_on_or_near_target/$Total_effective_yield;

	$Average_sequencing_depth_on_target = $Effective_sequences_on_target/$Initial_bases_on_target;

	$Average_sequencing_depth_near_target = $Effective_sequences_near_target/$Initial_bases_near_target;

	$Mismatch_rate_in_target_region=$Mismatch_base_in_target_region/$Effective_sequences_on_target;

	$Mismatch_rate_in_all_effective_sequence=$Mismatch_base_in_all_effective_sequence/$Total_effective_yield;

	$Coverage_of_target_region=$Base_covered_on_target/$Initial_bases_on_target;

	$Coverage_of_flanking_region=$Base_covered_near_target/$Initial_bases_near_target;

	#calculate SD
	my $all_base = $Initial_bases_on_target;
	foreach my $d (keys %depth)
	{
    	$all_base -= $depth{$d};
	}
	$depth{0} = $all_base;
	print "target_base:\t$Initial_bases_on_target\nBase_covered_on_target:\t$Base_covered_on_target\nNot_sequenced_base_of_target:\t$all_base\n";
	my $pingfanghe = 0;
	foreach my $d (keys %depth)
	{
        $pingfanghe += ($d - $Average_sequencing_depth_on_target)**2 * $depth{$d};
	}
	my $sd = sprintf("%.5f", $pingfanghe/$Initial_bases_on_target);
	my $sd2 = sprintf("%.5f", $pingfanghe/$Base_covered_on_target);
	$sd = sqrt($sd);
	$sd2 = sqrt($sd2);

	#calculate Median
	my $middle = int($Initial_bases_on_target/2);
	my $midsite = int($Base_covered_on_target/2);
	print "Middle_base_zhangchao:\t$middle\n";
	print "Middle_base_yuhuan:\t$midsite\n";
	my $add = 0;
	my $add2 = 0;
	my $Median = 0;
	my $Median2 = 0;
	foreach my $d ( sort { $a <=> $b } keys %depth)
	{
		$add += $depth{$d};
		if ($add > $middle)
		{
			$Median = $d;
			print "Mid_depth_zhangchao:\t$d\nBase_above_mid:\t$add\n";
			last;
		}
	}
	foreach my $d ( sort { $a <=> $b } keys %depth)
	{
		$add2 += $depth{$d};
		if ($add2 > $midsite)
		{
			$Median2 = $d;
			print "Mid_depth_yuhuan:\t$d\nBase_above_mid:\t$add2\n";
			last;
		}
	}

	#output
	open SD_MD,">$outdir/SD_MD.xls" or die $!;
	printf SD_MD "SD_y_z:\t%.2f\t%0.2f\n",$sd2,$sd;
	print SD_MD "Median_y_z:\t$Median2\t$Median\n";
	#printf SD_MD "Fraction_of_target_covered_with_at_least_50x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_50x;
	#printf SD_MD "Fraction_of_target_covered_with_at_least_100x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_100x;

	open STAT,">$outdir/information.xlsx" or die $!;
	print STAT "Initial_bases_on_target:\t$Initial_bases_on_target\n";
	print SD_MD "Initial_bases_near_target:\t$Initial_bases_near_target\n";
	print STAT "Initial_bases_on_or_near_target:\t$Initial_bases_on_or_near_target\n";
	print SD_MD "Total_effective_reads:\t$Total_effective_reads\n";
	printf STAT "Total_effective_yield(Mb):\t%.2f\n",$Total_effective_yield/1000000;
	#printf STAT "Average_read_length(bp):\t%.2f\n",$Average_read_length;
	printf STAT "Effective_yield_on_target(Mb):\t%.2f\n",$Effective_sequences_on_target/1000000;
	printf SD_MD "Effective_yield_near_target(Mb):\t%.2f\n",$Effective_sequences_near_target/1000000;
	printf SD_MD "Effective_yield_on_or_near_target(Mb):\t%.2f\n",$Effective_sequences_on_or_near_target/1000000;
	printf STAT "Fraction_of_effective_bases_on_target:\t%.1f%%\n",100*$Fraction_of_effective_bases_on_target;
	printf STAT "Fraction_of_effective_bases_on_or_near_target:\t%.1f%%\n",100*$Fraction_of_effective_bases_on_or_near_target;
	printf STAT "Average_sequencing_depth_on_target:\t%.2f\n",$Average_sequencing_depth_on_target;
	printf SD_MD "Average_sequencing_depth_near_target:\t%.2f\n",$Average_sequencing_depth_near_target;
	printf SD_MD "Mismatch_rate_in_target_region:\t%.2f%%\n",100*$Mismatch_rate_in_target_region;
	printf SD_MD "Mismatch_rate_in_all_effective_sequence:\t%.2f%%\n",100*$Mismatch_rate_in_all_effective_sequence;
	print STAT "Bases_covered_on_target:\t$Base_covered_on_target\n";
	printf STAT "Coverage_of_target_region:\t%.1f%%\n",100*$Coverage_of_target_region;
	print SD_MD "Base_covered_near_target:\t$Base_covered_near_target\n";
	printf SD_MD "Coverage_of_flanking_region:\t%.1f%%\n",100*$Coverage_of_flanking_region;
	printf STAT "Fraction_of_target_covered_with_at_least_100x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_100x;
	printf STAT "Fraction_of_target_covered_with_at_least_50x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_50x;
	printf STAT "Fraction_of_target_covered_with_at_least_20x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_20x;
	printf STAT "Fraction_of_target_covered_with_at_least_10x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_10x;
	printf STAT "Fraction_of_target_covered_with_at_least_4x:\t%.1f%%\n",100*$Fraction_of_target_covered_with_at_least_4x;
	printf SD_MD "Fraction_of_flanking_region_covered_with_at_least_20x:\t%.1f%%\n",100*$Fraction_of_flanking_region_covered_with_at_least_20x;
	printf SD_MD "Fraction_of_flanking_region_covered_with_at_least_10x:\t%.1f%%\n",100*$Fraction_of_flanking_region_covered_with_at_least_10x;
	printf SD_MD "Fraction_of_flanking_region_covered_with_at_least_4x:\t%.1f%%\n",100*$Fraction_of_flanking_region_covered_with_at_least_4x;
	close STAT;
	close SD_MD;


	#my %depth = ();
	delete $depth{'0'};
	my @depth = ();
	#open DEPTH,"$outdir/target_region.depth" or die;
	#while(<DEPTH>)
	#{
	#	chomp;
	#	my @arr = split;
	#	next if ($arr[2] == 0);
	#	$depth{$arr[2]}+=1;
	#}
	###depth : {depth_value:number_of_pos_when_depth} eg: 4:1000 means there 1000 positons' coverage is 4
	@depth=sort {$a<=>$b} keys %depth;
	my %counts = ();
	open HIS,">$outdir/depth_frequency.xls" or die;
	open CUM,">$outdir/cumu.xls" or die;
	open CUN,">$outdir/$sample_name\.sample_cumulative_coverage_counts" or die;
	print CUM "Depth\tPercent\n0\t1\n";
	for my $i (0..500)
	{
		print CUN "\tget_$i";
	}
	print CUN "\n$sample_name";
	#$counts{"0"} = $Initial_bases_on_target;
	#change by yuhuan,for maxdep to get every depth's frequence for TS plot.
	my $maxdep = max(@depth);
	foreach my $depth1 (0..$maxdep)
	{
		if($depth{$depth1})
		{
		my $per=$depth{$depth1}/$Initial_bases_on_target;
		print HIS "$depth1\t$per\t$depth{$depth1}\n";
		$maxCov=$per if($maxCov<$per);
		}
		my $tmp=0;
		foreach my $depth2(@depth)
		{
			$tmp+=$depth{$depth2} if($depth2 >= $depth1);
		}
		###need deal
		$counts{$depth1} = $tmp;
		$tmp=$tmp/$Initial_bases_on_target;
		print CUM "$depth1\t$tmp\n";
	}
	## @depth begin with 1, and $tmp+ may not eq the initial bases on target when bam file do not contain all site, but all base on target must be above 0 ,so mark counts{"0"} = $Initial_bases_on_target;
	$counts{"0"} = $Initial_bases_on_target;

	for my $i (0..500)
	{
	if($counts{$i})
	{
		print CUN "\t$counts{$i}";
	}
	##add by yuhuan, for the depth value in 1..500 but not in counts.Some TS project do not have low depth value.
	else
	{
		for my $b ($i..500)
		{
			if($counts{$b})
			{
				print CUN "\t$counts{$b}";
				last
			}

		}
	}
	}


	close CUN;
	close HIS;
	close CUM;

	#remove
	#`rm $outdir/flank_region.depth $outdir/target_region.depth $outdir/target_region-1.3.1.depth $outdir/tmp.region.bed $outdir/flank_region.bed $outdir/flank_target_region.bed`;
}

open BYCHR,">$outdir/$sample_name".".coverage.bychr.txt" or die;
print BYCHR "chr\tlength\ttotal_depth\tmean_depth\tcovered_bases\tprop_covered_bases";
##add by yuhuan for hg19 genome.
my @chrlist =();
if($ref eq "b37")
{
	@chrlist = (1..22,'X','Y');
	if($mt ne "N")
	{
		push (@chrlist,'MT');
	}
}
elsif(($ref eq "hg19") || ($ref eq "hg38"))
{
	@chrlist = ('chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chr20','chr21','chr22','chrX','chrY');
	if($mt ne "N")
	{
		if($ref eq "hg19")
		{
			push (@chrlist,'chrMT');
		}
		else
		{
			push (@chrlist,'chrM');
		}
	}
}

elsif(($ref eq "mm10")||($ref eq "mm9"))
{
    @chrlist = ('chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chrX','chrY');
    if($mt ne "N")
    {
        push (@chrlist,'chrM');
    }
}

elsif($ref eq "macFas5" || $ref eq "rheMac10")
{
    @chrlist = ('chr1','chr2','chr3','chr4','chr5','chr6','chr7','chr8','chr9','chr10','chr11','chr12','chr13','chr14','chr15','chr16','chr17','chr18','chr19','chr20','chrX');
    if($mt ne "N")
    {
        push (@chrlist,'chrM');
    }
}
else
{
	die("Wrong reference genome,reference can only be b37, hg19 or hg38  mm9 mm10 at present.")
}

##length_chr_WES : {chr:lenth_of_base} from bed file
##bychr_depth : {chr:total_base} from calculate
##bychr_coverage : {chr:coverd_length} from calculate
##add some judgement by yuhuan for chr in %bychr_depth(or %bychr_coverage) not in %length_chr_WES, or chr nor in chrlist.
for my $i (@chrlist)
{
	my $len_ral = 0;
	if (defined($bedfile))
	{
		if($length_chr_WES{$i})
		{
			$len_ral = $length_chr_WES{$i};
		}
	}
	else
	{
		$len_ral = $length_chr{$i} - $length_nblock{$i};
	}
	my $aver_depth = 0;
	my $aver_coverage = 0;
	if ($len_ral != 0)
	{
	if($bychr_depth{$i})
	{
		$aver_depth = sprintf("%.2f", $bychr_depth{$i}/$len_ral);
		$aver_coverage = sprintf("%.3f", $bychr_coverage{$i}/$len_ral);
	}
	}
	if ($aver_coverage > 1){$aver_coverage = 1}
	if(not $bychr_coverage{$i})
	{
		$bychr_coverage{$i} = 0
	}
	if(not $bychr_depth{$i})
	{
		$bychr_depth{$i} = 0
	}
	print BYCHR "\n$i\t$len_ral\t$bychr_depth{$i}\t$aver_depth\t$bychr_coverage{$i}\t$aver_coverage";
}
close BYCHR;



if(1)
{
	my $ylim = 100*$maxCov;


	my ($xbin,$ybin);
	$ylim= int($ylim) + 1;
	if($ylim <= 3)
	{
		$ybin = 0.5;
	}else{
		$ybin=1;
	}
	my $xlim=0;
	if($Average_sequencing_depth<30)
	{
		$xlim=100;
		$xbin=20;
	}elsif($Average_sequencing_depth < 50)
	{
		$xlim=160;
		$xbin=20;
	}elsif($Average_sequencing_depth  < 120)
	{
		$xlim=250;
		$xbin=50;
	}else{
		$xlim=600;
		$xbin=100;
	}
	histPlot($outdir,"$outdir/depth_frequency.xls",$ylim,$ybin,$xlim,$xbin);
	cumuPlot($outdir,"$outdir/cumu.xls",$xlim,$xbin);
}

sub cumuPlot {
	my ($outdir, $dataFile, $xlim, $xbin) = @_;
	my $figFile = "$outdir/cumuPlot.pdf";
	my $Rline=<<Rline;
	pdf(file="$figFile",w=8,h=6)
	rt <- read.table("$dataFile")
	opar <- par()
	x <- rt\$V1[1:($xlim+1)]
	y <- 100*rt\$V2[1:($xlim+1)]
	par(mar=c(4.5, 4.5, 2.5, 2.5))
	plot(x,y,col="red",type='l', lwd=2, bty="l",xaxt="n",yaxt="n", xlab="", ylab="", ylim=c(0, 100))
	xpos <- seq(0,$xlim,by=$xbin)
	ypos <- seq(0,100,by=20)
	axis(side=1, xpos, tcl=0.2, labels=FALSE)
	axis(side=2, ypos, tcl=0.2, labels=FALSE)
	mtext("Cumulative sequencing depth",side=1, line=2, at=median(xpos), cex=1.5 )
	mtext("Fraction of bases (%)",side=2, line=3, at=median(ypos), cex=1.5 )
	mtext(xpos, side=1, las=1, at=xpos, line=0.3, cex=1.4)
	mtext(ypos, side=2, las=1, at=ypos, line=0.3, cex=1.4)
	par(opar)
	dev.off()
	png(filename="$outdir/cumuPlot.png",width = 480, height = 360)
	par(mar=c(4.5, 4.5, 2.5, 2.5))
	plot(x,y,col="red",type='l', lwd=3, bty="l",xaxt="n",yaxt="n", xlab="", ylab="", ylim=c(0, 100))
	xpos <- seq(0,$xlim,by=$xbin)
	ypos <- seq(0,100,by=20)
	axis(side=1, xpos, tcl=0.2, labels=FALSE)
	axis(side=2, ypos, tcl=0.2, labels=FALSE)
	mtext("Cumulative sequencing depth",side=1, line=2, at=median(xpos), cex=1.5 )
	mtext("Fraction of bases (%)",side=2, line=3, at=median(ypos), cex=1.5 )
	mtext(xpos, side=1, las=1, at=xpos, line=0.3, cex=1.5)
	mtext(ypos, side=2, las=1, at=ypos, line=0.3, cex=1.5)
	par(opar)
	dev.off()

Rline
	open (ROUT,">$figFile.R");
	print ROUT $Rline;
	close(ROUT);

	system("R CMD BATCH  $figFile.R");
}


sub histPlot {
	my ($outdir, $dataFile, $ylim, $ybin, $xlim, $xbin) = @_;
	my $figFile = "$outdir/histPlot.pdf";
	my $Rline=<<Rline;
	pdf(file="$figFile",w=8,h=6)
	rt <- read.table("$dataFile")
	opar <- par()
	t=sum(rt\$V2[($xlim+1):length(rt\$V2)])
	y=c(rt\$V2[1:$xlim],t)
	y <- y*100
	x <- rt\$V1[1:($xlim+1)]
	par(mar=c(4.5, 4.5, 2.5, 2.5))
	plot(x,y,col="blue",type='h', lwd=1.5, xaxt="n",yaxt="n", xlab="", ylab="", bty="l",ylim=c(0,$ylim),xlim=c(0,$xlim))
	xpos <- seq(0,$xlim,by=$xbin)
	ypos <- seq(0,$ylim,by=$ybin)
	axis(side=1, xpos, tcl=0.2, labels=FALSE)
	axis(side=2, ypos, tcl=0.2, labels=FALSE)
	mtext("Sequencing depth",side=1, line=2, at=median(xpos), cex=1.5 )
	mtext("Fraction of bases (%)",side=2, line=3, at=median(ypos), cex=1.5 )
	end <- length(xpos)-1
	mtext(c(xpos[1:end],"$xlim+"), side=1, las=1, at=xpos, line=0.3, cex=1.4)
	mtext(ypos, side=2, las=1, at=ypos, line=0.3, cex=1.4)
	par(opar)
	dev.off()
	png(filename="$outdir/histPlot.png",width = 480, height = 360)
	par(mar=c(4.5, 4.5, 2.5, 2.5))
	plot(x,y,col="blue",type='h', lwd=1.5, xaxt="n",yaxt="n", xlab="", ylab="", bty="l",ylim=c(0,$ylim),xlim=c(0,$xlim))
	xpos <- seq(0,$xlim,by=$xbin)
	ypos <- seq(0,$ylim,by=$ybin)
	axis(side=1, xpos, tcl=0.2, labels=FALSE)
	axis(side=2, ypos, tcl=0.2, labels=FALSE)
	mtext("Sequencing depth",side=1, line=2, at=median(xpos), cex=1.5 )
	mtext("Fraction of bases (%)",side=2, line=3, at=median(ypos), cex=1.5 )
	end <- length(xpos)-1
	mtext(c(xpos[1:end],"$xlim+"), side=1, las=1, at=xpos, line=0.3, cex=1.5)
	mtext(ypos, side=2, las=1, at=ypos, line=0.3, cex=1.5)
	par(opar)
	dev.off()
Rline
	open (ROUT,">$figFile.R");
	print ROUT $Rline;
	close(ROUT);

	system("R CMD BATCH  $figFile.R");
}
