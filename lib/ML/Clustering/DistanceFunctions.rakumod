use v6.d;

use Data::Reshapers;

role ML::Clustering::DistanceFunctions {

    ##-------------------------------------------------------
    ## Arguments check
    ##-------------------------------------------------------

    my $msgSameLengths = 'The given vectors are expected to have the same number of arguments.';

    method args-check(@v1, @v2 --> Bool) {
        # Check arguments
        if @v1.elems != @v2.elems {
            warn $msgSameLengths;
            return False;
        }

        if ! ( @v1.all ~~ Numeric ) {
            warn 'All elements of the first argument are expected to be numeric';
            return False;
        }

        if ! ( @v2.all ~~ Numeric ) {
            warn 'All elements of the second argument are expected to be numeric';
            return False;
        }

        return True
    }

    ##-------------------------------------------------------
    ## Norm
    ##-------------------------------------------------------

    multi method norm(@vec --> Numeric) {
        return self.norm('euclidean', @vec);
    }

    multi method norm($spec, @vec --> Numeric) {
        given $spec {
            when $_ (elem) <max-norm inf-norm inf infinity> { @vec.map({ abs($_) }).max }
            when $_.Str eq '1' or $_ (elem) <one-norm one sum> { @vec.map({ abs($_) }).sum }
            when $_.isa(Whatever) or $_
                    .Str eq '2' or $_ (elem) <euclidean cosine two-norm two> { sqrt(sum(@vec <<*>> @vec)) }
            default { die "Unknown norm specification '$spec'."; }
        }
    }

    ##-------------------------------------------------------
    ## Distance
    ##-------------------------------------------------------
    method distance(Str $spec, @v1, @v2) {
        given $spec.lc {
            when $spec ∈ <Euclidean EuclideanDistance>>>.lc { return self.euclidean-distance(@v1, @v2); }
            when $spec ∈ <Cosine CosineDistance>>>.lc { return self.cosine-distance(@v1, @v2); }
            when $spec ∈ <Hamming HammingDistance>>>.lc { return self.hamming-distance(@v1, @v2); }
            default {
                die "Do not how to compute distance named $spec.";
            }
        }
    }

    ##-------------------------------------------------------
    ## Euclidean
    ##-------------------------------------------------------

    method euclidean-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return sqrt( [+] (@v1 Z @v2).map({ ($_[0] - $_[1]) ** 2}));
    }

    ##-------------------------------------------------------
    ## Cosine
    ##-------------------------------------------------------

    method cosine-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return 1.0 - ([+] (@v1 >>*<< @v2) ) / ( self.norm(@v1) * self.norm(@v2) );
    }

    ##-------------------------------------------------------
    ## Hamming
    ##-------------------------------------------------------

    method hamming-distance(@v1, @v2 --> Numeric) {

        if @v1.elems != @v2.elems {
            die $msgSameLengths;
        }

        # Compute distance
        return (@v1 Zne @v2).sum;
    }
}