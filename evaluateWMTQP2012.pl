#!/usr/bin/perl -w

##########################################################################################
#           Copyright (c) 2012, Radu Soricut
#                         SDL International, Language Weaver
#                         All rights reserved.
#
# Version 1.1
# For research or educational purposes only.  Do not redistribute.  
# 
# Expected Input
# List of files (reference file first, any number of hyp files following), 
# each file with tab-separated content in the format:
# <METHOD NAME> <SEGMENT NUMBER> <SEGMENT SCORE> <SEGMENT RANK>
# 
# Each hyp file should have the same number of lines as the reference file, otherwise it will
# not be considered.
# 
# Expected Output
# For each hyp file:
# - a "Ranking" line with ranking metric values (primary is DeltaAvg [higher is better], 
#   seconday is Spearman correlation [higher is better])
# - a "Scoring" line with scoring metric values (primary is MAE [lower is better], seconday 
#   are RMSE [lower is better], LargeErrPerc (percentage of errors>=1.0) [lower is better], 
#   and SmallErrPerc (percentage of errors<=0.1) [higher is better].
#
# History:
# - 02/23/2012: v1.1 adds the following:
#    * enforces <METHOD NAME> field to be parsed as <TEAMNAME>_<DESCRIPTION>
#    * reports predicted interval
# - 02/06/2012: v1.0 first release 
##########################################################################################

use strict;

my $INF = 1000000;
my $DEBUG = 0; # 1 if you want to see the avgDelta per quantile value (in the limit case); 2 if you want to see the refRank-values per quantile 

my $ERRSMALL_T = 0.1;
my $ERRLARGE_T = 1.0;

if( $#ARGV<1 ){ die "Usage: $0 ref-file input-file(s)\n"; }

warn "$0, version 1.1\n";

my $refFile = $ARGV[0];
my %rHash = readInput($refFile, $refFile);
for(my $i=1; $i<=$#ARGV; $i++){
    my $hypFile = $ARGV[$i];
    my %cHash = readInput($hypFile, $refFile, \%rHash);
    if( scalar(keys %rHash) != scalar(keys %cHash) ){ 
	warn "Warning: number of entries in reference $refFile not the same as in file $hypFile (file skipped)\n" and next; 
    }

    my $AvgDelta = avgDelta(\%cHash);
    my $Rho = spearman(\%cHash);
    my ($MAE, $RMSE, $ERRSMP, $ERRLGP, $MINinterv, $MAXinterv) = MAE_RMSE(\%cHash);
    my $method = $cHash{"1"}{"method"};

    # Ranking results
    if( $AvgDelta>-$INF ){
	printf "%30s\t:: Ranking: (primary)  DeltaAvg  = %.2f\t (secondary)  Spearman-Corr = %.2f\n", $method, $AvgDelta, $Rho;
    }
    else{ printf "%30s\t:: Ranking: (primary)  DeltaAvg  = %4s\t (secondary)  Spearman-Corr = %4s\n", $method, "--", "--"; }

    # Scoring results
    if( $MAE>-$INF ){
	printf "%30s\t:: Scoring: (primary) MeanAvgErr = %.2f\t (secondary) RootMeanSqrErr = %.2f\t LargeErrPerc = %5.1f\t SmallErrPerc = %5.1f\t Interval = [%.1f-%.1f]\n", $method, $MAE, $RMSE, $ERRLGP, $ERRSMP, $MINinterv, $MAXinterv;
    }
    else{ printf "%30s\t:: Scoring: (primary) MeanAvgErr = %4s\t (secondary) RootMeanSqrErr = %4s\t LargeErrPerc = %5s\t SmallErrPerc = %5s\n", $method, "--", "--", "--", "--"; }
}

sub readInput{
    my ($fileName, $refName, $rhash) = @_;

    my %hash = ();
    my ($minSegId,$maxSegId) = ($INF,0);
    my ($minRank,$maxRank) = ($INF,0);
    my $team = "";
    open(F, $fileName) or die "Error: cannot open file $fileName\n";
    while(my $line=<F>){
	$line =~ s/[\015\012]*$//; # line-clean
	my @line = split "\t", $line;
	if( scalar(@line) != 4 ){ 
	    warn "Warning: line expected to have 4 tab-delimited entries in file $fileName: '$line' (file will be skipped)\n";
	    close(F);
	    return %hash; 
	}
	my ($method, $segId) = ( $line[0], $line[1] );
	if( $method =~ /^(.*?)_(.*)$/ ){
	    my $cteam = $1;
	    if( !$team ){ $team = $cteam; }
	    elsif( $team ne $cteam ){
		warn "Warning: line expected to have <METHOD NAME> team consistently the same: '$line' (file will be skipped)\n";
		close(F);
		return %hash; 
	    }
	}
	else{ 
	    warn "Warning: line expected to have <METHOD NAME> field as <TEAMNAME>_<DESCRIPTION>: '$line' (file will be skipped)\n";
	    close(F);
	    return %hash; 
	}
	if( $hash{$segId} ){ die "Error in $fileName: segment $segId not uniq\n"; }
	my ($score, $rank) = ( $line[2], $line[3] );
	$hash{$segId}{"method"} = $method;
	$hash{$segId}{"score"} = $score;
	$hash{$segId}{"rank"} = $rank;
	if( $fileName ne $refName ){
	    if( !defined ($rhash->{$segId}) ){ die "Error in $fileName: segment id $segId not found in the reference file $refName\n"; }
	    $hash{$segId}{"refScore"} = $rhash->{$segId}{"score"};
	    $hash{$segId}{"refRank"} = $rhash->{$segId}{"rank"};
	}
	else{ # reference for reference is the reference
	    $hash{$segId}{"refScore"} = $hash{$segId}{"score"};
	    $hash{$segId}{"refRank"} = $hash{$segId}{"rank"};
	}
	
	# verification for ranks: the segId range must be the same as the rank range
	if( $minSegId > $segId ){ $minSegId = $segId; }
	if( $maxSegId < $segId ){ $maxSegId = $segId; }
	if( $minRank > $rank ){ $minRank = $rank; }
	if( $maxRank < $rank ){ $maxRank = $rank; }
    }
    if( $maxRank && ($minSegId != $minRank || $maxSegId != $maxRank) ){ die "Error in $fileName: the range of the ranks [$minRank,$maxRank] is not the same as the segment id-s range [$minSegId,$maxSegId]\n"; }
    
    close(F);

    return %hash;
}

sub avgDelta{
    my ($chash) = @_;

    if( $chash->{1}{"rank"}==0 ){ return -$INF; }

    my @inputSortIdx = sort { $chash->{$a}{"rank"} <=> $chash->{$b}{"rank"} }( keys %{$chash} );
    my $ridx = scalar(@inputSortIdx);

    my @refValueSort = ();
    my $refSum = 0;
    my @avgDelta = ();
    my $AvgDelta = 0;
    my $cN = 0;
    my $maxN = int($ridx/2);
    for($cN=2; $cN<=$maxN; $cN++){ # current number of quantiles
	@refValueSort = ();
	$refSum = 0;
	for(my $i=1; $i<=$cN; $i++){
	    my $q = int($ridx/$cN);
	    my $head = $i*$q;
	    if( $i==$cN && $head<$ridx ){ $head = $ridx; } # include the remainder, so that the average is done across the entire input
	    for(my $k=0; $k<$head; $k++){ $refValueSort[$i] += $chash->{$inputSortIdx[$k]}{"refScore"}; }
	    $refValueSort[$i] /= $head;
	    if( $i<$cN ){ $refSum += $refValueSort[$i]; }
	    printf STDERR "Avg. RefValues-over-quantile(s) 1..$i: %.2f\n", $refValueSort[$i] if $DEBUG>1;
	}
	$avgDelta[$cN] = $refSum/($cN-1)-$refValueSort[$cN];
	printf STDERR "AvgDelta[$cN]: %.2f\n", $avgDelta[$cN] if $DEBUG>0;
	$AvgDelta += $avgDelta[$cN];
    }
    if( $maxN>1 ){
	$AvgDelta /= ($maxN-1);
    }
    else{ $AvgDelta = 0; }
    return $AvgDelta;

}

sub spearman{
    my ($chash) = @_;

    if( $chash->{1}{"rank"}==0 ){ return -$INF; }

    my $n = scalar(keys %{$chash});
    my $sd2 = 0;
    for(my $i=1; $i<=$n; $i++){
	$sd2 += ($chash->{$i}{"rank"}-$chash->{$i}{"refRank"})**2;
    }
    my $rho = 1;
    if( $n>1 ){ $rho = 1-(6*$sd2)/($n*($n**2-1)); }
    return $rho;
}

sub MAE_RMSE{
    my ($chash) = @_;

    my $n = scalar(keys %{$chash});
    my ($ESUM,$SSUM,$zeros,$errSm,$errLg) = (0,0,0,0,0);
    my ($minInterv, $maxInterv) = ($INF,-$INF);
    for(my $i=1; $i<=$n; $i++){
	if( $minInterv>$chash->{$i}{"score"} ){ $minInterv=$chash->{$i}{"score"}; }
	if( $maxInterv<$chash->{$i}{"score"} ){ $maxInterv=$chash->{$i}{"score"}; }
	$zeros += $chash->{$i}{"score"}==0 ? 1 : 0;
	my $err = sprintf("%.2f",$chash->{$i}{"score"}-$chash->{$i}{"refScore"});
	my $aerr = abs($err);
	if( $aerr<=$ERRSMALL_T ){ $errSm += 1; }
	if( $aerr>=$ERRLARGE_T ){ $errLg += 1; }
	$ESUM += $aerr;
	$SSUM += $err*$err;
    }
    
    my $MAE = $ESUM/$n;
    my $RMSE = sqrt($SSUM/$n);

    my $ERRSMP = $errSm/$n*100;
    my $ERRLGP = $errLg/$n*100;

    if( $zeros==$n ){ $MAE = $RMSE = -$INF; }

    return ($MAE,$RMSE,$ERRSMP,$ERRLGP,$minInterv,$maxInterv);
}
