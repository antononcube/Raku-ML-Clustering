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
            when $spec ∈ <BrayCurtis BrayCurtisDistance>>>.lc { return self.bray-curtis-distance(@v1, @v2); }
            when $spec ∈ <Canberra CanberraDistance>>>.lc { return self.canberra-distance(@v1, @v2); }
            when $spec ∈ <Chessboard ChessboardDistance>>>.lc { return self.chessboard-distance(@v1, @v2); }
            when $spec ∈ <Cosine CosineDistance>>>.lc { return self.cosine-distance(@v1, @v2); }
            when $spec ∈ <Euclidean EuclideanDistance>>>.lc { return self.euclidean-distance(@v1, @v2); }
            when $spec ∈ <Hamming HammingDistance>>>.lc { return self.hamming-distance(@v1, @v2); }
            when $spec ∈ <Manhattan ManhattanDistance>>>.lc { return self.manhattan-distance(@v1, @v2); }
            when $spec ∈ <SquaredEuclidean SquaredEuclideanDistance>>>.lc { return self.squared-euclidean-distance(@v1, @v2); }
            default {
                die "Do not know how to compute distance named $spec.";
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
    ## SquaredEuclidean
    ##-------------------------------------------------------

    method squared-euclidean-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return [+] (@v1 Z @v2).map({ ($_[0] - $_[1]) ** 2});
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

    multi method hamming-distance(@v1, @v2 --> Numeric) {

        if @v1.elems != @v2.elems {
            die $msgSameLengths;
        }

        # Compute distance
        return (@v1 Zne @v2).sum;
    }

    multi method hamming-distance(Str $v1, Str $v2 --> Numeric) {
        return self.hamming-distance($v1.comb, $v2.comb);
    }

    ##-------------------------------------------------------
    ## Manhattan
    ##-------------------------------------------------------

    method manhattan-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return (@v1 >>-<< @v2)>>.abs.sum;
    }

    ##-------------------------------------------------------
    ## Chessboard
    ##-------------------------------------------------------

    method chessboard-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return (@v1 >>-<< @v2)>>.abs.max;
    }

    ##-------------------------------------------------------
    ## Bray-Curtis
    ##-------------------------------------------------------

    method bray-curtis-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return (@v1 >>-<< @v2)>>.abs.sum / (@v1 >>+<< @v2)>>.abs.sum;
    }

    ##-------------------------------------------------------
    ## Canberra
    ##-------------------------------------------------------

    method canberra-distance(@v1, @v2 --> Numeric) {

        if !self.args-check(@v1, @v2) {
            die;
        }

        # Compute distance
        return sum((@v1 >>-<< @v2)>>.abs >>/<< (@v1>>.abs >>+<< @v2>>.abs));
    }
}