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

## In brief

The function `k-means` finds clusters using the K-means algorithm. Here are the arguments:

- `@points` -- data points.
- `$k` -- number of clusters.
- `:$distance-function` -- points distance function.
- `:$learning-parameter` -- re-assignment learning parameter.
- `:$max-steps` -- maximum number of steps.
- `:$min-reassignment-fraction` -- minimum re-assignments required to continue the iterations.
- `:$precision-goal` -- precision goal.
- `:$prop` -- property to give as a result, one of 'MeanPoints', 'Clusters', 'ClusterLabels', 'IndexClusters', 'Properties', 'All'.

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
# | Min    => 2.290205825854349  | Min    => 2.317487685805899  |
# | 1st-Qu => 4.495363992252855  | 1st-Qu => 5.56095907314802   |
# | Mean   => 7.8818644048713535 | Mean   => 8.289683300170049  |
# | Median => 9.06759573999021   | Median => 9.41356364820627   |
# | 3rd-Qu => 10.1953221841508   | 3rd-Qu => 10.410205797110908 |
# | Max    => 12.215396508760179 | Max    => 11.990847715969457 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +-+----------+---------+----------+----------+---------+---+       
# |                                                          |       
# +                                     *  **   **    *      +  12.00
# |                                    *   *   ***  *  * *   |       
# +                              *        *** *** ** *  **   +  10.00
# |                                        * **  * * *       |       
# +    *                           *      **    ***          +   8.00
# |                                                          |       
# +   *                                                      +   6.00
# |             *  ***                        *              |       
# |      *  * *   ** *     *  *                              |       
# +      *      *    * *  * * *                              +   4.00
# |           *        *                      *              |       
# +                                                          +   2.00
# +-+----------+---------+----------+----------+---------+---+       
#   2.00       4.00      6.00       8.00       10.00     12.00
```

Here is how we use the function `k-means` to find clusters:

```perl6
use ML::Clustering;
my @cls = |k-means(@data2D2, 2);
@cls>>.elems
```
```
# (50 30)
```

**Remark:** The first argument is data points that is a list-of-numeric-lists. 
The second argument is a number of clusters to be found. 

**Remark:** 
Here are sample points from each found cluster:

```perl6
.say for @cls>>.pick(3);
```
```
# ((10.776287156615568 9.302970225317107) (11.542285598453944 10.810786134195094) (10.719163085086564 10.099796539272521))
# ((2.888037251505501 3.67308533397254) (9.938423208683538 3.0360923587431277) (5.2760421052593145 4.127051224071752))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# ++----------+-----------+----------+----------+----------+-+       
# |                                               ▽          |       
# +                                      ▽ ▽▽▽   ▽     ▽     +  12.00
# |                                     ▽   ▽   ▽▽▽  ▽  ▽  ▽ |       
# +                               ▽        ▽▽▽ ▽▽▽▽ ▽ ▽▽ ▽ ▽ +  10.00
# |                                           ▽▽  ▽ ▽ ▽      |       
# +   ☐                             ▽      ▽     ▽▽▽▽        +   8.00
# |                                                          |       
# +  ☐                                                       +   6.00
# |             ☐  ☐☐☐                         ☐             |       
# |      ☐ ☐  ☐   ☐☐       ☐  ☐                              |       
# +     ☐       ☐    ☐☐☐  ☐ ☐ ☐                              +   4.00
# |                           ☐                ☐             |       
# +           ☐        ☐                                     +   2.00
# ++----------+-----------+----------+----------+----------+-+       
#  2.00       4.00        6.00       8.00       10.00      12.00
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
# +---------------+----------------+---------------+---------+        
# |                                                          |        
# |                                             **   *       |        
# |                                         * ***********    |        
# +                                         **************   +  100.00
# |                    *                    * ******** **    |        
# |                   ******                                 |        
# |                 ********** *                             |        
# +                   *********                              +   50.00
# |                  *****                                   |        
# |                ****** *   **** *                         |        
# |   *******      ******* ********* *                       |        
# +   *******               *******                          +    0.00
# |                                                          |        
# +---------------+----------------+---------------+---------+        
#                 0.00             50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(32);
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +--------------+-----------------+----------------+--------+        
# |                                                    4     |        
# |                                            44444444   4  |        
# |                                          4  44444444444  |        
# +                                          4444444●4444444 +  100.00
# |                    2                     4 4  4444444 4  |        
# |                  2222222                                 |        
# |                22222222222 2                             |        
# +                22222222222                               +   50.00
# |                    ●                                     |        
# |               2222222 3  3 3 3 3                         |        
# |  1 111        2223333 33333●3333                         |        
# +555●●51 1             33333333333 3                       +    0.00
# | 5555555                 3   3                            |        
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
# [(15.258910202688437 39.2255668174249) (100.24499958706294 99.65769461573379) (-31.79637473419085 -2.1539860130629314) (-28.197932228217603 2.234311793139595) (38.94839670993014 10.542472077984751)]
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
# +--------------+-----------------+----------------+--------+        
# |                                                    o     |        
# |                                            o oooooo   o  |        
# |                                          o  ooooooooooo  |        
# +                                          ooooooooooooooo +  100.00
# |                    ®                     o o  ooooooo o  |        
# |                  ®®®®®®®                                 |        
# |                ®®®®®®®®®®® ®                             |        
# +                  ®®®®®®®®®                               +   50.00
# |                  ® ®                                     |        
# |               ®®®®®®® ®  ®®®®® ®                         |        
# | ******        ®®®®®®®®®®®®®®®®®® ®                       |        
# +*********              ®®®®®®®®®®                         +    0.00
# |  ******                     ®                            |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                  distance function: Cosine                  
# +--------------+----------------+----------------+---------+        
# |                                                          |        
# |                                             **   *       |        
# |                                         *  ******** **   |        
# +                                         ***************  +  100.00
# |                                         * ********** *   |        
# |                 ®®®®®®®                                  |        
# |                ®®®®®®®®®®® ®                             |        
# +                ®®®®®®®®®®®                               +   50.00
# |                 ®  ®                                     |        
# |               ®®®®®®®*   ******                          |        
# | ooooooo      ®®®®®*** ***********                        |        
# +ooooooo                 ********                          +    0.00
# |  o  o o                                                  |        
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
# +---------------+----------------+----------------+--------+        
# |                                                    *     |        
# |                                             ********  *  |        
# |                                          ** ***********  |        
# +                                           ************** +  100.00
# |                    o                     * ** ** * *  *  |        
# |                   oooooooo                               |        
# |                 ooooooooooo o                            |        
# +                   ooooooooo                              +   50.00
# |                  o  oo                                   |        
# |                ooooooo o  oooooo                         |        
# |   ooooooo      oooooo oooooooooooo                       |        
# +  ooooooo                ooooooooo                        +    0.00
# |   o oooo                    o                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.1                   
# +---------------+----------------+----------------+--------+        
# |                                                    *     |        
# |                                             ********  *  |        
# |                                          ** ***********  |        
# +                                           ************** +  100.00
# |                    o                     * ** ** * *  *  |        
# |                   oooooooo                               |        
# |                 ooooooooooo o                            |        
# +                   ooooooooo                              +   50.00
# |                  o  oo                                   |        
# |                ooooooo o  oooooo                         |        
# |   ooooooo      oooooo oooooooooooo                       |        
# +  ooooooo                ooooooooo                        +    0.00
# |   o oooo                    o                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.7                   
# +---------------+----------------+----------------+--------+        
# |                                                    o     |        
# |                                             oooooooo  o  |        
# |                                          oo ooooooooooo  |        
# +                                           oooooooooooooo +  100.00
# |                    *                     o oo oo o o  o  |        
# |                   ********                               |        
# |                 *********** *                            |        
# +                   *********                              +   50.00
# |                  *  **                                   |        
# |                ******* *  ******                         |        
# |   *******      ****** ************                       |        
# +  *******                *********                        +    0.00
# |   * ****                    *                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
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
# +---------------+----------------+----------------+--------+        
# |                                                    o     |        
# |                                             oooooooo  o  |        
# |                                          oo ooooooooooo  |        
# +                                           oooooooooooooo +  100.00
# |                    *                     o oo oo o o  o  |        
# |                   ********                               |        
# |                 *********** *                            |        
# +                   *********                              +   50.00
# |                  *  **                                   |        
# |                ******* *  ******                         |        
# |   *******      ****** ************                       |        
# +  *******                *********                        +    0.00
# |   * ****                    *                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                       maximum steps: 4                      
# +---------------+---------------+----------------+---------+        
# |                                                          |        
# |                                             oo   o       |        
# |                                          o oooooooo oo   |        
# +                                         ooooooooooooooo  +  100.00
# |                                         o oooooooooooo   |        
# |                  ooooooo                     o           |        
# |                 oooooooooo o                             |        
# +                *oooooooooo                               +   50.00
# |                  * o                                     |        
# |               ******* *  ooooo o                         |        
# |  ******       ***********ooooooo                         |        
# + ********               ****ooooo o                       +    0.00
# |  ***** *                   *                             |        
# +---------------+---------------+----------------+---------+        
#                 0.00            50.00            100.00             
# 
#                      maximum steps: 100                     
# +---------------+----------------+----------------+--------+        
# |                                                    *     |        
# |                                             ********  *  |        
# |                                          ** ***********  |        
# +                                           ************** +  100.00
# |                    o                     * ** ** * *  *  |        
# |                   oooooooo                               |        
# |                 ooooooooooo o                            |        
# +                   ooooooooo                              +   50.00
# |                  o  oo                                   |        
# |                ooooooo o  oooooo                         |        
# |   ooooooo      oooooo oooooooooooo                       |        
# +  ooooooo                ooooooooo                        +    0.00
# |   o oooo                    o                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
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
# |                                                    □     |        
# |                                             □□□□□□□□  □  |        
# |                                          □  □□□□□□□□□□□  |        
# +                                          □□□□□□□□□□□□□□□ +  100.00
# |                    *                     □ □  □□□□ □  □  |        
# |                  ******* *                               |        
# |                 *********** ▽                            |        
# +                   ********▽                              +   50.00
# |                 **  **                                   |        
# |                ****** ▽   ▽▽▽▽▽▽                         |        
# |  *******      ******▽▽ ▽▽▽▽▽▽▽▽▽▽▽                       |        
# + *******                 ▽▽▽▽▽▽▽▽▽                        +    0.00
# |   * ** *                    ▽                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                min-reassigments-fraction: 0.3               
# +---------------+----------------+----------------+--------+        
# |                                                    ▽     |        
# |                                             ▽▽▽▽▽▽▽   ▽  |        
# |                                           ▽ ▽▽▽▽▽▽▽▽▽▽▽  |        
# +                                          ▽▽▽▽▽▽▽▽▽▽▽▽▽▽▽ +  100.00
# |                    □                     ▽ ▽▽ ▽▽ ▽▽▽▽▽▽  |        
# |                   □□□□□□                                 |        
# |                 □□□□□□□□□□□ □                            |        
# +                 □□□□□□□□□□□                              +   50.00
# |                  *  □                                    |        
# |                ******* *  ******                         |        
# |   ******       ****** ***********                        |        
# +  ********              ***********                       +    0.00
# |   ******                 *  *                            |        
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
# +---------------+----------------+----------------+--------+        
# |                                                    □     |        
# |                                             □□□□□□□□  □  |        
# |                                          □□ □□□□□□□□□□□  |        
# +                                           □□□□□□□□□□□□□□ +  100.00
# |                    *                     □ □□ □□ □ □  □  |        
# |                   ********                               |        
# |                 *********** *                            |        
# +                   *********                              +   50.00
# |                  *  **                                   |        
# |                ******* *  ******                         |        
# |   *******      ****** ************                       |        
# +  *******                *********                        +    0.00
# |   * ****                    *                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      precision goal: 5                      
# +---------------+----------------+----------------+--------+        
# |                                                    *     |        
# |                                             ********  *  |        
# |                                          ** ***********  |        
# +                                           ************** +  100.00
# |                    □                     * ** ** * *  *  |        
# |                   □□□□□□□□                               |        
# |                 □□□□□□□□□□□ □                            |        
# +                   □□□□□□□□□                              +   50.00
# |                  □  □□                                   |        
# |                □□□□□□□ □  □□□□□□                         |        
# |   □□□□□□□      □□□□□□ □□□□□□□□□□□□                       |        
# +  □□□□□□□                □□□□□□□□□                        +    0.00
# |   □ □□□□                    □                            |        
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
# +----------------------+----------------------+---------------------+
# | BodyWeight           | BrainWeight          | Species             |
# +----------------------+----------------------+---------------------+
# | Min    => 0.023      | Min    => 0.4        | Sheep         => 1  |
# | 1st-Qu => 2.9        | 1st-Qu => 18.85      | Rat           => 1  |
# | Mean   => 4278.43875 | Mean   => 574.521429 | GuineaPig     => 1  |
# | Median => 53.83      | Median => 137        | Gorilla       => 1  |
# | 3rd-Qu => 493        | 3rd-Qu => 421        | Brachiosaurus => 1  |
# | Max    => 87000      | Max    => 5712       | Kangaroo      => 1  |
# |                      |                      | Giraffe       => 1  |
# |                      |                      | (Other)       => 21 |
# +----------------------+----------------------+---------------------+
```

Cluster by body weight only:

```perl6
my %awRes1 = find-clusters(@data2D2.map({ [$_<BodyWeight>, ] }), 4, prop=>'All');
.say for %awRes1<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>, align => {:Species<l>}) });
```
```
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | Brachiosaurus |   87000    |   87000    |
# +---------------+------------+------------+
# +-----------------+------------+------------+
# | Species         | BodyWeight | BodyWeight |
# +-----------------+------------+------------+
# | Diplodocus      |   11700    |   11700    |
# | AfricanElephant |    6654    |    6654    |
# | Triceratops     |    9400    |    9400    |
# +-----------------+------------+------------+
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | Cow           |    465     |    465     |
# | AsianElephant |    2547    |    2547    |
# | Donkey        | 187.100000 | 187.100000 |
# | Horse         |    521     |    521     |
# | Giraffe       |    529     |    529     |
# | Gorilla       |    207     |    207     |
# | Jaguar        |    100     |    100     |
# | Pig           |    192     |    192     |
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
# | Chimpanzee     | 52.160000  | 52.160000  |
# | Rat            |  0.280000  |  0.280000  |
# | Mole           |  0.122000  |  0.122000  |
# +----------------+------------+------------+
```

Note that obtained clusters seem well separated by weight:

```perl6
text-list-plot(((%awRes1<ClusterLabels>.Array >>+>> 1) Z @data2D2.map({ $_<BodyWeight> }))>>.log10.List)
```
```
# +---+-------+--------+-------+--------+--------+-------+---+      
# |                                                          |      
# |                            *                             |      
# +                                            *             +  4.00
# |   *                                                      |      
# |   *                                                      |      
# +   *                                                      +  2.00
# |                                                      *   |      
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
.say for %awRes2<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>, align => {:Species<l>}) });
```
```
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | Diplodocus    |   11700    |   11700    |
# | Triceratops   |    9400    |    9400    |
# | Brachiosaurus |   87000    |   87000    |
# +---------------+------------+------------+
# +-----------------+------------+------------+
# | Species         | BodyWeight | BodyWeight |
# +-----------------+------------+------------+
# | Cow             |    465     |    465     |
# | AsianElephant   |    2547    |    2547    |
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
# | PotarMonkey    |     10     |     10     |
# | Cat            |  3.300000  |  3.300000  |
# | Human          |     62     |     62     |
# | RhesusMonkey   |  6.800000  |  6.800000  |
# | GoldenHamster  |  0.120000  |  0.120000  |
# | Mouse          |  0.023000  |  0.023000  |
# | Chimpanzee     | 52.160000  | 52.160000  |
# | Rat            |  0.280000  |  0.280000  |
# | Mole           |  0.122000  |  0.122000  |
# +----------------+------------+------------+
# +-----------+------------+------------+
# | Species   | BodyWeight | BodyWeight |
# +-----------+------------+------------+
# | GreyWolf  | 36.330000  | 36.330000  |
# | Goat      | 27.660000  | 27.660000  |
# | GuineaPig |  1.040000  |  1.040000  |
# | Donkey    | 187.100000 | 187.100000 |
# | Rabbit    |  2.500000  |  2.500000  |
# | Sheep     | 55.500000  | 55.500000  |
# +-----------+------------+------------+
```

Note that obtained clusters seem well separated by body-brain weights directions:

```perl6
text-list-plot(%awRes2<Clusters>>>.log10);
```
```
# +-------+-------+--------+-------+-------+--------+-------++      
# +                                               *          +  4.00
# |                                            *             |      
# +                              ▽                           +  3.00
# |                              ▽   □*  *                   |      
# |                      ▽       □   *                       |      
# +                        ▽  □□   *               ❍        ❍+  2.00
# |                            *                    ❍        |      
# |                    ▽                                     |      
# +               □▽  □                                      +  1.00
# |        ▽                                                 |      
# +       ▽   ▽                                              +  0.00
# |                                                          |      
# | ▽                                                        |      
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
# +--------------+-----------------+----------------+--------+        
# |                                                    5     |        
# |                                            5 555555   5  |        
# |                                          5  55555555555  |        
# +                                          555555555555555 +  100.00
# |                    4                     5 5  5555555 5  |        
# |                  4444444                                 |        
# |                44444444444 4                             |        
# +                44444444444                               +   50.00
# |                  3 4                                     |        
# |               3333333 3  2 2 2 2                         |        
# |  1 111        333333332222222222                         |        
# +1111111 1              2222222222 2                       +    0.00
# |  111111                 2   2                            |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                            run: 2                           
# +--------------+-----------------+----------------+--------+        
# |                                                    3     |        
# |                                            3 333333   3  |        
# |                                          3  33333333333  |        
# +                                          333333333333333 +  100.00
# |                    5                     3 3  3333333 3  |        
# |                  5555555                                 |        
# |                55555555444 4                             |        
# +                55555444444                               +   50.00
# |                  1 4                                     |        
# |               1111111 1  1 1 1 1                         |        
# |  2 222        111111111111111111                         |        
# +2222222 2              1111111111 1                       +    0.00
# |  222222                 1   1                            |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00            
# 
#                            run: 3                           
# +--------------+-----------------+----------------+--------+        
# |                                                    4     |        
# |                                            4 444444   4  |        
# |                                          4  44444444444  |        
# +                                          444444444444444 +  100.00
# |                    3                     4 4  4444444 4  |        
# |                  3333333                                 |        
# |                33333333333 3                             |        
# +                33333333333                               +   50.00
# |                  2 3                                     |        
# |               2222222 2  5 5 5 5                         |        
# |  1 111        222222225555555555                         |        
# +1111111 1              5555555555 5                       +    0.00
# |  111111                 5   5                            |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00
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
# +----------+---------+----------+---------+----------+---------+----------++       
# +           7                             4                                +  15.00
# |         77777                         44444                              |       
# |         77 77                         44 44                              |       
# |            77                            44                              |       
# |           77                            44                        5555   |       
# +          777                           444                        5555   +  10.00
# | 11  17  77777                 22   44444444                         55   |       
# | 111133               22        22  44                               55   |       
# |  1133                22        22  44              555555555        55   |       
# |  633               222222      222224              55555555         55   |       
# +  6633              222222       2222               5555 555         55   +   5.00
# | 666333               22         2222               555555555      555555 |       
# |666  33               22          22                               555555 |       
# |                                  22                                      |       
# |                                2222                                      |       
# +                               2222                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                    Cosine                                   
# ++-------------------+--------------------+--------------------+-----------+       
# |                                                                          |       
# +           4                             1                                +  15.00
# |         44444                         11111                              |       
# |            44                            11                              |       
# |           44                            11                       2222    |       
# +          444                           111                       2222    +  10.00
# |  44  44 44444                 11   11112222                        66    |       
# |  444444              11        11  22                              66    |       
# |   4444               11        22  22             6666666 66       66    |       
# |   444              111111      222222             6666666 6        33    |       
# +   4444             112222       2266              6333 33 3        33    +   5.00
# |  444441              22         6666              3333333 33     555555  |       
# | 444  11              66          33                              555555  |       
# |                                  55                                      |       
# |                                5555                                      |       
# +                               7777                                       +   0.00
# ++-------------------+--------------------+--------------------+-----------+       
#  0.00                20.00                40.00                60.00               
# 
#                                  Chessboard                                 
# +----------+----------+---------+----------+---------+----------+----------+       
# +           4                              6                               +  15.00
# |         44444                          66666                             |       
# |         44 44                          66 66                             |       
# |            44                             66                             |       
# |           44                             66                       77 77  |       
# +          444                            666                       77 77  +  10.00
# | 22   24 44444                 55    66666666                         77  |       
# | 22 2222               11       55   66                               77  |       
# |  2 222                11       55   55             3 33333333        77  |       
# |  2 22               111111     5555 55             3 3333333         77  |       
# +  2 222              111111      555 5              3 333 333         77  +   5.00
# | 22 2222               11        555 5              3 33333333     77 7777|       
# |222   22               11         55                               77 7777|       
# |                                  55                                      |       
# |                                5555                                      |       
# +                               5555                                       +   0.00
# +----------+----------+---------+----------+---------+----------+----------+       
#            10.00      20.00     30.00      40.00     50.00      60.00              
# 
#                                  Manhattan                                  
# +----------+---------+----------+---------+----------+---------+----------++       
# +           3                             2                                +  15.00
# |         33336                         2222 2                             |       
# |         33 36                         22 2 2                             |       
# |            36                            2 2                             |       
# |           33                            22                        1111   |       
# +          336                           222                        1111   +  10.00
# | 55   55 33366                 77   7722222 2                        11   |       
# | 555 555              44        77  77                               11   |       
# |  55 55               44        77  77              111111111        11   |       
# |  55 5              4444 44     777777              11111111         11   |       
# +  55 55             4444 44      7777               1111 111         11   +   5.00
# | 555 555              44         7777               111111111      111111 |       
# |555   55              44          77                               111111 |       
# |                                  77                                      |       
# |                                7777                                      |       
# +                               7777                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                  BrayCurtis                                 
# +----------+----------+---------+----------+---------+----------+----------+       
# +           7                              6                               +  15.00
# |         77777                          66666                             |       
# |         77 77                          66 66                             |       
# |            77                             66                             |       
# |           77                             66                       33 33  |       
# +          777                            666                       33 33  +  10.00
# | 44   44 77777                 55    66666666                         33  |       
# | 44 4444               55       55   66                               33  |       
# |  4 444                55       55   66             1 11111111        33  |       
# |  4 44               555555     5555 56             1 1111111         33  |       
# +  4 444              555555      555 5              2 221 111         33  +   5.00
# | 44 4444               55        555 5              2 22222222     33 3333|       
# |444   44               55         55                               33 3333|       
# |                                  55                                      |       
# |                                5555                                      |       
# +                               5555                                       +   0.00
# +----------+----------+---------+----------+---------+----------+----------+       
#            10.00      20.00     30.00      40.00     50.00      60.00              
# 
#                                   Canberra                                  
# +--------------------+-------------------+--------------------+------------+       
# +           4                            2                                 +  15.00
# |         44477                        222 22                              |       
# |         44 77                        22  22                              |       
# |            77                            22                              |       
# |           66                           2 2                      2222     |       
# +          666                          22 2                      2222     +  10.00
# | 11  66  66666                22   222222 22                       22     |       
# | 111166               22       22  22                              22     |       
# |  1111                22       22  22              222222222       22     |       
# |  111               222222     222222              33333333        33     |       
# +  1111              333333      3333               3333 333        33     +   5.00
# | 111111               33        3333               333333333     333333   |       
# |111  11               33         33                              333333   |       
# |                                 55                                       |       
# |                               5555                                       |       
# +                              5555                                        +   0.00
# +--------------------+-------------------+--------------------+------------+       
#                      20.00               40.00                60.00
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
