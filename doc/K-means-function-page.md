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
# +------------------------------+------------------------------+
# | 0                            | 1                            |
# +------------------------------+------------------------------+
# | Min    => 1.9950702758041263 | Min    => 3.1062666066129676 |
# | 1st-Qu => 5.947405223607554  | 1st-Qu => 5.690815628112096  |
# | Mean   => 8.201136867257393  | Mean   => 8.177837902105656  |
# | Median => 9.127738386542324  | Median => 9.336753907200542  |
# | 3rd-Qu => 10.524620088938292 | 3rd-Qu => 10.264952240830207 |
# | Max    => 12.421580989389529 | Max    => 11.680216535793534 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +---+---------+--------+---------+---------+---------+-----+       
# +                                                          +  12.00
# |                                 *      **  ** *          |       
# |                                  *     ** * * ** *   *   |       
# +                                  * **  ** * **           +  10.00
# |                               *  * *  **   * **  *       |       
# +                                    *      *  *           +   8.00
# |                                                          |       
# |                         *                                |       
# +       **   ** * * *     *                                +   6.00
# |   *           ** ***    *                                |       
# +       *      *        * **                               +   4.00
# |               *     ***     *                            |       
# |                                                          |       
# +---+---------+--------+---------+---------+---------+-----+       
#     2.00      4.00     6.00      8.00      10.00     12.00
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
# ((4.639563954865547 4.7988321615683995) (1.9950702758041263 4.770276816354197) (5.602228381435534 4.667094447930123))
# ((8.193522648687345 11.287893394214535) (8.43054928626646 9.850051815019835) (10.726630730371417 9.384934214952791))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# +-+----------+---------+----------+---------+----------+---+       
# +                                          ☐     ☐         +  12.00
# |                                  ☐      ☐☐ ☐☐☐ ☐   ☐     |       
# |                                   ☐     ☐☐ ☐☐☐ ☐ ☐     ☐ |       
# +                               ☐   ☐☐☐☐ ☐☐☐ ☐ ☐☐☐   ☐     +  10.00
# |                                    ☐       ☐☐ ☐☐         |       
# +                                               ☐          +   8.00
# |                                                          |       
# |                        ▽▽                                |       
# +      ▽▽   ▽   ▽ ▽ ▽     ▽                                +   6.00
# |             ▽▽▽ ▽ ▽     ▽                                |       
# | ▽            ▽     ▽     ▽                               |       
# +      ▽        ▽      ▽▽▽    ▽                            +   4.00
# |                     ▽                                    |       
# +-+----------+---------+----------+---------+----------+---+       
#   2.00       4.00      6.00       8.00      10.00      12.00
```

------

## Scope

Here is more interesting looking two-dimensional data, `data2D2`:

```perl6
use Data::Reshapers;
my $pointsPerCluster = 200;
my @data2D5 = [[10, 20, 4], [20, 60, 6], [40, 10, 6], [-30, 0, 4], [100, 100, 8]].map({
    random-variate(NormalDistribution.new($_[0], $_[2]), $pointsPerCluster) Z random-variate(NormalDistribution.new($_[1], $_[2]), $pointsPerCluster)
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
# ++---------------+---------------+----------------+--------+        
# |                                                          |        
# |                                           **  **** *     |        
# +                                          * ***********   +  100.00
# |                                         *  ***********   |        
# |                     ** **                      *         |        
# |                    *******                               |        
# +                * **********                              +   50.00
# |                   ***** * *                              |        
# |                * ****       *                            |        
# |                ******** *********                        |        
# |   ********      * **   ********** **                     |        
# +   ********                ******                         +    0.00
# |                                                          |        
# ++---------------+---------------+----------------+--------+        
#  -50.00          0.00            50.00            100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(923);
my %clRes = find-clusters(@data2D5, 5, prop => 'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char => <1 2 3 4 5 ●>)
```
```
# +---------------+-----------------+----------------+-------+        
# +                                                 44       +  120.00
# |                                           4444444444444  |        
# +                                             44444●444444 +  100.00
# |                                          4  44444444 444 |        
# +                    5551 11                      4        +   80.00
# |                   55555111                               |        
# +               5 5555●51●111                              +   60.00
# +                  5555111 11                              +   40.00
# |                 5222                                     |        
# +               22222222   22222222                        +   20.00
# |   33333        22222 2 ●2222222222 2                     |        
# +33333●333               2 2222222  2                      +    0.00
# |  333333                     2                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00
```

**Remark:** The function `k-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are the centers of the clusters (the mean points):

```perl6
%clRes<MeanPoints>
```
```
# [(24.613214013051977 59.23826263706249) (24.375480640176775 14.347728089827852) (15.432281599141911 59.84562840172872) (99.63001685432694 100.07281544979541) (-30.04856015337075 0.15785764759286647)]
```

-------

## Control parameters (named arguments)

In this section we describe the named arguments of `find-clusters` that can be used to control the cluster finding
process.

### Distance function

The value of the argument `distance-function` specifies the distance function to be used -- close points tend to be
placed in the same cluster. Here is example comparing the "standard" Geometry distance, `euclidean-distance`, with the 
"directional" distance, `cosine-distance`:

```perl6
use ML::Clustering::DistanceFunctions;
('custom Euclidean' => -> @v1, @v2 { sqrt([+] (@v1 Z @v2).map({ ($_[0] - $_[1]) ** 2 })) },
 'built-in Cosine' => { ML::Clustering::DistanceFunctions.cosine-distance($^a, $^b) })
        .map({ say find-clusters(@data2D5, 3, distance-function => $_.value).&text-list-plot(
        title => 'distance function: ' ~ $_.key, point-char => <* ® o>), "\n" });
```
```
# distance function: custom Euclidean             
# +---------------+-----------------+----------------+-------+        
# +                                                 ®®       +  120.00
# |                                           ®®®®®®®®®®®®®  |        
# +                                             ®®®®®®®®®®®® +  100.00
# |                                          ®  ®®®®®®®® ®®® |        
# +                    **** **                      ®        +   80.00
# |                   ********                               |        
# +               * ***********                              +   60.00
# +                  ******* **                              +   40.00
# |                 ****                                     |        
# +               ********   ********                        +   20.00
# |   ooooo        ***** * *********** *                     |        
# +ooooooooo               * *******  *                      +    0.00
# |  oooooo                     *                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00           
# 
#              distance function: built-in Cosine             
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# +                                           **  *******    +  120.00
# +                                          * ************  +  100.00
# |                                         *  ***********   |        
# +                      *                         * *       +   80.00
# |                   *******                                |        
# +                ***********                               +   60.00
# |               *  *********                               |        
# +                 *                                        +   40.00
# +              *********  ®®®®®®®®                         +   20.00
# |   ooooo       *******  ®®®®®®®®®® ®                      |        
# +ooooooooo              ®®®®®®®®®®  ®                      +    0.00
# | o ooooo                     ®                            |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

Instead of distance functions (subs) we can use string identifiers of "known functions":

```perl6
<Euclidean Cosine>.map({ say find-clusters(@data2D5, 3, distance-function => $_).&text-list-plot(
        title => 'distance function: ' ~ $_, point-char => <* ® o>), "\n" });
```
```
# distance function: Euclidean                
# +---------------+-----------------+----------------+-------+        
# +                                                 ®®       +  120.00
# |                                           ®®®®®®®®®®®®®  |        
# +                                             ®®®®®®®®®®®® +  100.00
# |                                          ®  ®®®®®®®® ®®® |        
# +                    **** **                      ®        +   80.00
# |                   ********                               |        
# +               * ***********                              +   60.00
# +                  ******* **                              +   40.00
# |                 ****                                     |        
# +               ********   ********                        +   20.00
# |   ooooo        ***** * *********** *                     |        
# +ooooooooo               * *******  *                      +    0.00
# |  oooooo                     *                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00           
# 
#                  distance function: Cosine                  
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# +                                            o  ooooo o    +  120.00
# +                                          oooooooooooooo  +  100.00
# |                                         o  ooooooooooo   |        
# +                       ®                        o o       +   80.00
# |                  ®®®®®®®®                                |        
# +                ®®®®®®®®®®®®                              +   60.00
# +               ®  ®®®®® ®®o                               +   40.00
# |                 ® ®                                      |        
# +              ®®®®®oooo  oooooooo                         +   20.00
# |   *****        ®ooooo  oooooooooo o                      |        
# +*********              oooooooooo  o                      +    0.00
# | * *****                                                  |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

Here is a list of identifiers corresponding to "known functions":

```perl6
say ML::Clustering::DistanceFunctions.known-distance-function-specs():short;
```
```
# (bray-curtis canberra chessboard cosine euclidean hamming manhattan squared-euclidean)
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
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     oooooo                               +   80.00
# +                    oooooooo                              +   60.00
# |                o ooooooooooo                             |        
# +                   oooo  o o                              +   40.00
# |                o oooo       o                            |        
# +                oooooooo oooooooooo                       +   20.00
# |   ooooooo       o ooo  ooooooooooo o                     |        
# +  ooooooooo              o ooooooo  o                     +    0.00
# |   o oo                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.1                   
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     oooooo                               +   80.00
# +                    oooooooo                              +   60.00
# |                o ooooooooooo                             |        
# +                   oooo  o o                              +   40.00
# |                o oooo       o                            |        
# +                oooooooo oooooooooo                       +   20.00
# |   ooooooo       o ooo  ooooooooooo o                     |        
# +  ooooooooo              o ooooooo  o                     +    0.00
# |   o oo                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.7                   
# +----------------+---------------+----------------+--------+        
# |                                                          |        
# |                                             * ***** *    |        
# +                                           *************  +  100.00
# |                                         *  ************  |        
# |                     ooo o                      *         |        
# |                   oooooooo                               |        
# |                oooooooooooo                              |        
# +                  ooooooo oo                              +   50.00
# |                 ooooo                                    |        
# |               oooooooo  *********                        |        
# |  oooooooo       oooooo **********  *                     |        
# + ooooooooo              * *******  *                      +    0.00
# |  o o o                                                   |        
# +----------------+---------------+----------------+--------+        
#                  0.00            50.00            100.00
```

We see the plots above that with smaller learning parameter better results are obtained. But keep in mind that in some
situations that small learning parameters can make the computations too slow or produce worse clustering results.

### Maximum steps

The value m of the named argument `max-steps` is used in the stopping criteria of the implemented K-means algorithm --
if in the number of iterations exceeds m then the algorithms stops. Here is example that shows better clustering results
is obtained with larger max steps:

```perl6
(1, 4, 100).map({ say find-clusters(@data2D5, 2, max-steps => $_).&text-list-plot(title => 'maximum steps: ' ~ $_.Str, point-char => <* o>), "\n" });
```
```
# maximum steps: 1                      
# +----------------+----------------+---------------+--------+        
# +                                                ***       +  120.00
# |                                           * ******* *    |        
# +                                           *************  +  100.00
# |                                         *  ******** ***  |        
# +                     oo* **                     *         +   80.00
# |                   ooooooo*                               |        
# +                oooooooooooo                              +   60.00
# +                   o oo  o o                              +   40.00
# |               o  oooo                                    |        
# +                oooooooo ooooooooo                        +   20.00
# |  oooooooo       ooooo  oooooooooo  o                     |        
# +  oooooooo               o oooooo  o                      +    0.00
# |   o oo                                                   |        
# +----------------+----------------+---------------+--------+        
#                  0.00             50.00           100.00            
# 
#                       maximum steps: 4                      
# +----------------+----------------+----------------+-------+        
# +                                                 oo       +  120.00
# |                                            oooooooooooo  |        
# +                                             oooooooooooo +  100.00
# |                                          o  oooooooo  oo |        
# +                     ******                               +   80.00
# +                    ********                              +   60.00
# |                * ***********                             |        
# +                   ****  * *                              +   40.00
# |                * ****       *                            |        
# +                ******** **********                       +   20.00
# |   *******       * ***  *********** *                     |        
# +  *********              * *******  *                     +    0.00
# |   * **                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                      maximum steps: 100                     
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     oooooo                               +   80.00
# +                    oooooooo                              +   60.00
# |                o ooooooooooo                             |        
# +                   oooo  o o                              +   40.00
# |                o oooo       o                            |        
# +                oooooooo oooooooooo                       +   20.00
# |   ooooooo       o ooo  ooooooooooo o                     |        
# +  ooooooooo              o ooooooo  o                     +    0.00
# |   o oo                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
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
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     □□□□□□                               +   80.00
# |                    □□□□□□□□                              |        
# +                □ □□□□□□□□□□□                             +   60.00
# +                   □□□□□ □ □                              +   40.00
# |                  ▽▽▽▽                                    |        
# +                ▽▽▽▽▽▽▽▽  ▽▽▽▽▽▽▽▽                        +   20.00
# |   ▽ ▽▽▽▽▽       ▽▽▽▽▽▽  ▽▽▽▽▽▽▽▽▽▽ ▽                     |        
# +  ▽▽▽▽▽▽▽▽▽             ▽▽ ▽▽▽▽▽▽▽  ▽                     +    0.00
# |   ▽▽▽▽▽▽                                                 |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                min-reassigments-fraction: 0.3               
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     □□□□□□                               +   80.00
# |                    □□□□□□□□                              |        
# +                □ □□□□□□□□□□□                             +   60.00
# +                   □□□□□ □ □                              +   40.00
# |                  ▽▽▽▽                                    |        
# +                ▽▽▽▽▽▽▽▽  ▽▽▽▽▽▽▽▽                        +   20.00
# |   ▽ ▽▽▽▽▽       ▽▽▽▽▽▽  ▽▽▽▽▽▽▽▽▽▽ ▽                     |        
# +  ▽▽▽▽▽▽▽▽▽             ▽▽ ▽▽▽▽▽▽▽  ▽                     +    0.00
# |   ▽▽▽▽▽▽                                                 |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
```

### Precision goal

The value `p` of the named argument `precision-goal` is used specify in stopping criteria that evaluates the differences
between the "old" and "new" clusters centers -- if the maximum of that difference is less than `10 ** (-p)` then the
cluster finding iterations stop. Here is example that shows using the different precision goals:

```perl6
srand(1921);
(0.2, 5).map({ say find-clusters(@data2D5, 2, precision-goal => $_).&text-list-plot(title => 'precision goal: ' ~ $_.Str, point-char => Whatever), "\n" });
```
```
# precision goal: 0.2                     
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     □□□□□□                               +   80.00
# +                    □□□□□□□□                              +   60.00
# |                □ □□□□□□□□□□□                             |        
# +                   □□□□  □ □                              +   40.00
# |                □ □□□□       □                            |        
# +                □□□□□□□□ □□□□□□□□□□                       +   20.00
# |   □□□□□□□       □ □□□  □□□□□□□□□□□ □                     |        
# +  □□□□□□□□□              □ □□□□□□□  □                     +    0.00
# |   □ □□                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                      precision goal: 5                      
# +----------------+----------------+----------------+-------+        
# +                                                 **       +  120.00
# |                                            ************  |        
# +                                             ************ +  100.00
# |                                          *  ********  ** |        
# +                     □□□□□□                               +   80.00
# +                    □□□□□□□□                              +   60.00
# |                □ □□□□□□□□□□□                             |        
# +                   □□□□  □ □                              +   40.00
# |                □ □□□□       □                            |        
# +                □□□□□□□□ □□□□□□□□□□                       +   20.00
# |   □□□□□□□       □ □□□  □□□□□□□□□□□ □                     |        
# +  □□□□□□□□□              □ □□□□□□□  □                     +    0.00
# |   □ □□                                                   |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
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
# +----------------------+----------------------+-----------------------+
# | BrainWeight          | BodyWeight           | Species               |
# +----------------------+----------------------+-----------------------+
# | Min    => 0.4        | Min    => 0.023      | GreyWolf        => 1  |
# | 1st-Qu => 18.85      | 1st-Qu => 2.9        | Cow             => 1  |
# | Mean   => 574.521429 | Mean   => 4278.43875 | Sheep           => 1  |
# | Median => 137        | Median => 53.83      | Human           => 1  |
# | 3rd-Qu => 421        | 3rd-Qu => 493        | AfricanElephant => 1  |
# | Max    => 5712       | Max    => 87000      | AsianElephant   => 1  |
# |                      |                      | Giraffe         => 1  |
# |                      |                      | (Other)         => 21 |
# +----------------------+----------------------+-----------------------+
```

Cluster by body weight only:

```perl6
my %awRes1 = find-clusters(@data2D2.map({ [$_<BodyWeight>,] }), 4, prop => 'All');
.say for %awRes1<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>, align => { :Species<l> }, float-format =>  '10.3f') });
```
```
# +--------------+------------+------------+
# | Species      | BodyWeight | BodyWeight |
# +--------------+------------+------------+
# | GreyWolf     |     36.330 |     36.330 |
# | Goat         |     27.660 |     27.660 |
# | PotarMonkey  |     10     |     10     |
# | RhesusMonkey |      6.800 |      6.800 |
# | Kangaroo     |     35     |     35     |
# +--------------+------------+------------+
# +------------+------------+------------+
# | Species    | BodyWeight | BodyWeight |
# +------------+------------+------------+
# | Cow        |    465     |    465     |
# | Donkey     |    187.100 |    187.100 |
# | Horse      |    521     |    521     |
# | Giraffe    |    529     |    529     |
# | Gorilla    |    207     |    207     |
# | Human      |     62     |     62     |
# | Sheep      |     55.500 |     55.500 |
# | Jaguar     |    100     |    100     |
# | Chimpanzee |     52.160 |     52.160 |
# | Pig        |    192     |    192     |
# +------------+------------+------------+
# +----------------+------------+------------+
# | Species        | BodyWeight | BodyWeight |
# +----------------+------------+------------+
# | MountainBeaver |      1.350 |      1.350 |
# | GuineaPig      |      1.040 |      1.040 |
# | Cat            |      3.300 |      3.300 |
# | GoldenHamster  |      0.120 |      0.120 |
# | Mouse          |      0.023 |      0.023 |
# | Rabbit         |      2.500 |      2.500 |
# | Rat            |      0.280 |      0.280 |
# | Mole           |      0.122 |      0.122 |
# +----------------+------------+------------+
# +-----------------+------------+------------+
# | Species         | BodyWeight | BodyWeight |
# +-----------------+------------+------------+
# | Diplodocus      |   11700    |   11700    |
# | AsianElephant   |    2547    |    2547    |
# | AfricanElephant |    6654    |    6654    |
# | Triceratops     |    9400    |    9400    |
# | Brachiosaurus   |   87000    |   87000    |
# +-----------------+------------+------------+
```

Note that obtained clusters seem well separated by weight:

```perl6
text-list-plot(((%awRes1<ClusterLabels>.Array >>+>> 1) Z @data2D2.map({ $_<BodyWeight> }))>>.log10.List)
```
```
# +---+-------+--------+-------+--------+--------+-------+---+      
# |                                                          |      
# |                            *                             |      
# +                            *                             +  4.00
# |                            *                             |      
# |                                            *             |      
# +                                            *             +  2.00
# |                                            *         *   |      
# |                                                      *   |      
# |   *                                                      |      
# +   *                                                      +  0.00
# |   *                                                      |      
# |   *                                                      |      
# +                                                          + -2.00
# +---+-------+--------+-------+--------+--------+-------+---+      
#     0.00    0.10     0.20    0.30     0.40     0.50    0.60
```

Here we cluster using both body weight and brain weight -- for that combination of weights it makes sense to cluster
with Cosine distance:

```perl6
my %awRes2 = find-clusters(@data2D2.map({ $_<BodyWeight BrainWeight> }), 4, distance-function => 'Cosine', prop => 'All');
.say for %awRes2<IndexClusters>.map({ to-pretty-table(@data2D2[|$_], field-names => <Species BodyWeight BodyWeight>, align => { :Species<l> }, float-format =>  '10.3f') });
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
# | Horse           |    521     |    521     |
# | Giraffe         |    529     |    529     |
# | AfricanElephant |    6654    |    6654    |
# | Pig             |    192     |    192     |
# +-----------------+------------+------------+
# +---------------+------------+------------+
# | Species       | BodyWeight | BodyWeight |
# +---------------+------------+------------+
# | GreyWolf      |     36.330 |     36.330 |
# | AsianElephant |    2547    |    2547    |
# | Donkey        |    187.100 |    187.100 |
# | Gorilla       |    207     |    207     |
# | Kangaroo      |     35     |     35     |
# | Sheep         |     55.500 |     55.500 |
# | Jaguar        |    100     |    100     |
# +---------------+------------+------------+
# +----------------+------------+------------+
# | Species        | BodyWeight | BodyWeight |
# +----------------+------------+------------+
# | MountainBeaver |      1.350 |      1.350 |
# | Goat           |     27.660 |     27.660 |
# | GuineaPig      |      1.040 |      1.040 |
# | PotarMonkey    |     10     |     10     |
# | Cat            |      3.300 |      3.300 |
# | Human          |     62     |     62     |
# | RhesusMonkey   |      6.800 |      6.800 |
# | GoldenHamster  |      0.120 |      0.120 |
# | Mouse          |      0.023 |      0.023 |
# | Rabbit         |      2.500 |      2.500 |
# | Chimpanzee     |     52.160 |     52.160 |
# | Rat            |      0.280 |      0.280 |
# | Mole           |      0.122 |      0.122 |
# +----------------+------------+------------+
```

Note that obtained clusters seem well separated by body-brain weights directions:

```perl6
text-list-plot(%awRes2<Clusters>>>.log10);
```
```
# +-------+-------+--------+-------+-------+--------+-------++      
# +                                            *  ▽          +  4.00
# |                                                          |      
# +                              ❍                           +  3.00
# |                              ❍   **  ▽                   |      
# |                      ❍       * * ▽                      □|      
# +                        ❍  ❍*                   □         +  2.00
# |                            *                    □        |      
# |                   ❍❍                                     |      
# +               ❍❍                                         +  1.00
# |        ❍                                                 |      
# +       ❍   ❍                                              +  0.00
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
# +---------------+-----------------+----------------+-------+        
# +                                                 33       +  120.00
# |                                           3333333333333  |        
# +                                             333333333311 +  100.00
# |                                          3  11111111  11 |        
# +                    2222 22                               +   80.00
# |                   22222222                               |        
# +               2 22222222222                              +   60.00
# +                  2222222 22                              +   40.00
# |                 5555                                     |        
# +               55555555   55555555                        +   20.00
# |   44444        55555 5 55555555555 5                     |        
# +444444444               5 5555555  5                      +    0.00
# |  444444                     5                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00           
# 
#                            run: 2                           
# +---------------+-----------------+----------------+-------+        
# +                                                2 2       +  120.00
# |                                           2222222222222  |        
# +                                             222222222222 +  100.00
# |                                          2  22222222 222 |        
# +                    3333 3                       2        +   80.00
# |                   33333333                               |        
# +               3 33333333333                              +   60.00
# +                  33333 3 33                              +   40.00
# |                 1 11                                     |        
# +              111111111   11111111                        +   20.00
# |   55555        11111 1 1111111111  1                     |        
# +444555555               1 1111111  1                      +    0.00
# | 4 44445                     1                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00           
# 
#                            run: 3                           
# +---------------+-----------------+----------------+-------+        
# +                                                4 4       +  120.00
# |                                           4444444444444  |        
# +                                             444444444444 +  100.00
# |                                          4  44444444 444 |        
# +                    3333 3                       4        +   80.00
# |                   33333333                               |        
# +               3 33333333333                              +   60.00
# +                  3333333 33                              +   40.00
# |                 3 33                                     |        
# +               33333335   55555555                        +   20.00
# |   22222        33555 5 5555555555  5                     |        
# +111222222               5 5555555  5                      +    0.00
# | 1 11111                     5                            |        
# +---------------+-----------------+----------------+-------+        
#                 0.00              50.00            100.00
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
    say text-list-plot(
            k-means(@blackPoints, 7, distance-function => $_), 
            point-char => (1 .. 7)>>.Str, 
            title => $_, 
            width => 76, height => 18), "\n"
})
```
```
# Euclidean                                  
# +----------+---------+----------+----------+---------+----------+---------++       
# |                                                                          |       
# +         33333                         66 666                             +  15.00
# |         33 33                         66  66                             |       
# |            33                             66                             |       
# |           33                             66                       4444   |       
# +          333                           6 66                       4444   +  10.00
# | 2 2  22 23333                 77   77776 666                        44   |       
# | 2 22222               11       77  77                               44   |       
# |   2222                11       77  77              666444444        44   |       
# |   222              11 1155     777777              66644444         44   |       
# +   2222             11 1155      7777               6644 444         44   +   5.00
# | 2 22222               15        7777               664444444      444444 |       
# |22 2  22               55         77                               444444 |       
# |                                  77                                      |       
# |                                7777                                      |       
# +                               5777                                       +   0.00
# +----------+---------+----------+----------+---------+----------+---------++       
#            10.00     20.00      30.00      40.00     50.00      60.00     70.00    
# 
#                                    Cosine                                   
# ++-------------------+--------------------+--------------------+-----------+       
# |                                                                          |       
# +           3                             2                                +  15.00
# |         33337                         22222                              |       
# |            77                            11                              |       
# |           77                            11                       5544    |       
# +          777                           111                       4444    +  10.00
# |  33  33 77777                 11   11115555                        44    |       
# |  333333              22        11  55                              44    |       
# |   3333               21        55  55             44444444 4       44    |       
# |   333              111111      555554             44444444         66    |       
# +   3377             115555       4444              6666 666         66    +   5.00
# |  337777              55         4444              66666666 6     666666  |       
# | 337  22              44          66                              666666  |       
# |                                  66                                      |       
# |                                6666                                      |       
# +                               6666                                       +   0.00
# ++-------------------+--------------------+--------------------+-----------+       
#  0.00                20.00                40.00                60.00               
# 
#                                  Chessboard                                 
# +----------+---------+----------+---------+----------+---------+----------++       
# +           6                             7                                +  15.00
# |         66666                         7777 7                             |       
# |         66 66                         77 7 7                             |       
# |            66                            7 7                             |       
# |           55                            77                        2222   |       
# +          555                           777                        2222   +  10.00
# | 33   33 55555                 11   7777777 7                        22   |       
# | 333 333              44        11  77                               22   |       
# |  33 33               44        11  77              222222222        22   |       
# |  33 3              4444 44     111111              22222222         22   |       
# +  33 33             4444 44      1111               2222 222         22   +   5.00
# | 333 333              44         1111               222222222      222222 |       
# |333   33              44          11                               222222 |       
# |                                  11                                      |       
# |                                1111                                      |       
# +                               1111                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                  Manhattan                                  
# +----------+---------+----------+---------+----------+---------+----------++       
# +           2                             6                                +  15.00
# |         22222                         6666 6                             |       
# |         22 22                         66 6 6                             |       
# |            22                            6 6                             |       
# |           22                            66                        1111   |       
# +          222                           666                        1111   +  10.00
# | 77   77 22222                 33   6666666 6                        11   |       
# | 777 777              33        33  66                               11   |       
# |  77 77               33        33  66              111111111        11   |       
# |  77 7              3333 33     334446              11111111         11   |       
# +  77 77             3333 33      4444               1111 111         11   +   5.00
# | 777 777              33         4444               111111111      111111 |       
# |777   77              33          44                               111111 |       
# |                                  44                                      |       
# |                                5555                                      |       
# +                               5555                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                  BrayCurtis                                 
# +----------+---------+----------+---------+----------+---------+----------++       
# +           7                             1                                +  15.00
# |         77777                         11111                              |       
# |         77 77                         11 11                              |       
# |            77                            11                              |       
# |           77                            11                        6666   |       
# +          777                           111                        6666   +  10.00
# | 44  27  77777                 11   11111111                         66   |       
# | 444222               33        11  11                               66   |       
# |  4422                33        55  11              666666666        66   |       
# |  442               333333      555511              66666666         66   |       
# +  4422              333333       5555               6666 666         66   +   5.00
# | 444222               33         5555               666666666      666666 |       
# |444  22               33          55                               666666 |       
# |                                  55                                      |       
# |                                5555                                      |       
# +                               5555                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                   Canberra                                  
# +--+-------------------+------------------+-------------------+------------+       
# +             2                           7                                +  15.00
# |           22222                       77777                              |       
# |           22 22                       77 77                              |       
# |              22                          77                              |       
# |             22                          77                      5555     |       
# +            666                         777                      5555     +  10.00
# |    11  11 66666                77  77777777                       55     |       
# |    111111              77       7  77                             55     |       
# |     1111               33       3  77             555555555       55     |       
# |     111              333333     33333             44444444        55     |       
# +     1111             333333     3333              4444 444        44     +   5.00
# |    111111              33       3333              444444444     444444   |       
# |   411  11              33        33                             444444   |       
# |                                  33                                      |       
# |                                 333                                      |       
# +                                333                                       +   0.00
# +--+-------------------+------------------+-------------------+------------+       
#    0.00                20.00              40.00               60.00
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
