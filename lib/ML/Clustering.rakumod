#!/usr/bin/env raku
use v6.d;

use ML::Clustering::DistanceFunctions;
use ML::Clustering::KMeans;

unit module ML::Clustering;

#------------------------------------------------------------
#| Find clusters using the K-means algorithm.
#| C<@points> -- data points.
#| C<$k> -- number of clusters.
#| C<:$distance-function> -- points distance function.
#| C<:$learning-parameter> -- re-assignment learning parameter.
#| C<:$max-steps> -- maximum number of steps.
#| C<:$min-reassignment-fraction> -- minimum re-assignments required to continue the iterations.
#| C<:$precision-goal> -- precision goal.
#| C<:$prop> -- property to give as a result, one of 'MeanPoints', 'Clusters', 'ClusterLabels', 'IndexClusters', 'Properties', 'All'.
our sub k-means(@points, $k, *%args) is export {
    return find-clusters(@points, $k, method => 'k-means', |%args);
}

#------------------------------------------------------------
#| Find clusters.
#| C<@points> -- data points.
#| C<$k> -- number of clusters.
#| C<:$method> -- method to use, one of Whatever, 'K-means', 'K-medoids', or 'Bi-sectional-k-means'.
#| C<:$distance-function> -- points distance function.
#| C<:$learning-parameter> -- re-assignment learning parameter.
#| C<:$max-steps> -- maximum number of steps.
#| C<:$min-reassignment-fraction> -- minimum re-assignments required to continue the iterations.
#| C<:$precision-goal> -- precision goal.
#| C<:$prop> -- property to give as a result, one of 'MeanPoints', 'Clusters', 'ClusterLabels', 'IndexClusters', 'Properties', 'All'.
our sub find-clusters(@points, $k, *%args) is export {

    my $method = 'k-means';
    if %args<method>:exists {
        $method = %args<method>
    }

    if !( $method ~~ Str && $method.lc ∈ <kmeans k-means> ) {
        die 'Only method \'K-means\' is implemented. Continuing with \'K-means\'.';
    }

    if $method.lc ∈ <kmeans k-means> {
        return ML::Clustering::KMeans.find-clusters(@points, $k, |%args.grep({ $_.key ne 'method' }).Hash );
    } else {
        die 'Do not know what to do with the given method.'
    }
}
