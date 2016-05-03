#!/usr/bin/env perl -w
use strict;
use Getopt::Long;
use File::Basename;
use Cwd;
my $cwd = getcwd();


### usage ###
my $usage =<< "USAGE";
  Description: This perl script is used to split a large file containing multiple 
  FASTA sequences into separate sequence file including given number of sequences
  Author: Longsheng.xing\@allwegene.com
  Version: 1.0
=====================================================================================
Options:
		-i  --in    input FASTA sequence file
		-o  --out   output directory
		-h  --help  print this help info

=====================================================================================

USAGE

my $infile;
my $outdir;
my $help;

GetOptions("in|i=s" => \$infile,
           "out|o=s" => \$outdir,
           "h|help" => \$help);

if( !defined($infile) || !defined($outdir) ||
    $help ) {
  print STDERR "$usage";
  exit();
}
# if not existed, create a directory
unless(!-e $outdir) {
  mkdir($outdir);
}
$outdir =~ s/\/$//;

my $seqs;
my $count;
my $fileNum = 15;
my $seqnum;

($count,$seqs) = &readFastaFile($infile);

### determining seq number
my $quotient = int($count / $fileNum);
print $quotient,"\n";

my $mod = $count % $fileNum;
if ($mod == 0) {
  $seqnum = $quotient;
} else {
  $seqnum = $quotient + 1;
}

&splitFASTA($seqnum,$count,$seqs);


##############################
### split FASTA subroutine ###
##############################
sub splitFASTA {
  my $seqNum = shift;
  my $cnt = shift;
  my $sequence = shift;
  
  chdir $outdir || die "Cannot chdir to this directory!$!";
  foreach my $num(1 .. $cnt) {
    my $temp = $num + $seqNum - 1;
    $temp = int $temp / $seqNum;  #determining the filename of partial file based on the quotient
  
    my $filename = basename($infile);
	$filename .= ".part$temp";
    open OUT,">>$filename" || die "Cannot open this file!$!";
  
    &formattedPrint(*OUT,$sequence->[$num - 1]{'header'},$sequence->[$num - 1]{'sequence'});
    close OUT;
  
  }

}
############################################
### Subroutine for achieving formatted   ###
### printing to the specified filehandle ###
############################################
sub formattedPrint {
  my $file = shift;
  my $head = shift;
  my $seq = shift;
  my $len = length $seq;
  print $file ">$head\n";
  
  for(my $i = 0; $i < $len; $i += 80) {
    my $substr = substr($seq,$i,80);
    print $file "$substr\n";
  }

}

#########################################
### Subroutine for reading input      ###
### original sequence in FASTA-format ###
#########################################
sub readFastaFile {
  my $file = shift;

  open IN,"<$file" || die "Cannot open this file!$!";
  my $cnt = 0;
  my @sequence;
  while(<IN>) {
    chomp;
    if(/^>(.+)/) {
      $cnt++;
      $sequence[$cnt - 1]{'header'} = $1;     
    }
    if(/^\w/) {
      $sequence[$cnt - 1]{'sequence'} .= $_;
    }
  }
  close IN;

  return ($cnt,\@sequence);
}
