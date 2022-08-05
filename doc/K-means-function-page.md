# `k-means` function page

## Introduction

This computable document has explanations and examples of using the function `k-means` of the package
["ML::Clustering"](https://github.com/antononcube/Raku-ML-Clustering), [AAp1].

For an introduction to the [K-means](https://en.wikipedia.org/wiki/K-means_clustering) algorithm see [Wk1] or [AN1].

The implementation uses the distance functions Euclidean, Cosine, Hamming, Manhattan, and others.

The data in the examples below is generated and manipulated with the packages
["Data::Generators"](https://raku.land/zef:antononcube/Data::Generators),
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), and
["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers), described in the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
[AA1].

The plots are made with the package
["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp6].

**Remark:** By default `find-clusters` of [AAp1] uses the K-means algorithm. The function `k-means`
calls `find-clusters` with the option setting `method=>'K-means'`.


-------

## In brief

The function `k-means` finds clusters using the K-means algorithm. Here are the arguments:

| Argument                      | Default      | Description                                                                                                          |
|-------------------------------|--------------|----------------------------------------------------------------------------------------------------------------------|
| `@points`                     | _            | data points                                                                                                          |
| `$k`                          | _            | number of clusters                                                                                                   |
| `:$distance-function`         | 'Euclidean'  | points distance function                                                                                             |
| `:$learning-parameter`        | 0.01         | re-assignment learning parameter                                                                                     |
| `:$max-steps`                 | 1000         | maximum number of steps                                                                                              |
| `:$min-reassignment-fraction` | 0.005        | minimum re-assignments required to continue the iterations                                                           |
| `:$precision-goal`            | 6            | precision goal                                                                                                       |
| `:$prop`                      | 'Clusters'   | property to give as a result, one of 'MeanPoints', 'Clusters', 'ClusterLabels', 'IndexClusters', 'Properties', 'All' |

-------

## Basic examples

Here we derive a set of random points, and summarize it:

```perl6
use Data::Generators;
use Data::Summarizers;
use Text::Plot;

my $n = 100;
my @data1 = (random-variate(NormalDistribution.new(5, 1.5), $n) X random-variate(NormalDistribution.new(5, 1), $n))
        .pick(30);
my @data2 = (random-variate(NormalDistribution.new(10, 1), $n) X random-variate(NormalDistribution.new(10, 1), $n))
        .pick(50);
my @data2D2 = [|@data1, |@data2].pick(*);
records-summary(@data2D2)
```
```
# +------------------------------+-----------------------------+
# | 1                            | 0                           |
# +------------------------------+-----------------------------+
# | Min    => 0.8824019896655129 | Min    => 2.152795216051352 |
# | 1st-Qu => 5.5846702059255655 | 1st-Qu => 5.166210322103936 |
# | Mean   => 8.09145990881722   | Mean   => 8.058710857432443 |
# | Median => 9.194317843131072  | Median => 9.14556329228429  |
# | 3rd-Qu => 10.141692047394958 | 3rd-Qu => 10.38535430504569 |
# | Max    => 12.313010385717398 | Max    => 12.34157809955947 |
# +------------------------------+-----------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +--+---------+---------+---------+---------+----------+----+       
# |                                                          |       
# +                                         *    * **        +  12.00
# |                                 *   **   * * *  * *      |       
# +                               ***     ****** *  *        +  10.00
# |                                     * *  ***  ***        |       
# +                      *                               *   +   8.00
# |                *            **                           |       
# +   *     * ***        **                                  +   6.00
# +      *** **** *       * *                                +   4.00
# |             *     *                                      |       
# +                                                          +   2.00
# |               *     *                                    |       
# +                                                          +   0.00
# +--+---------+---------+---------+---------+----------+----+       
#    2.00      4.00      6.00      8.00      10.00      12.00
```

Here is how we use the function `k-means` to find clusters:

```perl6
use ML::Clustering;
my @cls = |k-means(@data2D2, 2);
@cls>>.elems
```
```
# (30 50)
```

**Remark:** The first argument is data points that is a list-of-numeric-lists. The second argument is a number of
clusters to be found.

**Remark:**
Here are sample points from each found cluster:

```perl6
.say for @cls>>.pick(3);
```
```
# ((6.164886864107952 5.6276829332983915) (3.9859038623890966 4.5799177043056885) (3.9859038623890966 5.981356062660475))
# ((9.235405380378566 9.069274111707532) (10.38535430504569 9.784797148131712) (11.053242895868774 11.536909720126861))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# +-+---------+----------+----------+---------+----------+---+       
# |                                          ☐    ☐          |       
# +                                     ☐☐☐         ☐ ☐      +  12.00
# |                                ☐ ☐      ☐ ☐ ☐ ☐  ☐☐ ☐    |       
# +                                ☐☐☐   ☐☐☐☐  ☐☐ ☐  ☐       +  10.00
# |                                          ☐☐☐☐  ☐☐      ☐ |       
# +                      ▽                                   +   8.00
# |                ▽            ▽ ▽                          |       
# + ▽       ▽▽▽▽         ▽▽                                  +   6.00
# |     ▽▽▽  ▽▽ ▽ ▽       ▽ ▽                                |       
# +           ▽ ▽     ▽                                      +   4.00
# |                                                          |       
# +                                                          +   2.00
# |              ▽      ▽                                    |       
# +-+---------+----------+----------+---------+----------+---+       
#   2.00      4.00       6.00       8.00      10.00      12.00
```

------

## Scope

Here is more interesting looking two-dimensional data, `data2D2`:

```perl6
use Data::Reshapers;
my $pointsPerCluster = 200;
my @data2D5 = [[10, 20, 4], [20, 60, 6], [40, 10, 6], [-30, 0, 4], [100, 100, 8]].map({
    random-variate(NormalDistribution.new($_[0], $_[2]), $pointsPerCluster) Z random-variate(NormalDistribution.new(
            $_[1], $_[2]), $pointsPerCluster)
}).Array;
@data2D5 = flatten(@data2D5, max-level => 1).pick(*);
@data2D5.elems
```
```
# 1000
```

Here is a plot of that data:

```perl6
text-list-plot(@data2D5)
```
```
# +----------------+---------------+---------------+---------+        
# |                                                          |        
# |                                           ******** **    |        
# +                                        **************    +  100.00
# |                                           * **********   |        
# |                    ****                          *       |        
# |                 ***********                              |        
# +                  **********                              +   50.00
# |                      ** *                                |        
# |                ******    *                               |        
# |     *         ********  ********                         |        
# +   *******      ** *    **********                        +    0.00
# |   *******               *******                          |        
# |                                                          |        
# +----------------+---------------+---------------+---------+        
#                  0.00            50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(923);
my %clRes = find-clusters(@data2D5, 5, prop => 'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char => <1 2 3 4 5 ●>)
```
```
# +--------------+-----------------+----------------+--------+        
# +                                            1 11111 1     +  120.00
# |                                            11111111111   |        
# +                                         11111111●11111   +  100.00
# |                                              1111111 111 |        
# +                 333333                             1     +   80.00
# +                33333●333333                              +   60.00
# |                  3333333333                              |        
# +                     33 3                                 +   40.00
# |              2 222222                                    |        
# +              2222●222   444444444                        +   20.00
# | 5555555       22222 22 4444●4444                         |        
# +5555●555                 444444444                        +    0.00
# | 555555                                                   |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00
```

**Remark:** The function `k-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are the centers of the clusters (the mean points):

```perl6
%clRes<MeanPoints>
```
```
# [(9.551785725509388 19.639288713192233) (-30.11753150046125 0.0014953191527669416) (40.34786145750227 9.957098197999017) (19.810626987825515 59.864436396722716) (100.2979870132514 99.66817524598197)]
```

-------

## Control parameters (named arguments)

In this section we describe the named arguments of `find-clusters` that can be used to control the cluster finding
process.

### Distance function

The value of the argument `distance-function` specifies the distance function to be used -- close points tend to be
placed in the same cluster. Here is example comparing the "standard" Geometry distance, `euclidean-distance`, with the "
directional" distance, `cosine-distance`:

***TBD...***

Instead of distance functions we can use string identifiers of those functions:

```perl6
<Euclidean Cosine>.map({ say find-clusters(@data2D5, 3, distance-function => $_).&text-list-plot(
        title => 'distance function: ' ~ $_, point-char => <* ® o>), "\n" });
```
```
# distance function: Euclidean                
# +--------------+-----------------+----------------+--------+        
# +                                            * ***** *     +  120.00
# |                                            ***********   |        
# +                                         **************   +  100.00
# |                                              ******* *** |        
# +                 ®®®®®®                             *     +   80.00
# +                ®®®®®®®®®®®®                              +   60.00
# |                  ®®®®®®®®®®                              |        
# +                     ®® ®                                 +   40.00
# |              ® ®®®®®®                                    |        
# +              ®®®®®®®®   ®®®®®®®®®                        +   20.00
# | ooooooo       ®®®®® ®® ®®®®®®®®®                         |        
# +oooooooo                 ®®®®®®®®®                        +    0.00
# | oooooo                                                   |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                  distance function: Cosine                  
# +--------------+----------------+----------------+---------+        
# +                                                          +  120.00
# |                                           ooooooooooo    |        
# +                                        oooooooooooooo    +  100.00
# |                                           o ooooooooooo  |        
# +                      o                         o  o      +   80.00
# |                oooooooooo                                |        
# +                oooooooooooo                              +   60.00
# +                   oooo o                                 +   40.00
# |                oooo                                      |        
# +             ooooooooo  oo oooooo                         +   20.00
# | ®®®®® ®     o ooooooo ooooooooo                          |        
# +*®®®®®®*                ooooooooo                         +    0.00
# | ******                                                   |        
# +--------------+----------------+----------------+---------+        
#                0.00             50.00            100.00
```

### Learning parameter

At a certain execution step of the algorithm the learning parameter specifies how much the current mean points have to
be "pulled" in the direction of the estimated new points. Smaller values of the named argument `learning-parameter`
correspond to more cautious learning:

```perl6
(0.01, 0.1, 0.7).map({ say find-clusters(@data2D5, 2, learning-parameter => $_).&text-list-plot(
        title => 'learning-parameter:' ~ $_.Str, point-char => <* o>), "\n" });
```
```
# learning-parameter:0.01                   
# +---------------+----------------+----------------+--------+        
# +                                             ooo oo o     +  120.00
# |                                            oooooooooo o  |        
# +                                         ooooooooooooooo  +  100.00
# +                                               oooooo o o +   80.00
# |                  ******                            o     |        
# +                 ********** *                             +   60.00
# |                   ******* *                              |        
# +                         *                                +   40.00
# |               * *****     *                              |        
# +              *********  *********                        +   20.00
# |   *******      ** *    ***********                       |        
# +  *******                ** *** *                         +    0.00
# +   *                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.1                   
# +---------------+----------------+----------------+--------+        
# +                                             ooo oo o     +  120.00
# |                                            oooooooooo o  |        
# +                                         ooooooooooooooo  +  100.00
# +                                               oooooo o o +   80.00
# |                  ******                            o     |        
# +                 ********** *                             +   60.00
# |                   ******* *                              |        
# +                         *                                +   40.00
# |               * *****     *                              |        
# +              *********  *********                        +   20.00
# |   *******      ** *    ***********                       |        
# +  *******                ** *** *                         +    0.00
# +   *                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.7                   
# +---------------+----------------+----------------+--------+        
# +                                             ooo oo o     +  120.00
# |                                            oooooooooo o  |        
# +                                         ooooooooooooooo  +  100.00
# +                                               oooooo o o +   80.00
# |                  ******                            o     |        
# +                 ********** *                             +   60.00
# |                   ******* *                              |        
# +                         *                                +   40.00
# |               * *****     *                              |        
# +              *********  *********                        +   20.00
# |   *******      ** *    ***********                       |        
# +  *******                ** *** *                         +    0.00
# +   *                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

We see the plots above that with smaller learning parameter better results are obtained. But keep in mind that in some
situations that small learning parameters can make the computations too slow or produce worse clustering results.

### Maximum steps

The value m of the named argument `max-steps` is used in the stopping criteria of the implemented K-means algorithm --
if in the number of iterations exceeds m then the algorithms stops. Here is example that shows better clustering results
is obtained with larger max steps:

```perl6
(1, 4, 100).map({ say find-clusters(@data2D5, 2, max-steps => $_).&text-list-plot(title => 'maximum steps: ' ~ $_.Str,
        point-char => <* o>), "\n" });
```
```
# maximum steps: 1                      
# +---------------+----------------+---------------+---------+        
# +                                                          +  120.00
# |                                            **********    |        
# +                                        **************    +  100.00
# |                                           * ***********  |        
# +                    * *                            *      +   80.00
# |                ***********                               |        
# +                 ***********                              +   60.00
# +                     ****                                 +   40.00
# |                 ** **                                    |        
# +              oooooooo   ********                         +   20.00
# |  ooooooo       ooooooo oo*******                         |        
# + oooooooo                oooooo* *                        +    0.00
# |  oooo                                                    |        
# +---------------+----------------+---------------+---------+        
#                 0.00             50.00           100.00             
# 
#                       maximum steps: 4                      
# +---------------+----------------+----------------+--------+        
# +                                             *** ** *     +  120.00
# |                                            ********** *  |        
# +                                         ***************  +  100.00
# +                                               ****** * * +   80.00
# |                  oooooo                            *     |        
# +                 oooooooooo o                             +   60.00
# |                   ooooooo o                              |        
# +                         o                                +   40.00
# |               o ooooo     o                              |        
# +              ooooooooo  ooooooooo                        +   20.00
# |   ooooooo      oo o    ooooooooooo                       |        
# +  ooooooo                oo ooo o                         +    0.00
# +   o                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      maximum steps: 100                     
# +---------------+----------------+----------------+--------+        
# +                                             *** ** *     +  120.00
# |                                            ********** *  |        
# +                                         ***************  +  100.00
# +                                               ****** * * +   80.00
# |                  oooooo                            *     |        
# +                 oooooooooo o                             +   60.00
# |                   ooooooo o                              |        
# +                         o                                +   40.00
# |               o ooooo     o                              |        
# +              ooooooooo  ooooooooo                        +   20.00
# |   ooooooo      oo o    ooooooooooo                       |        
# +  ooooooo                oo ooo o                         +    0.00
# +   o                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

### Minimum reassignments fraction

The value `m` of the option "min-reassignments-fraction" is used in the stopping criteria of the implemented K-means
algorithm -- if in the last iteration step the fraction of the number of points that have changed clusters is less m
then the algorithms stops. Here is example that shows better clustering results is obtained with a smaller fraction:

```perl6
srand(9);
(0.01, 0.3).map({ say find-clusters(@data2D5, 3, min-reassigments-fraction => $_).&text-list-plot(
        title => 'min-reassigments-fraction: ' ~ $_.Str, point-char => Whatever), "\n" });
```
```
# min-reassigments-fraction: 0.01               
# +--------------+-----------------+----------------+--------+        
# +                                            □ □□□□□ □     +  120.00
# |                                            □□□□□□□□□□□   |        
# +                                         □□□□□□□□□□□□□□   +  100.00
# |                                              □□□□□□□ □□□ |        
# +                 ******                             □     +   80.00
# +                ************                              +   60.00
# |                  **********                              |        
# +                     ** *                                 +   40.00
# |              * ******                                    |        
# +              ********   *********                        +   20.00
# | ▽▽▽▽▽▽▽       ***** ** *********                         |        
# +▽▽▽▽▽▽▽▽                 *********                        +    0.00
# | ▽▽▽▽▽▽                                                   |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                min-reassigments-fraction: 0.3               
# +---------------+----------------+----------------+--------+        
# +                                             □□□□□□ □     +  120.00
# |                                            □□□□□□□□□□ □  |        
# +                                         □□□□□□□□□□□□□□□  +  100.00
# +                                               □□□□□□ □ □ +   80.00
# |                  ▽▽▽▽▽▽                            □     |        
# +                 ▽▽▽▽▽▽▽▽▽▽▽▽                             +   60.00
# |                   ▽▽▽▽▽▽▽▽▽                              |        
# +                         ▽                                +   40.00
# |               ▽ ▽▽▽▽▽    *                               |        
# +              ▽▽▽▽▽▽▽▽▽  *********                        +   20.00
# |  ▽▽▽▽▽▽▽       ▽▽▽▽    ***********                       |        
# + ▽▽▽▽▽▽▽▽                ****** *                         +    0.00
# +   ▽                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

### Precision goal

The value `p` of the named argument `precision-goal` is used specify in stopping criteria that evaluates the differences
between the "old" and "new" clusters centers -- if the maximum of that difference is less than `10 ** (-p)` then the
cluster finding iterations stop. Here is example that shows using the different precision goals:

```perl6
srand(1921);
(0.2, 5).map({ say find-clusters(@data2D5, 2, precision-goal => $_).&text-list-plot(title => 'precision goal: ' ~ $_
        .Str, point-char => Whatever), "\n" });
```
```
# precision goal: 0.2                     
# +---------------+----------------+----------------+--------+        
# +                                             *** ** *     +  120.00
# |                                            ********** *  |        
# +                                         ***************  +  100.00
# +                                               ****** * * +   80.00
# |                  □□□□□□                            *     |        
# +                 □□□□□□□□□□ □                             +   60.00
# |                   □□□□□□□ □                              |        
# +                         □                                +   40.00
# |               □ □□□□□     □                              |        
# +              □□□□□□□□□  □□□□□□□□□                        +   20.00
# |   □□□□□□□      □□ □    □□□□□□□□□□□                       |        
# +  □□□□□□□                □□ □□□ □                         +    0.00
# +   □                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      precision goal: 5                      
# +---------------+----------------+----------------+--------+        
# +                                             *** ** *     +  120.00
# |                                            ********** *  |        
# +                                         ***************  +  100.00
# +                                               ****** * * +   80.00
# |                  □□□□□□                            *     |        
# +                 □□□□□□□□□□ □                             +   60.00
# |                   □□□□□□□ □                              |        
# +                         □                                +   40.00
# |               □ □□□□□     □                              |        
# +              □□□□□□□□□  □□□□□□□□□                        +   20.00
# |   □□□□□□□      □□ □    □□□□□□□□□□□                       |        
# +  □□□□□□□                □□ □□□ □                         +    0.00
# +   □                                                      +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

-------

## Applications

### Animal weights clustering

Take animal weights `data2D2` (and show `data2D2` dimensions):

```perl6
use Data::ExampleDatasets;
my @data2D2 = |example-dataset('https://raw.githubusercontent.com/antononcube/Raku-ML-Clustering/main/resources/dfAnimalWeights.csv');
say "dimensions: { dimensions(@data2D2) }";
```
```
# dimensions: 28 3
```

Summarize:

```perl6
records-summary(@data2D2)
```
```
# +---------------------+----------------------+----------------------+
# | Species             | BrainWeight          | BodyWeight           |
# +---------------------+----------------------+----------------------+
# | Cat           => 1  | Min    => 0.4        | Min    => 0.023      |
# | GoldenHamster => 1  | 1st-Qu => 18.85      | 1st-Qu => 2.9        |
# | GreyWolf      => 1  | Mean   => 574.521429 | Mean   => 4278.43875 |
# | GuineaPig     => 1  | Median => 137        | Median => 53.83      |
# | Donkey        => 1  | 3rd-Qu => 421        | 3rd-Qu => 493        |
# | Chimpanzee    => 1  | Max    => 5712       | Max    => 87000      |
# | RhesusMonkey  => 1  |                      |                      |
# | (Other)       => 21 |                      |                      |
# +---------------------+----------------------+----------------------+
```

Cluster by body weight only:

```perl6
my %awRes1 = find-clusters(@data2D2.map({ [$_<BodyWeight>,] }), 4, prop => 'All');
.say for %awRes1<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>,
        align => { :Species<l> }) });
```
```
# +-----------------+------------+------------+
# | Species         | BodyWeight | BodyWeight |
# +-----------------+------------+------------+
# | Diplodocus      |   11700    |   11700    |
# | AfricanElephant |    6654    |    6654    |
# | Triceratops     |    9400    |    9400    |
# | Brachiosaurus   |   87000    |   87000    |
# +-----------------+------------+------------+
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | Cow           |    465     |    465     |
# | AsianElephant |    2547    |    2547    |
# | Horse         |    521     |    521     |
# | Giraffe       |    529     |    529     |
# +---------------+------------+------------+
# +----------------+------------+------------+
# | Species        | BodyWeight | BodyWeight |
# +----------------+------------+------------+
# | MountainBeaver |  1.350000  |  1.350000  |
# | GreyWolf       | 36.330000  | 36.330000  |
# | Goat           | 27.660000  | 27.660000  |
# | GuineaPig      |  1.040000  |  1.040000  |
# | PotarMonkey    |     10     |     10     |
# | Cat            |  3.300000  |  3.300000  |
# | Human          |     62     |     62     |
# | RhesusMonkey   |  6.800000  |  6.800000  |
# | Kangaroo       |     35     |     35     |
# | GoldenHamster  |  0.120000  |  0.120000  |
# | Mouse          |  0.023000  |  0.023000  |
# | Rabbit         |  2.500000  |  2.500000  |
# | Sheep          | 55.500000  | 55.500000  |
# | Jaguar         |    100     |    100     |
# | Chimpanzee     | 52.160000  | 52.160000  |
# | Rat            |  0.280000  |  0.280000  |
# | Mole           |  0.122000  |  0.122000  |
# +----------------+------------+------------+
# +---------+------------+------------+
# | Species | BodyWeight | BodyWeight |
# +---------+------------+------------+
# | Donkey  | 187.100000 | 187.100000 |
# | Gorilla |    207     |    207     |
# | Pig     |    192     |    192     |
# +---------+------------+------------+
```

Note that obtained clusters seem well separated by weight:

```perl6
text-list-plot(((%awRes1<ClusterLabels>.Array >>+>> 1) Z @data2D2.map({ $_<BodyWeight> }))>>.log10.List)
```
```
# +---+-------+--------+-------+--------+--------+-------+---+      
# |                                                          |      
# |   *                                                      |      
# +   *                                                      +  4.00
# |                                                      *   |      
# |                                                      *   |      
# +                            *               *             +  2.00
# |                                            *             |      
# |                                            *             |      
# |                                            *             |      
# +                                            *             +  0.00
# |                                            *             |      
# |                                            *             |      
# +                                                          + -2.00
# +---+-------+--------+-------+--------+--------+-------+---+      
#     0.00    0.10     0.20    0.30     0.40     0.50    0.60
```

Here we cluster using both body weight and brain weight -- for that combination of weights it makes sense to cluster
with Cosine distance:

```perl6
my %awRes2 = find-clusters(@data2D2.map({ $_<BodyWeight BrainWeight> }), 4, distance-function => 'Cosine',
        prop => 'All');
.say for %awRes2<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>,
        align => { :Species<l> }) });
```
```
# +-----------------+------------+------------+
# | Species         | BodyWeight | BodyWeight |
# +-----------------+------------+------------+
# | Cow             |    465     |    465     |
# | AsianElephant   |    2547    |    2547    |
# | Donkey          | 187.100000 | 187.100000 |
# | Horse           |    521     |    521     |
# | Giraffe         |    529     |    529     |
# | Gorilla         |    207     |    207     |
# | AfricanElephant |    6654    |    6654    |
# | Kangaroo        |     35     |     35     |
# | Jaguar          |    100     |    100     |
# | Pig             |    192     |    192     |
# +-----------------+------------+------------+
# +----------------+------------+------------+
# | Species        | BodyWeight | BodyWeight |
# +----------------+------------+------------+
# | MountainBeaver |  1.350000  |  1.350000  |
# | GreyWolf       | 36.330000  | 36.330000  |
# | Goat           | 27.660000  | 27.660000  |
# | GuineaPig      |  1.040000  |  1.040000  |
# | Cat            |  3.300000  |  3.300000  |
# | GoldenHamster  |  0.120000  |  0.120000  |
# | Rabbit         |  2.500000  |  2.500000  |
# | Sheep          | 55.500000  | 55.500000  |
# | Chimpanzee     | 52.160000  | 52.160000  |
# | Rat            |  0.280000  |  0.280000  |
# +----------------+------------+------------+
# +--------------+------------+------------+
# | Species      | BodyWeight | BodyWeight |
# +--------------+------------+------------+
# | PotarMonkey  |     10     |     10     |
# | Human        |     62     |     62     |
# | RhesusMonkey |  6.800000  |  6.800000  |
# | Mouse        |  0.023000  |  0.023000  |
# | Mole         |  0.122000  |  0.122000  |
# +--------------+------------+------------+
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | Diplodocus    |   11700    |   11700    |
# | Triceratops   |    9400    |    9400    |
# | Brachiosaurus |   87000    |   87000    |
# +---------------+------------+------------+
```

Note that obtained clusters seem well separated by body-brain weights directions:

```perl6
text-list-plot(%awRes2<Clusters>>>.log10);
```
```
# +-------+-------+--------+-------+-------+--------+-------++      
# +                                               *          +  4.00
# |                                            *             |      
# +                              ❍                           +  3.00
# |                              ▽   **  *                   |      
# |                      ❍       ▽   *                       |      
# +                        ❍  ▽▽   *               □        □+  2.00
# |                            *                    □        |      
# |                    ▽                                     |      
# +               ▽▽  ▽                                      +  1.00
# |        ❍                                                 |      
# +       ▽   ▽                                              +  0.00
# |                                                          |      
# | ❍                                                        |      
# +-------+-------+--------+-------+-------+--------+-------++      
#         -1.00   0.00     1.00    2.00    3.00     4.00    5.00
```

------

## Properties and Relations

Often it is good idea to run `k-means` a few times:

```perl6
for 1 ... 3 {
    say text-list-plot(k-means(@data2D5, 5), point-char => (1 .. 5)>>.Str, title => "run: { $_ }"), "\n";
}
```
```
# run: 1                           
# +--------------+-----------------+----------------+--------+        
# +                                            4 44444 4     +  120.00
# |                                            44444444444   |        
# +                                         44444444444444   +  100.00
# |                                              4444444 444 |        
# +                  33333                             4     +   80.00
# +                333333333333                              +   60.00
# |                 33333333333                              |        
# +                     33 3                                 +   40.00
# |              3 333333                                    |        
# +             333333333   111111111                        +   20.00
# | 22222 2      333333 11 111111111                         |        
# +55555555                 111111111                        +    0.00
# | 555555                                                   |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                            run: 2                           
# +---------------+-----------------+----------------+-------+        
# +                                             22 444 4     +  120.00
# |                                             22244444333  |        
# +                                         22 2222111133313 +  100.00
# +                                               11111 1 1 3+   80.00
# |                   55555 5                          1     |        
# +                 555555555555                             +   60.00
# |                   5555555 55                             |        
# +                                                          +   40.00
# |                5555555    5                              |        
# +    5          555555555 555555555                        +   20.00
# |   5555555      55  5    5555555555                       |        
# +  55555555                5555555                         +    0.00
# +   5                                                      +  -20.00
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00           
# 
#                            run: 3                           
# +--------------+-----------------+----------------+--------+        
# +                                            3 33333 3     +  120.00
# |                                            33333333333   |        
# +                                         33333333333333   +  100.00
# |                                              3333333 333 |        
# +                 444444                             3     +   80.00
# +                444444444444                              +   60.00
# |                  4444444444                              |        
# +                     44 4                                 +   40.00
# |              2 222222                                    |        
# +              22222222   111111111                        +   20.00
# | 5555555       22222 22 111111111                         |        
# +55555555                 111111111                        +    0.00
# | 555555                                                   |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00
```

-------

## Possible Issues

The initial mean points of the clusters are chosen at random. Hence, to reproduce clustering results `srand` has to be
used.

-------

## Neat Examples

Extracted point-vectors from a rasterized formula `x^2 + y^2 == 1`:

```perl6
my @blackPoints = [[11, 15], [40, 15], [9, 14], [10, 14], [11, 14], [12, 14], [13, 14], [38, 14], [39, 14], [40, 14], [41, 14], [42, 14], [9, 13], [10, 13], [12, 13], [13, 13], [38, 13], [39, 13], [41, 13], [42, 13], [12, 12], [13, 12], [41, 12], [42, 12], [11, 11], [12, 11], [40, 11], [41, 11], [64, 11], [65, 11], [66, 11], [67, 11], [10, 10], [11, 10], [12, 10], [39, 10], [40, 10], [41, 10], [64, 10], [65, 10], [66, 10], [67, 10], [2, 9], [3, 9], [6, 9], [7, 9], [9, 9], [10, 9], [11, 9], [12, 9], [13, 9], [30, 9], [31, 9], [35, 9], [36, 9], [37, 9], [38, 9], [39, 9], [40, 9], [41, 9], [42, 9], [66, 9], [67, 9], [2, 8], [3, 8], [4, 8], [5, 8], [6, 8], [7, 8], [22, 8], [23, 8], [31, 8], [32, 8], [35, 8], [36, 8], [66, 8], [67, 8], [3, 7], [4, 7], [5, 7], [6, 7], [22, 7], [23, 7], [31, 7], [32, 7], [35, 7], [36, 7], [50, 7], [51, 7], [52, 7], [53, 7], [54, 7], [55, 7], [56, 7], [57, 7], [58, 7], [66, 7], [67, 7], [3, 6], [4, 6], [5, 6], [20, 6], [21, 6], [22, 6], [23, 6], [24, 6], [25, 6], [31, 6], [32, 6], [33, 6], [34, 6], [35, 6], [36, 6], [50, 6], [51, 6], [52, 6], [53, 6], [54, 6], [55, 6], [56, 6], [57, 6], [66, 6], [67, 6], [3, 5], [4, 5], [5, 5], [6, 5], [20, 5], [21, 5], [22, 5], [23, 5], [24, 5], [25, 5], [32, 5], [33, 5], [34, 5], [35, 5], [50, 5], [51, 5], [52, 5], [53, 5], [55, 5], [56, 5], [57, 5], [66, 5], [67, 5], [2, 4], [3, 4], [4, 4], [5, 4], [6, 4], [7, 4], [22, 4], [23, 4], [32, 4], [33, 4], [34, 4], [35, 4], [50, 4], [51, 4], [52, 4], [53, 4], [54, 4], [55, 4], [56, 4], [57, 4], [58, 4], [64, 4], [65, 4], [66, 4], [67, 4], [68, 4], [69, 4], [1, 3], [2, 3], [3, 3], [6, 3], [7, 3], [22, 3], [23, 3], [33, 3], [34, 3], [64, 3], [65, 3], [66, 3], [67, 3], [68, 3], [69, 3], [33, 2], [34, 2], [31, 1], [32, 1], [33, 1], [34, 1], [30, 0], [31, 0], [32, 0], [33, 0]];
```
```
# [[11 15] [40 15] [9 14] [10 14] [11 14] [12 14] [13 14] [38 14] [39 14] [40 14] [41 14] [42 14] [9 13] [10 13] [12 13] [13 13] [38 13] [39 13] [41 13] [42 13] [12 12] [13 12] [41 12] [42 12] [11 11] [12 11] [40 11] [41 11] [64 11] [65 11] [66 11] [67 11] [10 10] [11 10] [12 10] [39 10] [40 10] [41 10] [64 10] [65 10] [66 10] [67 10] [2 9] [3 9] [6 9] [7 9] [9 9] [10 9] [11 9] [12 9] [13 9] [30 9] [31 9] [35 9] [36 9] [37 9] [38 9] [39 9] [40 9] [41 9] [42 9] [66 9] [67 9] [2 8] [3 8] [4 8] [5 8] [6 8] [7 8] [22 8] [23 8] [31 8] [32 8] [35 8] [36 8] [66 8] [67 8] [3 7] [4 7] [5 7] [6 7] [22 7] [23 7] [31 7] [32 7] [35 7] [36 7] [50 7] [51 7] [52 7] [53 7] [54 7] [55 7] [56 7] [57 7] [58 7] [66 7] [67 7] [3 6] [4 6] ...]
```

Plot the extracted point-vectors:

```perl6
text-list-plot(@blackPoints, width => 76, height => 18)
```
```
# +--+-------------------+------------------+-------------------+------------+       
# |                                                                          |       
# +             *                           *                                +  15.00
# |           *****                       *****                              |       
# |           ** **                       ** **                              |       
# |             **                          **                      ****     |       
# +            ***                         ***                      ****     +  10.00
# |    **  ** *****                **  ********                       **     |       
# |    ******              **       *  **                             **     |       
# |     ****               **       *  **             *********       **     |       
# |     ***              ******     *****             ********        **     |       
# +     ****             ******     ****              **** ***        **     +   5.00
# |    ******              **       ****              *********     ******   |       
# |   ***  **              **        **                             ******   |       
# |                                 ***                                      |       
# +                                ***                                       +   0.00
# |                                                                          |       
# +--+-------------------+------------------+-------------------+------------+       
#    0.00                20.00              40.00               60.00
```

Cluster and plot the clusters using different distance functions:

```perl6
<Euclidean Cosine Chessboard Manhattan BrayCurtis Canberra>.map({
    say text-list-plot(k-means(@blackPoints, 7, distance-function => $_), point-char => (1 .. 7)>>.Str, title => $_,
            width => 76, height => 18), "\n"
})
```
```
# Euclidean                                  
# +----------+---------+----------+----------+---------+----------+---------++       
# +           3                              1                               +  15.00
# |         33333                          11111                             |       
# |         33 33                          11 11                             |       
# |            33                             11                             |       
# |           33                             11                       6666   |       
# +          333                            111                       6666   +  10.00
# | 77   77 33333                 44   411 11111                        66   |       
# | 777 777               55       44  44                               66   |       
# |  77 77                55       44  44              22222 2226       66   |       
# |  77 7              5 55555     444444              22222 222        66   |       
# +  77 77             5 55555      4444               2222  222        66   +   5.00
# | 777 777               55        4444               22222 2226     666666 |       
# |777   77               55         44                               666666 |       
# |                                  44                                      |       
# |                                4444                                      |       
# +                               4444                                       +   0.00
# +----------+---------+----------+----------+---------+----------+---------++       
#            10.00     20.00      30.00      40.00     50.00      60.00     70.00    
# 
#                                    Cosine                                   
# +--------------------+--------------------+--------------------+-----------+       
# |                                                                          |       
# +           5                             6                                +  15.00
# |         55222                         66666                              |       
# |         55 22                         66 66                              |       
# |           22                            66                       7777    |       
# +          222                           666                       7777    +  10.00
# |  55  52 22222                 66   66666666                        77    |       
# |  555552              66        66  66                              77    |       
# |   5552               66        66  77             7777777 77       33    |       
# |   552              666666      777777             7777333 3        33    |       
# +   5222             666677       7777              3333 33 3        33    +   5.00
# |  552226              77         7777              3333333 33     111111  |       
# | 552  66              77          33                              111111  |       
# |                                  11                                      |       
# |                                1444                                      |       
# +                               4444                                       +   0.00
# +--------------------+--------------------+--------------------+-----------+       
#                      20.00                40.00                60.00               
# 
#                                  Chessboard                                 
# ++---------+----------+---------+----------+----------+---------+----------+       
# |                                                                          |       
# +           6                              2                               +  15.00
# |         66666                          22222                             |       
# |            66                             22                             |       
# |           66                             22                       11 11  |       
# +          666                            222                       11 11  +  10.00
# |  66  66 66666                 44    44222222                         11  |       
# |  666666               44       44   44                               11  |       
# |   6666                44       44   44              777555533        11  |       
# |   666               444444     44 4444              77755533         11  |       
# +   6666              444444      4 444               7777 333         11  +   5.00
# |  666666               44        4 444               777733333     11 1111|       
# | 666  66               44          44                              11 1111|       
# |                                   44                                     |       
# |                                44 44                                     |       
# +                               444 4                                      +   0.00
# ++---------+----------+---------+----------+----------+---------+----------+       
#  0.00      10.00      20.00     30.00      40.00      50.00     60.00              
# 
#                                  Manhattan                                  
# +----------+---------+----------+---------+----------+---------+----------++       
# |                                                                          |       
# +           7                             3                                +  15.00
# |         77777                         33333                              |       
# |         77 77                         33 33                              |       
# |           77                            33                        5555   |       
# +          777                           333                        5555   +  10.00
# | 44   44 77777                 33   33333333                         55   |       
# | 4444 44              33        33  33                               55   |       
# |  222 2               33        33  33              555555555        55   |       
# |  226               3333 33     333333              55555555         55   |       
# +  266 6             3333 33      3333               5555 555         55   +   5.00
# | 6666 61              33         3333               555555555      555555 |       
# |666   11              33          33                               555555 |       
# |                                3333                                      |       
# +                               3333                                       +   0.00
# |                                                                          |       
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                  BrayCurtis                                 
# +----------+----------+---------+----------+---------+----------+----------+       
# +           5                              2                               +  15.00
# |         55555                          22222                             |       
# |         55 55                          22 22                             |       
# |            55                             22                             |       
# |           55                             22                       11 11  |       
# +          555                            222                       11 11  +  10.00
# | 55   55 55555                 66    22222222                         11  |       
# | 33 3355               77       66   62                               11  |       
# |  3 333                77       66   66             4 44444444        11  |       
# |  3 33               777777     6666 66             4 4444444         11  |       
# +  3 333              777777      666 6              4 444 444         11  +   5.00
# | 33 3333               77        666 6              4 44444444     11 1111|       
# |333   33               77         66                               11 1111|       
# |                                  66                                      |       
# |                                6666                                      |       
# +                               6666                                       +   0.00
# +----------+----------+---------+----------+---------+----------+----------+       
#            10.00      20.00     30.00      40.00     50.00      60.00              
# 
#                                   Canberra                                  
# +-+-------------------+--------------------+--------------------+----------+       
# +            2                             1                               +  15.00
# |          22222                         11111                             |       
# |          22 22                         11 11                             |       
# |             22                            11                             |       
# |            22                            11                       5555   |       
# +           222                           111                       5555   +  10.00
# |   77  77 72222                 11   11111111                        55   |       
# |   777777              24        44  11                              55   |       
# |    7777               44        44  44             55555 5555       55   |       
# |    777              4444 44     444444             55555 555        55   |       
# +    7777             4444 44      4444              3333  333        33   +   5.00
# |   777777              66         6666              33333 3333     333333 |       
# |  677  77              66          66                              333333 |       
# |                                   66                                     |       
# |                                 6666                                     |       
# +                                4444                                      +   0.00
# +-+-------------------+--------------------+--------------------+----------+       
#   0.00                20.00                40.00                60.00
```

-------

## References

### Articles, books

[Wk1] Wikipedia entry, ["K-means clustering"](https://en.wikipedia.org/wiki/K-means_clustering).

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/)
,
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AN1] Amiya Nayak and Ivan Stojmenovic,
"Handbook of Applied Algorithms: Solving Scientific, Engineering, and Practical Problems", Wiley, 2008. ISBN:
0470044926, 9780470044926.

### Packages

[AAp1] Anton Antonov,
[ML::Clustering Raku package](https://github.com/antononcube/Raku-ML-Clustering),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Data::Generators Raku package](https://github.com/antononcube/Raku-Data-Generators),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp3] Anton Antonov,
[Data::Reshapers Raku package](https://github.com/antononcube/Raku-Data-Reshapers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp4] Anton Antonov,
[Data::Summarizers Raku package](https://github.com/antononcube/Raku-Data-Summarizers),
(2021),
[GitHub/antononcube](https://github.com/antononcube).

[AAp5] Anton Antonov,
[UML::Translators Raku package](https://github.com/antononcube/Raku-UML-Translators),
(2022),
[GitHub/antononcube](https://github.com/antononcube).

[AAp6] Anton Antonov,
[Text::Plot Raku package](https://raku.land/zef:antononcube/Text::Plot),
(2022),
[GitHub/antononcube](https://github.com/antononcube).
