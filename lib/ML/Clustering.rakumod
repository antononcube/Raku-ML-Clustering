#!/usr/bin/env raku
use v6.d;

use ML::Clustering::DistanceFunctions;
use ML::Clustering::KMeans;

unit module ML::Clustering;

sub find-clusters(@inputs, $nClusters, *%args) is export {

    my $method = 'k-means';
    if %args<method>:exists {
        $method = %args<method>
    }

    if !( $method ~~ Str && $method.lc ∈ <kmeans k-means> ) {
        die 'Only method \'K-means\' is implemented. Continuing with \'K-means\'.';
    }

    if $method.lc ∈ <kmeans k-means> {
        return ML::Clustering::KMeans.find-clusters(@inputs, $nClusters, |%args.grep({ $_.key ne 'method' }).Hash );
    } else {
        die 'Do not know what to do with the given method.'
    }
}
