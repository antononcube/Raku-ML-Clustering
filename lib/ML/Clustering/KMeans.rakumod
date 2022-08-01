#!/usr/bin/env raku
use v6.d;

use ML::Clustering::DistanceFunctions;
use Data::Reshapers::TypeSystem;

class ML::Clustering::KMeans
        does ML::Clustering::DistanceFunctions {

    my Data::Reshapers::TypeSystem $typeSystem .= new;

    method find-clusters(@inputs,
                         UInt $nSeeds,
                         :$distance-function is copy = 'Euclidean',
                         :$max-steps is copy = 1000,
                         :$precision-goal is copy = 6,
                         :$learning-parameter is copy = 0.01,
                         :$min-reassignment-fraction is copy = 0.005,
                         :$prop is copy = 'Clusters') {

        # Process arguments
        if !$typeSystem.has-homogeneous-shape(@inputs) {
            die 'The first argument is expected to be a list of same length numeric lists.';
        }

        # Process options
        my $knownDistanceFuncs = <Euclidean Cosine Manhattan ChessBoard Hamming>;
        if $distance-function.isa(Whatever) { $distance-function = 'Euclidean' }
        if !($distance-function ~~ Str && $distance-function.lc ∈ $knownDistanceFuncs>>.lc) {
            die "The value of the argument distance-function is expected to be Whatever or one of { $knownDistanceFuncs.raku }."
        }
        $distance-function = $distance-function.lc;

        if $max-steps.isa(Whatever) { $max-steps = 100 }
        if !($max-steps ~~ Int && $max-steps ≥ 0) {
            die "The value of the argument max-steps is expected to be Whatever or a non-negative integer."
        }

        if $precision-goal.isa(Whatever) { $precision-goal = 6 }
        if !($precision-goal ~~ Numeric && $precision-goal ≥ 0) {
            die "The value of the argument precision-goal is expected to be Whatever or a non-negative real."
        }

        if $learning-parameter.isa(Whatever) { $learning-parameter = 0.01 }
        if !($learning-parameter ~~ Numeric && $learning-parameter ≥ 0) {
            die "The value of the argument learning-parameter is expected to be Whatever or a non-negative real."
        }

        if $min-reassignment-fraction.isa(Whatever) { $min-reassignment-fraction = 0.005 }
        if !($min-reassignment-fraction ~~ Numeric && 0 ≤ $min-reassignment-fraction ≤ 1) {
            die "The value of the argument min-reassignment-fraction is expected to be Whatever or a non-negative real between 0 and 1."
        }

        my $minReassignPoints = $min-reassignment-fraction * @inputs.elems;

        # Property option handling
        if $prop.isa(Whatever) { $prop = 'Clusters' }
        my $knownProperties = <MeanPoints Clusters ClusterLabels IndexClusters Properties All>;
        if !($prop ~~ Str && $prop ∈ $knownProperties) {
            die "The value of the argument prop is expected to be Whatever or one of { $knownProperties.raku }."
        }
        if $prop.lc eq 'properties' { return $knownProperties; }

        # Sanity check
        if @inputs.elems < $nSeeds {
            die 'The number of requested clusters is larger than the number of data points.'
        }

        # Main algorithm
        my @means = @inputs.pick($nSeeds);
        my $meansDiff = Inf;

        # $newIndexes is for the number of points that have been re-assigned to new cluster centers
        my $newIndexes = @inputs.elems;
        my Numeric $tol = 10 ** (-$precision-goal);
        my Int $nSteps = 0;

        my $dMat;
        my @clustersIndexes;

        # Find the number of points re-assigned to new cluster centers
        while $meansDiff > $tol && $newIndexes ≥ $minReassignPoints && $nSteps < $max-steps {
            $nSteps += 1;

            # clusterIndexes[i] says to which cluster center input[i] is assigned to.
            my @clustersIndexesOld = @clustersIndexes;
            my @meansOld = @means;

            # Compute the distance matrix
            for ^@inputs -> $i {
                for ^@means.elems -> $c {
                    $dMat[$i][$c] = self.distance($distance-function, @means[$c], @inputs[$i]);
                }
            }

            if $learning-parameter > 0 {
                # Standard learning with eta

                @clustersIndexes = do for ^@inputs.elems -> $i {
                    my $j = $dMat[$i].minpairs.head.key;
#                    say $j;
#                    say '0: ',  @inputs[$j];
#                    say '1: ',  @means[$j];
#                    say '2: ', (@inputs[$i] >>-<< @means[$j]);
#                    say '3: ', ($learning-parameter <<*<< (@inputs[$i] >>-<< @means[$j]));
                    @means[$j] = @means[$j] >>+<< ($learning-parameter <<*<< (@inputs[$i] >>-<< @means[$j]));
                    $j
                }

            } else {

                @clustersIndexes = do for ^@inputs.elems -> $i {
                    my $j = $dMat[$i].minpairs.head.key;
                    $j
                }

                my @inputClusterIndexPairs = @clustersIndexes Z=> @inputs;
                my @zeroVec = 0.0 xx @inputs[0].elems;
                @means = @inputClusterIndexPairs.categorize({ $_.key }).map({ my @s = @zeroVec; for $_.value>>.value -> $v { @s = @s >>+<< $v }; @s >>/>> $_.value.elems });
                #say @inputClusterIndexPairs.categorize({ $_.key }).map({ ([>>+<<] $_.value>>.value) >>/>> $_.elems }).raku;
                #@means = @inputClusterIndexPairs.categorize({ $_.key }).map({ ([>>+<<] $_.value>>.value) >>/>> $_.elems });
            }

            # Find the number of points re - assigned to new cluster centers
            if $nSteps > 1 {
                $newIndexes = self.hamming-distance(@clustersIndexes, @clustersIndexesOld)
            }

            # Displacement of the cluster centers
            $meansDiff = (@means Z @meansOld).map({ self.distance($distance-function, $_[0], $_[1]) }).sum;
        }

        my @inputClusterIndexPairs = @clustersIndexes Z=> @inputs;
        my @clusters = @inputClusterIndexPairs.categorize({ $_.key }).map({ $_.value>>.value });

        @inputClusterIndexPairs = @clustersIndexes Z=> ^@inputs.elems;
        my @indexClusters = @inputClusterIndexPairs.categorize({ $_.key }).map({ $_.value>>.value });

        my %res = MeanPoints => @means, Clusters => @clusters, ClusterLabels => @clustersIndexes, ClusterIndexes => @indexClusters;
        if $prop.lc eq 'all' {
            return %res;
        } else {
            %res{$prop}
        }
    }
}