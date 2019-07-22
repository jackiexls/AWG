#!/usr/bin/perl -w
#################################################################
#Last update: 21th June
#New parameter added for determining whether the input
#file with a header line
#################################################################
use strict;
use Getopt::Long;

my ($in, $out, $remain, $col_num, $query, $mode, $title, $help);

GetOptions("i=s" => \$in,
           "o=s" => \$out,
           "r=s" => \$remain,
           "q=s" => \$query,
           "n=i" => \$col_num,
           "m=i" => \$mode,
           "t=s" => \$title,
           "help|h" => \$help
);           
           
if( !defined($in) || !defined($out) || !defined($remain) ||
    !defined($query) || !defined($title) || $help ) {
  &Usage();
  	
}
$col_num ||= 1;
$mode ||= 2;

if($mode == 1) {
  &selectByItemSpeed($in,$col_num,$query,$out,$title);
} else {
  &selectByItemInOrder($in,$col_num,$query,$out,$remain,$title);	
}


####################################################
#subroutine for selecting items from the input file
#based on the query file, in the end, outputing to
#the output file
####################################################
sub selectByItemSpeed{
  my ($infile,$col,$qfile,$outfile,$head) = @_;
  
  open QUERY,"<$qfile" || die "Cannot open this file!$!";
  my %query;
  while(<QUERY>) {
  	chomp;
  	$_ =~ s/^\s+//;
  	$_ =~ s/\s+$//;
  	$query{$_} = 1;
  }
  
  close QUERY;  
  open FILE,"<$infile" || die "Cannot open this file!$!";  
  open OUT,">$outfile" || die "Cannot write to this file!$!";
  if($head eq 'T') {
    my $header = <FILE>;
    print OUT "$header";
  }
  
  while(<FILE>) {
    chomp;
    my @arr = split /\t/,$_;
    if(defined $query{$arr[$col - 1]}) {
      print OUT "$_\n";	
    }	
  }  
  close FILE;	
  
  close OUT;  
}

### alternative mode ###
sub selectByItemInOrder{
  my ($infile,$col,$qfile,$outfile,$left,$head) = @_;
  
  open QUERY,"<$qfile" || die "Cannot open this file!$!";
  my @query;
  while(<QUERY>) {
  	chomp;
  	$_ =~ s/^\s+//;
  	$_ =~ s/\s+$//;
  	push @query,$_;
  }
  
  close QUERY;
  
  open FILE,"<$infile" || die "Cannot open this file!$!";  
  open OUT,">$outfile" || die "Cannot write to this file!$!";
  #open LEFT,">$remain" || die "Cannot write to this file!$!";
  
  if($head eq 'T') {
    my $header = <FILE>;
    print OUT "$header";
  }
  
  my @data = ();
  my $cnt = -1;
  my $cols;
  while(<FILE>) {
    chomp;
    my @arr = split /\t/,$_;
	$cols = scalar(@arr);
	
    #if(defined $query{$arr[$col - 1]}) {
    #  print OUT "$_\n";	
    #}
    $cnt++;
    $data[$cnt]{'name'} = $arr[$col - 1];
    $data[$cnt]{'value'} = $_;    	
  }  
  close FILE;	
  
  foreach my $i(0..$#query) {
    my $p = $query[$i];
    my $q = &isExisted($p,\@data);
    if($q != -1) {
      print OUT "$data[$q]{'value'}\n";	
    } else {
      #print OUT "$p\n";
      if($left eq 'y') {
	    foreach (0..$col-2) {
		  print OUT "\t";
		}
		
        print OUT "$p";
		foreach ($col .. $cols) {
		  print OUT "\t";
		}
		print OUT "\n";
		
      } else {
        ;	
      }
      #print LEFT "$p\n";	
    }
  }
  
  close OUT;    
  
}

### is existed ###
sub isExisted {
  my ($key,$arr) = @_;
  foreach (0..$#{$arr}) {
    if($arr->[$_]{'name'} eq $key) {
      return $_;	
    }	
  }	
  return -1;
}

### usage ###
sub Usage {
  print STDERR << "EOF";
  Description:This script is aimed at extracting those lines from tab-delimited 
  file based on the items matching to the specified column No.
  Author: xinglongsheng\@ioz.ac.cn
  Version: 2.0
=================================================================================
Options:
           -i  --in    <s>  input original file
           -o  --out   <s>  output file
           -r  --re    <s>  keep not matched items remaining(order mode)
                             y: yes || n: no
           -q  --query <s>  query file
           -n  --col   <i>  column number for looking up
           -m  --mode  <i>  output mode,1: speed priority 2: order first
           -t  --title <s>  with header(T) or not(F)
           -h  --help       print this help info
=================================================================================
EOF
  exit();
}
