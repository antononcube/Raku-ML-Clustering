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
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA1].

The plots are made with the package
["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp6].

**Remark:** By default `find-clusters` of [AAp1] uses the K-means algorithm. The function `k-means` 
calls `find-clusters` with the option setting `method=>'K-means'`.


-------

## Basic examples 

Here we derive a set of random points, and summarize it:

```perl6
use Data::Generators;
use Data::Summarizers;
use Text::Plot;

my $n = 100;
my @data1 = (random-variate(NormalDistribution.new(5,1.5), $n) X random-variate(NormalDistribution.new(5,1), $n)).pick(30);
my @data2 = (random-variate(NormalDistribution.new(10,1), $n) X random-variate(NormalDistribution.new(10,1), $n)).pick(50);
my @data2D2 = [|@data1, |@data2].pick(*);
records-summary(@data2D2)
```
```
# +------------------------------+------------------------------+
# | 1                            | 0                            |
# +------------------------------+------------------------------+
# | Min    => 2.695973658339584  | Min    => 1.161503375563047  |
# | 1st-Qu => 5.323852064697945  | 1st-Qu => 4.843399044311585  |
# | Mean   => 8.111648377178188  | Mean   => 7.852664725468367  |
# | Median => 9.26578744096337   | Median => 9.19712296143257   |
# | 3rd-Qu => 10.342159371494283 | 3rd-Qu => 10.052430531414808 |
# | Max    => 12.547146218415426 | Max    => 11.385517475067733 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +-------+---------+---------+---------+---------+---------++       
# |                                                          |       
# +                                           * *            +  12.00
# |                                             *****  *     |       
# +                                       * *** * ** * **    +  10.00
# |                                        * ** **** *****   |       
# |                                           *    *     *   |       
# +                                          *               +   8.00
# |                                     *       *            |       
# +   *           *  * *  * *    *                           +   6.00
# |       **    *     *****  *     *    *                    |       
# +          *       **                                      +   4.00
# |        *   **                                            |       
# +                                                          +   2.00
# +-------+---------+---------+---------+---------+---------++       
#         2.00      4.00      6.00      8.00      10.00     12.00
```

Here is how we use the function `k-means` to find clusters:

```perl6
use ML::Clustering;
my @cls = |k-means(@data2D2, 2);
@cls>>.elems
```
```
# (51 29)
```

**Remark:** The first argument is data points that is a list-of-numeric-lists. 
The second argument is a number of clusters to be found. 

**Remark:** 
Here are sample points from each found cluster:

```perl6
.say for @cls>>.pick(3);
```
```
# ((10.432426680199464 11.078634763257302) (10.720305365912793 9.68063421870811) (9.811885232997058 9.89107457367072))
# ((5.532344283869239 5.54628409036646) (4.7273941676840385 4.835865508530682) (2.2970718597527364 5.053263457876329))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# +------+----------+---------+----------+----------+--------+       
# |                                             ▽            |       
# +                                              ▽ ▽         +  12.00
# |                                              ▽▽▽▽▽▽  ▽   |       
# +                                        ▽ ▽▽▽▽▽▽▽▽▽ ▽▽▽▽  +  10.00
# |                                         ▽  ▽  ▽▽▽   ▽▽▽  |       
# |                                            ▽    ▽      ▽ |       
# +                                           ▽              +   8.00
# |                                      ▽                   |       
# +  ☐               ☐ ☐  ☐ ☐                     ▽          +   6.00
# |       ☐☐    ☐ ☐   ☐☐☐☐☐   ☐  ☐  ☐    ☐                   |       
# +        ☐☐        ☐☐                                      +   4.00
# |       ☐    ☐                                             |       
# |             ☐                                            |       
# +------+----------+---------+----------+----------+--------+       
#        2.00       4.00      6.00       8.00       10.00
```

------

## Scope

Here is more interesting looking two-dimensional data, `data2D2`:

```perl6
use Data::Reshapers;
my $pointsPerCluster = 200;
my @data2D5 = [[10,20,4],[20,60,6],[40,10,6],[-30,0,4],[100,100,8]].map({ 
    random-variate(NormalDistribution.new($_[0], $_[2]), $pointsPerCluster) Z random-variate(NormalDistribution.new($_[1], $_[2]), $pointsPerCluster)
   }).Array;
@data2D5 = flatten(@data2D5, max-level=>1).pick(*);
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
# ++---------------+---------------+---------------+---------+        
# |                                                          |        
# |                                               **** *     |        
# |                                          ***********     |        
# +                                        * *************   +  100.00
# |                      * *                   * ****  **    |        
# |                  ********  *                             |        
# |                 ***********                              |        
# +                   ********                               +   50.00
# |                 **** *    **                             |        
# |               ********* ******** *                       |        
# +   *******        **   ************                       +    0.00
# |    ****** *            * * ** *                          |        
# |                                                          |        
# ++---------------+---------------+---------------+---------+        
#  -50.00          0.00            50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(32);
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +---------------+----------------+----------------+--------+        
# |                                                  4       |        
# |                                               4 444444   |        
# +                                         4 444444●44444 4 +  100.00
# |                                            444444444444  |        
# |                     1 1                       44 4   44  |        
# |                 111111111  1                             |        
# |                111111●1111                               |        
# +                  11 111111                               +   50.00
# |                 222       5                              |        
# |              2222●2222  5 555555 5                       |        
# |33333333       222222  55555●555555                       |        
# + 333●333 3              555555555                         +    0.00
# |   3 3                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

**Remark:** The function `k-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are the centers of the clusters (the mean points):

```perl6
%clRes<MeanPoints>
```
```
# [(20.18297516448547 58.53977797886236) (-29.669442217016634 0.06766194490290872) (9.77806615116641 20.18832214714496) (39.910133348874375 10.03437982515635) (99.42660899942406 100.06064233764445)]
```

-------

## Control parameters (named arguments)

In this section we describe the named arguments of `find-clusters` that can be used to
control the cluster finding process.

### Distance function

The value of the argument `distance-function` specifies the distance function to be used -- 
close points tend to be placed in the same cluster. 
Here is example comparing the "standard" Geometry distance, `euclidean-distance`, 
with the "directional" distance, `cosine-distance`:

***TBD...***

Instead of distance functions we can use string identifiers of those functions:

```perl6
<Euclidean Cosine>.map({ say find-clusters(@data2D5, 3, distance-function => $_).&text-list-plot(title => 'distance function: ' ~ $_, point-char=><* ® o>), "\n"});
```
```
# distance function: Euclidean                
# +---------------+----------------+----------------+--------+        
# |                                                  ®       |        
# |                                               ® ®®®®®®   |        
# +                                         ® ®®®®®®®®®®®® ® +  100.00
# |                                            ®®®®®®®®®®®®  |        
# |                     * *                       ®® ®   ®®  |        
# |                 *********  *                             |        
# |                ***********                               |        
# +                  ** ******                               +   50.00
# |                 ***       *                              |        
# |              *********  * ****** *                       |        
# |oooooooo       ******  ************                       |        
# + ooooooo o              *********                         +    0.00
# |   o o                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                  distance function: Cosine                  
# +--------------+----------------+----------------+---------+        
# |                                                          |        
# |                                               ®®®®  ®    |        
# |                                          ®®®®®®®®®®®®    |        
# +                                        ® ®®®®®®®®®®®®®®  +  100.00
# |                     ®                      ®®®®®®  ®®    |        
# |                 ®  ®®®®®  ®                              |        
# |                ®®®®®®®®®®®                               |        
# +                 ®®®®®®®®®                                +   50.00
# |                           ®                              |        
# |             ®®®®®®®®®® * ®**** * *                       |        
# |ooooooo       ®®®®®®® ************                        |        
# + ooooooo o             *********                          +    0.00
# |   o o                                                    |        
# +--------------+----------------+----------------+---------+        
#                0.00             50.00            100.00
```

### Learning parameter

At a certain execution step of the algorithm the learning parameter specifies how much the 
current mean points have to be "pulled" in the direction of the estimated new points. 
Smaller values of the named argument `learning-parameter` correspond to more cautious learning:

```perl6
(0.01, 0.1, 0.7).map({ say find-clusters(@data2D5, 2, learning-parameter => $_).&text-list-plot(title => 'learning-parameter:' ~ $_.Str, point-char=><* o>), "\n"});
```
```
# learning-parameter:0.01                   
# +----------------+---------------+----------------+--------+        
# |                                                  o       |        
# |                                               o oooooo   |        
# +                                         o oooooooooooo o +  100.00
# |                                            oooooooooooo  |        
# |                      * **                     oooo   oo  |        
# |                  ***********                             |        
# +                 ***********                              +   50.00
# |                   * ****                                 |        
# |                 **** *     *                             |        
# |              * ********  **********                      |        
# |  *******         **    ***********                       |        
# +   ****** *             *  **** *                         +    0.00
# |    *                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00            
# 
#                    learning-parameter:0.1                   
# +----------------+---------------+----------------+--------+        
# |                                                  o       |        
# |                                               o oooooo   |        
# +                                         o oooooooooooo o +  100.00
# |                                            oooooooooooo  |        
# |                      * **                     oooo   oo  |        
# |                  ***********                             |        
# +                 ***********                              +   50.00
# |                   * ****                                 |        
# |                 **** *     *                             |        
# |              * ********  **********                      |        
# |  *******         **    ***********                       |        
# +   ****** *             *  **** *                         +    0.00
# |    *                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00            
# 
#                    learning-parameter:0.7                   
# +----------------+---------------+----------------+--------+        
# |                                                  o       |        
# |                                               o oooooo   |        
# +                                         o oooooooooooo o +  100.00
# |                                            oooooooooooo  |        
# |                      * **                     oooo   oo  |        
# |                  ***********                             |        
# +                 ***********                              +   50.00
# |                   * ****                                 |        
# |                 **** *     *                             |        
# |              * ********  **********                      |        
# |  *******         **    ***********                       |        
# +   ****** *             *  **** *                         +    0.00
# |    *                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00
```

We see the plots above that with smaller learning parameter better results are obtained. 
But keep in mind that in some situations that small learning parameters can make 
the computations too slow or produce worse clustering results.

### Maximum steps

The value m of the named argument `max-steps` is used in the stopping criteria of the implemented K-means algorithm -- 
if in the number of iterations exceeds m then the algorithms stops. 
Here is example that shows better clustering results is obtained with larger max steps:

```perl6
(1, 4, 100).map({ say find-clusters(@data2D5, 2, max-steps => $_).&text-list-plot(title => 'maximum steps: ' ~ $_.Str, point-char=><* o>), "\n" });
```
```
# maximum steps: 1                      
# +----------------+---------------+----------------+--------+        
# |                                                  o       |        
# |                                               o oooooo   |        
# +                                         o oooooooooooo o +  100.00
# |                                            oooooooooooo  |        
# |                      * **                     oooo   oo  |        
# |                  ***********                             |        
# +                 ***********                              +   50.00
# |                   * ****                                 |        
# |                 **** *     *                             |        
# |              * ********  **********                      |        
# |  *******         **    ***********                       |        
# +   ****** *             *  **** *                         +    0.00
# |    *                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00            
# 
#                       maximum steps: 4                      
# +---------------+----------------+----------------+--------+        
# |                                                  o       |        
# |                                              o oooooo    |        
# +                                        o oooooooooooo o  +  100.00
# |                                           oooooooooooo   |        
# |                     o  oo                     ooo   oo   |        
# |                  ******oo  o                             |        
# +                 *********o                               +   50.00
# |                  ******* *                               |        
# |                 **** *    **                             |        
# |              ********** ******** *                       |        
# |  *******        ** *  ************                       |        
# +   ****** *             * * ** **                         +    0.00
# |    * *                                                   |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      maximum steps: 100                     
# +----------------+---------------+----------------+--------+        
# |                                                  o       |        
# |                                               o oooooo   |        
# +                                         o oooooooooooo o +  100.00
# |                                            oooooooooooo  |        
# |                      * **                     oooo   oo  |        
# |                  ***********                             |        
# +                 ***********                              +   50.00
# |                   * ****                                 |        
# |                 **** *     *                             |        
# |              * ********  **********                      |        
# |  *******         **    ***********                       |        
# +   ****** *             *  **** *                         +    0.00
# |    *                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00
```

### Minimum reassignments fraction

The value `m` of the option "min-reassignments-fraction" is used in the stopping criteria of the implemented K-means algorithm -- 
if in the last iteration step the fraction of the number of points that have changed clusters is less m then the algorithms stops. 
Here is example that shows better clustering results is obtained with a smaller fraction:

```perl6
srand(9);
(0.01, 0.3).map({ say find-clusters(@data2D5, 3, min-reassigments-fraction => $_).&text-list-plot(title => 'min-reassigments-fraction: ' ~ $_.Str, point-char=>Whatever), "\n" });
```
```
# min-reassigments-fraction: 0.01               
# +---------------+----------------+----------------+--------+        
# |                                                  □       |        
# |                                               □ □□□□□□   |        
# +                                         □ □□□□□□□□□□□□ □ +  100.00
# |                                            □□□□□□□□□□□□  |        
# |                     * *                       □□ □   □□  |        
# |                 *********  *                             |        
# |                ***********                               |        
# +                  ** ******                               +   50.00
# |                 ***       *                              |        
# |              *********  * ****** *                       |        
# |▽▽▽▽▽▽▽▽       ******  ************                       |        
# + ▽▽▽▽▽▽▽ ▽              *********                         +    0.00
# |   ▽ ▽                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                min-reassigments-fraction: 0.3               
# +---------------+----------------+----------------+--------+        
# |                                                  *       |        
# |                                               * ******   |        
# +                                         * ************ * +  100.00
# |                                            ************  |        
# |                     □ □                       ** *   **  |        
# |                 □□□□□□□□□  □                             |        
# |                □□□□□□□□□□□                               |        
# +                  □□ □□□□□□                               +   50.00
# |                 □□□       □                              |        
# |              □□□□□□□□□  □ □□□□□□ □                       |        
# |▽▽▽▽▽▽▽▽       □□□□□□  □□□□□□□□□□□□                       |        
# + ▽▽▽▽▽▽▽ ▽              □□□□□□□□□                         +    0.00
# |   ▽ ▽                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

### Precision goal

The value `p` of the named argument `precision-goal` is used specify in stopping criteria that evaluates 
the differences between the "old" and "new" clusters centers -- 
if the maximum of that difference is less than `10 ** (-p)` then the cluster finding iterations stop. 
Here is example that shows using the different precision goals:

```perl6
srand(1921);
(0.2, 5).map({ say find-clusters(@data2D5, 2, precision-goal => $_).&text-list-plot(title => 'precision goal: ' ~ $_.Str, point-char=>Whatever), "\n" });
```
```
# precision goal: 0.2                     
# +----------------+---------------+----------------+--------+        
# |                                                  *       |        
# |                                               * ******   |        
# +                                         * ************ * +  100.00
# |                                            ************  |        
# |                      □ □□                     ****   **  |        
# |                  □□□□□□□□□□□                             |        
# +                 □□□□□□□□□□□                              +   50.00
# |                   □ □□□□                                 |        
# |                 □□□□ □     □                             |        
# |              □ □□□□□□□□  □□□□□□□□□□                      |        
# |  □□□□□□□         □□    □□□□□□□□□□□                       |        
# +   □□□□□□ □             □  □□□□ □                         +    0.00
# |    □                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00            
# 
#                      precision goal: 5                      
# +----------------+---------------+----------------+--------+        
# |                                                  *       |        
# |                                               * ******   |        
# +                                         * ************ * +  100.00
# |                                            ************  |        
# |                      □ □□                     ****   **  |        
# |                  □□□□□□□□□□□                             |        
# +                 □□□□□□□□□□□                              +   50.00
# |                   □ □□□□                                 |        
# |                 □□□□ □     □                             |        
# |              □ □□□□□□□□  □□□□□□□□□□                      |        
# |  □□□□□□□         □□    □□□□□□□□□□□                       |        
# +   □□□□□□ □             □  □□□□ □                         +    0.00
# |    □                                                     |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00
```

-------

## Applications

### Animal weights clustering

Take animal weights `data2D2` (and show `data2D2` dimensions):

```perl6
use Data::ExampleDatasets;
my @data2D2 = |example-dataset('https://raw.githubusercontent.com/antononcube/Raku-ML-Clustering/main/resources/dfAnimalWeights.csv');
say "dimensions: {dimensions(@data2D2)}";
```
```
# dimensions: 28 3
```

Summarize:

```perl6
records-summary(@data2D2)
```
```
# +----------------------+----------------------+----------------------+
# | BrainWeight          | BodyWeight           | Species              |
# +----------------------+----------------------+----------------------+
# | Min    => 0.4        | Min    => 0.023      | Brachiosaurus  => 1  |
# | 1st-Qu => 18.85      | 1st-Qu => 2.9        | Diplodocus     => 1  |
# | Mean   => 574.521429 | Mean   => 4278.43875 | GreyWolf       => 1  |
# | Median => 137        | Median => 53.83      | GuineaPig      => 1  |
# | 3rd-Qu => 421        | 3rd-Qu => 493        | AsianElephant  => 1  |
# | Max    => 5712       | Max    => 87000      | MountainBeaver => 1  |
# |                      |                      | Donkey         => 1  |
# |                      |                      | (Other)        => 21 |
# +----------------------+----------------------+----------------------+
```

Cluster by body weight only:

```perl6
my %awRes1 = find-clusters(@data2D2.map({ [$_<BodyWeight>, ] }), 4, prop=>'All');
.say for %awRes1<IndexClusters>.map({ to-pretty-table(@data2D2[|$_]) });
```
```
# +----------------+-------------+------------+
# |    Species     | BrainWeight | BodyWeight |
# +----------------+-------------+------------+
# | MountainBeaver |   8.100000  |  1.350000  |
# |   GuineaPig    |   5.500000  |  1.040000  |
# |  PotarMonkey   |     115     |     10     |
# |      Cat       |  25.600000  |  3.300000  |
# |  RhesusMonkey  |     179     |  6.800000  |
# | GoldenHamster  |      1      |  0.120000  |
# |     Mouse      |   0.400000  |  0.023000  |
# |     Rabbit     |  12.100000  |  2.500000  |
# |      Rat       |   1.900000  |  0.280000  |
# |      Mole      |      3      |  0.122000  |
# +----------------+-------------+------------+
# +---------+------------+-------------+
# | Species | BodyWeight | BrainWeight |
# +---------+------------+-------------+
# |   Cow   |    465     |     423     |
# |  Horse  |    521     |     655     |
# | Giraffe |    529     |     680     |
# +---------+------------+-------------+
# +------------+------------+-------------+
# | BodyWeight |  Species   | BrainWeight |
# +------------+------------+-------------+
# | 36.330000  |  GreyWolf  |  119.500000 |
# | 27.660000  |    Goat    |     115     |
# | 187.100000 |   Donkey   |     419     |
# |    207     |  Gorilla   |     406     |
# |     62     |   Human    |     1320    |
# |     35     |  Kangaroo  |      56     |
# | 55.500000  |   Sheep    |     175     |
# |    100     |   Jaguar   |     157     |
# | 52.160000  | Chimpanzee |     440     |
# |    192     |    Pig     |     180     |
# +------------+------------+-------------+
# +-----------------+------------+-------------+
# |     Species     | BodyWeight | BrainWeight |
# +-----------------+------------+-------------+
# |    Diplodocus   |   11700    |      50     |
# |  AsianElephant  |    2547    |     4603    |
# | AfricanElephant |    6654    |     5712    |
# |   Triceratops   |    9400    |      70     |
# |  Brachiosaurus  |   87000    |  154.500000 |
# +-----------------+------------+-------------+
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
# |   *                                                      |      
# |                            *                             |      
# +                                            *             +  2.00
# |                                            *             |      
# |                                                      *   |      
# |                                                      *   |      
# +                                                      *   +  0.00
# |                                                      *   |      
# |                                                      *   |      
# +                                                          + -2.00
# +---+-------+--------+-------+--------+--------+-------+---+      
#     0.00    0.10     0.20    0.30     0.40     0.50    0.60
```

Here we cluster using both body weight and brain weight -- 
for that combination of weights it makes sense to cluster with Cosine distance:

```perl6
my %awRes2 = find-clusters(@data2D2.map({ $_<BodyWeight BrainWeight> }), 4, distance-function=>'Cosine', prop=>'All');
.say for %awRes2<IndexClusters>.map({ to-pretty-table(@data2D2[|$_]) });
```
```
# +------------+----------------+-------------+
# | BodyWeight |    Species     | BrainWeight |
# +------------+----------------+-------------+
# |  1.350000  | MountainBeaver |   8.100000  |
# | 36.330000  |    GreyWolf    |  119.500000 |
# | 27.660000  |      Goat      |     115     |
# |  1.040000  |   GuineaPig    |   5.500000  |
# |  3.300000  |      Cat       |  25.600000  |
# |  0.120000  | GoldenHamster  |      1      |
# |  2.500000  |     Rabbit     |  12.100000  |
# | 55.500000  |     Sheep      |     175     |
# | 52.160000  |   Chimpanzee   |     440     |
# |  0.280000  |      Rat       |   1.900000  |
# +------------+----------------+-------------+
# +------------+---------------+-------------+
# | BodyWeight |    Species    | BrainWeight |
# +------------+---------------+-------------+
# |   11700    |   Diplodocus  |      50     |
# |    9400    |  Triceratops  |      70     |
# |   87000    | Brachiosaurus |  154.500000 |
# +------------+---------------+-------------+
# +------------+-------------+--------------+
# | BodyWeight | BrainWeight |   Species    |
# +------------+-------------+--------------+
# |     10     |     115     | PotarMonkey  |
# |     62     |     1320    |    Human     |
# |  6.800000  |     179     | RhesusMonkey |
# |  0.023000  |   0.400000  |    Mouse     |
# |  0.122000  |      3      |     Mole     |
# +------------+-------------+--------------+
# +-----------------+-------------+------------+
# |     Species     | BrainWeight | BodyWeight |
# +-----------------+-------------+------------+
# |       Cow       |     423     |    465     |
# |  AsianElephant  |     4603    |    2547    |
# |      Donkey     |     419     | 187.100000 |
# |      Horse      |     655     |    521     |
# |     Giraffe     |     680     |    529     |
# |     Gorilla     |     406     |    207     |
# | AfricanElephant |     5712    |    6654    |
# |     Kangaroo    |      56     |     35     |
# |      Jaguar     |     157     |    100     |
# |       Pig       |     180     |    192     |
# +-----------------+-------------+------------+
```

Note that obtained clusters seem well separated by body-brain weights directions:

```perl6
text-list-plot(%awRes2<Clusters>>>.log10);
```
```
# +-------+-------+--------+-------+-------+--------+-------++      
# +                                               □          +  4.00
# |                                            □             |      
# +                              ⎔                           +  3.00
# |                              *   □□  □                   |      
# |                      ⎔       *   □                       |      
# +                        ⎔  **   □               ▽        ▽+  2.00
# |                            □                    ▽        |      
# |                    *                                     |      
# +               **  *                                      +  1.00
# |        ⎔                                                 |      
# +       *   *                                              +  0.00
# |                                                          |      
# | ⎔                                                        |      
# +-------+-------+--------+-------+-------+--------+-------++      
#         -1.00   0.00     1.00    2.00    3.00     4.00    5.00
```

------

## Properties and Relations

Often it is good idea to run `k-means` a few times:

```perl6
for 1...3 {
say text-list-plot(k-means(@data2D5, 5), point-char=>(1..5)>>.Str, title=>"run: {$_}"), "\n";
}
```
```
# run: 1                           
# +---------------+----------------+----------------+--------+        
# |                                                  2       |        
# |                                               2 222222   |        
# +                                         2 222222222222 2 +  100.00
# |                                            222222222222  |        
# |                     3 3                       22 2   22  |        
# |                 333333333  3                             |        
# |                33333333333                               |        
# +                  33 333333                               +   50.00
# |                 555       1                              |        
# |              555555555  1 111111 1                       |        
# |44444444       555555  111111111111                       |        
# + 4444444 4              111111111                         +    0.00
# |   4 4                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                            run: 2                           
# +---------------+----------------+----------------+--------+        
# |                                                  3       |        
# |                                               3 333333   |        
# +                                         3 333333333333 3 +  100.00
# |                                            333333333333  |        
# |                     2 2                       33 3   33  |        
# |                 222222222  2                             |        
# |                22222222222                               |        
# +                  22 222222                               +   50.00
# |                 555       4                              |        
# |              555555555  4 444444 4                       |        
# |11111111       555555  444444444444                       |        
# + 1111111 1              444444444                         +    0.00
# |   1 1                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                            run: 3                           
# +---------------+----------------+----------------+--------+        
# |                                                  2       |        
# |                                               2 222222   |        
# +                                         2 222222222222 2 +  100.00
# |                                            222222222222  |        
# |                     5 5                       22 2   22  |        
# |                 555555555 5                              |        
# |                55555555555                               |        
# +                  55 555555                               +   50.00
# |                 5 5       1                              |        
# |             5 55555555  11111111 1                       |        
# |4444444        555555  111111111111                       |        
# + 4444444 3              111111111                         +    0.00
# |   3333                                                   |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

-------

## Possible Issues

The initial mean points of the clusters are chosen at random. 
Hence, to reproduce clustering results `srand` has to be used.

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
text-list-plot(@blackPoints, width=>76, height => 18)
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
    say text-list-plot(k-means(@blackPoints, 7, distance-function=>$_), point-char=>(1..7)>>.Str, title=>$_, width=>76, height => 18), "\n" 
})
```
```
# Euclidean                                  
# ++---------+----------+---------+----------+----------+---------+----------+       
# |                                                                          |       
# +           7                              3                               +  15.00
# |         77777                          33333                             |       
# |            77                             33                             |       
# |           77                             33                       11 11  |       
# +          777                            333                       11 11  +  10.00
# |  77  77 77777                 44    44333333                         11  |       
# |  777777               22       44   44                               11  |       
# |   7777                22       44   44              555555555        66  |       
# |   777               222222     44 4444              55555555         66  |       
# +   7777              222222      4 444               5555 555         66  +   5.00
# |  777777               22        4 444               555555555     66 6666|       
# | 777  77               22          44                              66 6666|       
# |                                   44                                     |       
# |                                44 44                                     |       
# +                               444 4                                      +   0.00
# ++---------+----------+---------+----------+----------+---------+----------+       
#  0.00      10.00      20.00     30.00      40.00      50.00     60.00              
# 
#                                    Cosine                                   
# ++-------------------+--------------------+--------------------+-----------+       
# |                                                                          |       
# +           1                             5                                +  15.00
# |         11111                         55555                              |       
# |         11 11                         55 66                              |       
# |           11                            66                       3333    |       
# +          111                           777                       3333    +  10.00
# |  11  11 11111                 66   77777777                        33    |       
# |  111111              55        77  77                              33    |       
# |   1111               66        77  77             3333 33333       33    |       
# |   111              666777      777333             3333 3333        44    |       
# +   1111             777777       3333              4444  444        44    +   5.00
# |  111155              73         3333              4444 44444     444444  |       
# | 111  55              33          44                              444444  |       
# |                                  44                                      |       
# |                                2222                                      |       
# +                               2222                                       +   0.00
# ++-------------------+--------------------+--------------------+-----------+       
#  0.00                20.00                40.00                60.00               
# 
#                                  Chessboard                                 
# ++---------+----------+---------+----------+---------+----------+---------++       
# |                                                                          |       
# +           3                              7                               +  15.00
# |         33333                         7 7777                             |       
# |            33                             77                             |       
# |           33                             66                       2222   |       
# +          333                            666                       2222   +  10.00
# |  33  33 33333                 44   4446 6666                        22   |       
# |  333333               11       44  44                               22   |       
# |   3333                11       44  44              66222222 2       22   |       
# |   333               111111     444444              66222222         22   |       
# +   3333              111111      4444               6622 222         22   +   5.00
# |  333333               11        5555               66222222 2     222222 |       
# | 333  33               11         55                               222222 |       
# |                                  55                                      |       
# |                                5555                                      |       
# +                               5555                                       +   0.00
# ++---------+----------+---------+----------+---------+----------+---------++       
#  0.00      10.00      20.00     30.00      40.00     50.00      60.00     70.00    
# 
#                                  Manhattan                                  
# ++---------+----------+---------+----------+----------+---------+----------+       
# |                                                                          |       
# +           1                              2                               +  15.00
# |         11111                          22222                             |       
# |            11                             22                             |       
# |           11                             22                       33 33  |       
# +          111                            222                       33 33  +  10.00
# |  11  11 11111                 22    22222222                         33  |       
# |  111111               22       22   22                               33  |       
# |   1111                22       22   22              555557777        34  |       
# |   111               222222     22 2222              55555666         44  |       
# +   1111              222222      2 222               5555 566         44  +   5.00
# | 1111111               22        2 222               555555666     44 4444|       
# |                                   22                                     |       
# |                                22 22                                     |       
# +                               222 2                                      +   0.00
# |                                                                          |       
# ++---------+----------+---------+----------+----------+---------+----------+       
#  0.00      10.00      20.00     30.00      40.00      50.00     60.00              
# 
#                                  BrayCurtis                                 
# +----------+----------+---------+----------+---------+----------+----------+       
# +           7                              5                               +  15.00
# |         77777                          55555                             |       
# |         77 77                          55 55                             |       
# |            77                             55                             |       
# |           77                             55                       33 33  |       
# +          777                            555                       33 33  +  10.00
# | 22   27 77777                 11    15555555                         33  |       
# | 22 2222               66       11   11                               33  |       
# |  2 222                66       11   11             4 44444444        33  |       
# |  2 22               666666     1111 11             4 4444444         33  |       
# +  2 222              666666      111 1              4 444 444         33  +   5.00
# | 22 2222               66        111 1              4 44444444     33 3333|       
# |222   22               66         11                               33 3333|       
# |                                  11                                      |       
# |                                1111                                      |       
# +                               1111                                       +   0.00
# +----------+----------+---------+----------+---------+----------+----------+       
#            10.00      20.00     30.00      40.00     50.00      60.00              
# 
#                                   Canberra                                  
# +-+--------------------+-------------------+-------------------+-----------+       
# +            3                             3                               +  15.00
# |          33333                         33333                             |       
# |          33 33                         33 33                             |       
# |             33                            33                             |       
# |            33                            33                      3333    |       
# +           111                           111                      1111    +  10.00
# |   11  11 11111                 11   11111111                       11    |       
# |   111116               66       66  66                             11    |       
# |    6666                66       66  66             666666666       66    |       
# +    6662              666666     666666             66666666        66    +   5.00
# |   555555               55        5444              444444444     444444  |       
# |  555  55               55         44                             444444  |       
# |                                   44                                     |       
# |                                 5544                                     |       
# +                                5554                                      +   0.00
# |                                                                          |       
# +-+--------------------+-------------------+-------------------+-----------+       
#   0.00                 20.00               40.00               60.00
```

-------

## References

### Articles, books

[Wk1] Wikipedia entry, ["K-means clustering"](https://en.wikipedia.org/wiki/K-means_clustering).

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

[AN1] Amiya Nayak and Ivan Stojmenovic,
"Handbook of Applied Algorithms: Solving Scientific, Engineering, and Practical Problems", 
Wiley, 2008. ISBN: 0470044926, 9780470044926.

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
