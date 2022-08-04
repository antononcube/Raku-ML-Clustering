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
# | 0                            | 1                            |
# +------------------------------+------------------------------+
# | Min    => 2.2281365166048808 | Min    => 2.9382159679307494 |
# | 1st-Qu => 6.250110072780141  | 1st-Qu => 5.164380329582421  |
# | Mean   => 8.2360458040384    | Mean   => 7.981618928486766  |
# | Median => 8.950762558540042  | Median => 9.106032906312041  |
# | 3rd-Qu => 10.336161562453555 | 3rd-Qu => 9.930676893915638  |
# | Max    => 12.053245516793952 | Max    => 11.698726286080701 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +-+----------+---------+----------+---------+----------+---+       
# +                                                          +  12.00
# |                                              **  *   *   |       
# |                                * *  *** *     * *        |       
# +                                    **** * *****  *   *   +  10.00
# |                                    ***     **** **       |       
# +                                       *     **           +   8.00
# |                                                          |       
# |                      *                                   |       
# +   *      *     *       *  *                              +   6.00
# |        * * * * ***    * *        **                      |       
# +          *        *  *  * * *                            +   4.00
# |                  *      *                                |       
# |                                                          |       
# +-+----------+---------+----------+---------+----------+---+       
#   2.00       4.00      6.00       8.00      10.00      12.00
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

**Remark:** The first argument is data points that is a list-of-numeric-lists. 
The second argument is a number of clusters to be found. 

**Remark:** 
Here are sample points from each found cluster:

```perl6
.say for @cls>>.pick(3);
```
```
# ((5.995193200689768 3.90004257757857) (4.8386210308008 5.047013641358976) (6.352695065288211 6.012939274733107))
# ((12.053245516793952 9.654112920321383) (10.191927147647144 10.118188042793188) (10.406041929520853 9.762167912395329))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# ++----------+----------+----------+----------+-----------+-+       
# +                                                        ☐ +  12.00
# |                                 ☐☐   ☐☐ ☐     ☐☐   ☐     |       
# +                                  ☐  ☐  ☐    ☐☐☐☐ ☐       +  10.00
# |                                     ☐☐☐☐ ☐ ☐ ☐☐☐  ☐    ☐ |       
# |                                    ☐ ☐☐     ☐ ☐☐ ☐☐      |       
# +                                        ☐      ☐          +   8.00
# |                                                          |       
# |                      ▽                                   |       
# +  ▽       ▽     ▽       ▽  ▽                              +   6.00
# |       ▽  ▽ ▽ ▽ ▽ ▽    ▽ ▽        ▽▽                      |       
# +         ▽▽        ▽  ▽  ▽ ▽  ▽                           +   4.00
# |                  ▽                                       |       
# |                         ▽                                |       
# ++----------+----------+----------+----------+-----------+-+       
#  2.00       4.00       6.00       8.00       10.00       12.00
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
# ++---------------+----------------+---------------+--------+        
# |                                                          |        
# |                                              * **** **   |        
# |                                            ***********   |        
# +                                            ***********   +  100.00
# |                                          *  *** ****     |        
# |                   *********                              |        
# |                 ***********                              |        
# +                       *** *                              +   50.00
# |                   ****                                   |        
# |                 ******* ********* *                      |        
# +    *******       ***   ************                      +    0.00
# |   ********               ** ****                         |        
# |                                                          |        
# ++---------------+----------------+---------------+--------+        
#  -50.00          0.00             50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(32);
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +---------------+-----------------+----------------+-------+        
# |                                                     1 1  |        
# |                                             11 111111111 |        
# +                                             555555●51515 +  100.00
# |                                           5 55555●55555  |        
# |                                              5 55555     |        
# |                  3333333333                              |        
# |                 33333333333                              |        
# +                   33●333  3                              +   50.00
# |                  3                                       |        
# |                3333444   4444444                         |        
# |  22222 2       334444  44444●4444444                     |        
# +2 222●222                444444444                        +    0.00
# |  2 22222                                                 |        
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
# [(-30.2942695419995 -0.11582340982777715) (15.46347427852727 42.48107028183905) (102.35702796060134 109.015147508923) (38.08330253079351 9.763674601225604) (98.90503774367805 94.51464917524534)]
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
# +----------------+----------------+----------------+-------+        
# |                                                       *  |        
# |                                             ** ********* |        
# +                                             ************ +  100.00
# |                                            ************  |        
# |                                              * **** *    |        
# |                   ®®®®®®®®®®                             |        
# +                 ®®®®®®®®®®®®                             +   50.00
# |                       ®®®                                |        
# |                  ®®®®®                                   |        
# |                ®®®®®®®®  oooooooo  o                     |        
# |  ®®®®®®®®        ®®® ® o oooooooooo                      |        
# + ® ®®®®®®®                ooo oooo                        +    0.00
# |      ®  ®                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                  distance function: Cosine                  
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# |                                               oooooo o   |        
# |                                            oooooooooooo  |        
# +                                            oooooooooooo  +  100.00
# |                                          o  oooooooooo   |        
# |                  ®®®®®®®®®®                              |        
# |                ®®®®®®®®®®®                               |        
# +                  ®®®®®®®®®                               +   50.00
# |                 ®                                        |        
# |               ®®®®oooo   ooo ooo                         |        
# |  ***** *       ®®oooo ooooooooooooo                      |        
# +*********                ooooooooo                        +    0.00
# |  * *****                                                 |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
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
# +----------------+----------------+----------------+-------+        
# |                                                       o  |        
# |                                             oo ooooooooo |        
# +                                             oooooooooooo +  100.00
# |                                            oooooooooooo  |        
# |                                              o oooo o    |        
# |                   **********                             |        
# +                 ************                             +   50.00
# |                       ***                                |        
# |                   ****                                   |        
# |                 *******  ********* *                     |        
# |   *******        *** * * ***********                     |        
# +  ********                ** *****                        +    0.00
# |      *  *                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.1                   
# +----------------+----------------+----------------+-------+        
# |                                                       *  |        
# |                                             ** ********* |        
# +                                             ************ +  100.00
# |                                            ************  |        
# |                                              * **** *    |        
# |                   oooooooooo                             |        
# +                 oooooooooooo                             +   50.00
# |                       ooo                                |        
# |                   oooo                                   |        
# |                 ooooooo  ooooooooo o                     |        
# |   ooooooo        ooo o o ooooooooooo                     |        
# +  oooooooo                oo ooooo                        +    0.00
# |      o  o                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.7                   
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# |                                               ****** *   |        
# |                                            ************  |        
# +                                            ************  +  100.00
# |                                          *  **********   |        
# |                  **********                              |        
# |                ************                              |        
# +                   ********                               +   50.00
# |                  *                                       |        
# |                oo*****   *******                         |        
# |   oooooo       ooo*** * ***********                      |        
# + oooooooo                *********                        +    0.00
# |  o ooooo                                                 |        
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
# +----------------+----------------+---------------+--------+        
# |                                                      *   |        
# |                                               ********   |        
# +                                            ************  +  100.00
# |                                            ************  |        
# |                                           * * ******     |        
# |                   *********                              |        
# |                 ***********                              |        
# +                   ****** **                              +   50.00
# |                  o                                       |        
# |                oooooooo  ooooooo                         |        
# |   ooooo o       oooooo oooooooooooo                      |        
# +  oooooooo               ooooooooo                        +    0.00
# |   o ooooo                                                |        
# +----------------+----------------+---------------+--------+        
#                  0.00             50.00           100.00            
# 
#                       maximum steps: 4                      
# +----------------+----------------+---------------+--------+        
# |                                                      o   |        
# |                                               oooooooo   |        
# |                                            oooooooooooo  |        
# +                                            oooooooooooo  +  100.00
# |                                           o ooooooooo    |        
# |                   ooooooooo                              |        
# |                 *oooooooooo                              |        
# +                   ***ooo oo                              +   50.00
# |                  *  *                                    |        
# |                ********  *****oo                         |        
# |   ***** *        ***** ***********o                      |        
# +  ********               ********                         +    0.00
# |   * *** *                                                |        
# +----------------+----------------+---------------+--------+        
#                  0.00             50.00           100.00            
# 
#                      maximum steps: 100                     
# +----------------+----------------+----------------+-------+        
# |                                                       *  |        
# |                                             ** ********* |        
# +                                             ************ +  100.00
# |                                            ************  |        
# |                                              * **** *    |        
# |                   oooooooooo                             |        
# +                 oooooooooooo                             +   50.00
# |                       ooo                                |        
# |                   oooo                                   |        
# |                 ooooooo  ooooooooo o                     |        
# |   ooooooo        ooo o o ooooooooooo                     |        
# +  oooooooo                oo ooooo                        +    0.00
# |      o  o                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
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
# +----------------+----------------+----------------+-------+        
# |                                                       ▽  |        
# |                                             ▽▽ ▽▽▽▽▽▽▽▽▽ |        
# +                                             ▽▽▽▽▽▽▽▽▽▽▽▽ +  100.00
# |                                            ▽▽▽▽▽▽▽▽▽▽▽▽  |        
# |                                              ▽ ▽▽▽▽ ▽    |        
# |                   **********                             |        
# +                 ************                             +   50.00
# |                       ***                                |        
# |                  *****                                   |        
# |                ********  □□□□□□□□  □                     |        
# |  ********        *** * □ □□□□□□□□□□                      |        
# + * *******                □□□ □□□□                        +    0.00
# |      *  *                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                min-reassigments-fraction: 0.3               
# +----------------+----------------+----------------+-------+        
# |                                                     ▽ ▽  |        
# |                                             ▽▽ ▽▽▽▽▽▽▽▽▽ |        
# +                                             *▽▽▽▽▽▽▽▽▽▽▽ +  100.00
# |                                            ************  |        
# |                          □□                  * **** *    |        
# |                   □□□□□□□□□□                             |        
# +                 □□□□□□□□□□□□                             +   50.00
# |                       □□□                                |        
# |                   □□□□                                   |        
# |                 □□□□□□□  □□□□□□□□□ □                     |        
# |   □□□□□□□        □□□ □ □ □□□□□□□□□□□                     |        
# +  □□□□□□□□                □□ □□□□□                        +    0.00
# |      □  □                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
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
# +----------------+----------------+----------------+-------+        
# |                                                       *  |        
# |                                             ** ********* |        
# +                                             ************ +  100.00
# |                                            ************  |        
# |                                              * **** *    |        
# |                   □□□□□□□□□□                             |        
# +                 □□□□□□□□□□□□                             +   50.00
# |                       □□□                                |        
# |                   □□□□                                   |        
# |                 □□□□□□□  □□□□□□□□□ □                     |        
# |   □□□□□□□        □□□ □ □ □□□□□□□□□□□                     |        
# +  □□□□□□□□                □□ □□□□□                        +    0.00
# |      □  □                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                      precision goal: 5                      
# +----------------+----------------+----------------+-------+        
# |                                                       *  |        
# |                                             ** ********* |        
# +                                             ************ +  100.00
# |                                            ************  |        
# |                                              * **** *    |        
# |                   □□□□□□□□□□                             |        
# +                 □□□□□□□□□□□□                             +   50.00
# |                       □□□                                |        
# |                   □□□□                                   |        
# |                 □□□□□□□  □□□□□□□□□ □                     |        
# |   □□□□□□□        □□□ □ □ □□□□□□□□□□□                     |        
# +  □□□□□□□□                □□ □□□□□                        +    0.00
# |      □  □                                                |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00
```

-------

## Applications

### Animal weights clustering

Take animal weights data2D2 (and show data2D2 dimensions):

Summarize:

Cluster by body weight only:

Note that obtained clusters seem well separated by weight:

Here we cluster using both body weight and brain weight -- 
for that combination of weights it makes sense to cluster with CosineDistance:

Note that obtained clusters seem well separated by body-brain weights directions:

------

## Properties and Relations

Often it is good idea to run `k-means` a few times:


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
# +----------+----------+---------+----------+----------+---------+----------+       
# |                                                                          |       
# +           3                              2                               +  15.00
# |         44333                          22222                             |       
# |         44 33                          22 22                             |       
# |           33                             22                        7777  |       
# +          433                            222                        7777  +  10.00
# | 44   44 44333                 22    22222222                         77  |       
# | 44 4444               33       22   22                               77  |       
# |  4 444                33       22   22              666666666        77  |       
# |  4 44               333333     222 222              66666666         77  |       
# +  5 555              333333      22 22               6666 666         77  +   5.00
# | 55 5555               33        22 22               666666666      777111|       
# |555   55               33         2 2                               771111|       
# |                                222 2                                     |       
# +                               2222                                       +   0.00
# |                                                                          |       
# +----------+----------+---------+----------+----------+---------+----------+       
#            10.00      20.00     30.00      40.00      50.00     60.00              
# 
#                                    Cosine                                   
# +--------------------+--------------------+--------------------+-----------+       
# |                                                                          |       
# +           1                             5                                +  15.00
# |         11166                         55555                              |       
# |            66                            55                              |       
# |           66                            55                       7777    |       
# +          666                           333                       7777    +  10.00
# |  11  11 66222                 55   33333333                        77    |       
# |  111116              55        33  33                              77    |       
# |   1116               55        33  33             777777777        77    |       
# |   116              555333      333777             77777777         44    |       
# +   1166             333333       7777              7444 444         44    +   5.00
# |  116222              37         7777              444444444      444444  |       
# | 116  25              77          44                              444444  |       
# |                                  44                                      |       
# |                                4444                                      |       
# +                               4444                                       +   0.00
# +--------------------+--------------------+--------------------+-----------+       
#                      20.00                40.00                60.00               
# 
#                                  Chessboard                                 
# +----------+---------+----------+---------+----------+---------+----------++       
# |                                                                          |       
# +           2                             5                                +  15.00
# |         22222                         55555                              |       
# |         22 22                         55 55                              |       
# |           22                            55                        6666   |       
# +          222                           555                        6666   +  10.00
# | 33  33  22222                 75   55555555                         66   |       
# | 333333               11        55  55                               66   |       
# |  3333                11        55  55              666666666        66   |       
# |  333               111177      555555              66666666         66   |       
# +  4333              111177       5555               6666 666         66   +   5.00
# | 444333               11         5555               666666666      666666 |       
# |444  33               17          55                               666666 |       
# |                                7555                                      |       
# +                               7775                                       +   0.00
# |                                                                          |       
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00    
# 
#                                  Manhattan                                  
# ++---------+----------+---------+----------+----------+---------+----------+       
# |                                                                          |       
# +           7                              6                               +  15.00
# |         77777                          66666                             |       
# |            77                             66                             |       
# |           77                             66                       33 33  |       
# +          777                            666                       33 33  +  10.00
# |  77  77 77777                 66    66666666                         33  |       
# |  777777               22       66   66                               33  |       
# |   7777                22       26   66              444451111        33  |       
# |   777               222222     22 6666              44445111         33  |       
# +   7777              222222      2 266               4444 511         33  +   5.00
# |  777777               22        2 226               444555511     33 3333|       
# | 777  77               22          22                              33 3333|       
# |                                   22                                     |       
# |                                22 22                                     |       
# +                               222 2                                      +   0.00
# ++---------+----------+---------+----------+----------+---------+----------+       
#  0.00      10.00      20.00     30.00      40.00      50.00     60.00              
# 
#                                  BrayCurtis                                 
# +----------+----------+---------+----------+---------+----------+----------+       
# +           4                              7                               +  15.00
# |         44444                          77777                             |       
# |         44 44                          77 77                             |       
# |            44                             77                             |       
# |           44                             77                       22 22  |       
# +          444                            777                       22 22  +  10.00
# | 55   44 44444                 66    77777777                         22  |       
# | 55 5554               66       66   77                               22  |       
# |  5 555                66       66   77             1 11111111        22  |       
# |  5 55               666666     6666 77             1 1111111         22  |       
# +  5 555              666666      666 6              3 333 333         22  +   5.00
# | 55 5555               66        666 6              3 33333333     22 2222|       
# |555   55               66         66                               22 2222|       
# |                                  66                                      |       
# |                                6666                                      |       
# +                               6666                                       +   0.00
# +----------+----------+---------+----------+---------+----------+----------+       
#            10.00      20.00     30.00      40.00     50.00      60.00              
# 
#                                   Canberra                                  
# +----------+---------+----------+---------+----------+---------+----------++       
# +           1                             5                                +  15.00
# |         11111                         5555 5                             |       
# |         11 11                         55 5 5                             |       
# |            11                            5 5                             |       
# |           11                            55                        5555   |       
# +          111                           555                        5555   +  10.00
# | 33   11 11111                 55   5555555 5                        55   |       
# | 333 331              22        22  55                               44   |       
# |  33 33               22        22  22              444444444        44   |       
# |  33 3              2222 22     222222              44444444         44   |       
# +  33 33             2222 22      2222               4444 444         77   +   5.00
# | 333 333              22         2222               777777777      777777 |       
# |333   33              22          22                               777777 |       
# |                                  66                                      |       
# |                                6666                                      |       
# +                               6666                                       +   0.00
# +----------+---------+----------+---------+----------+---------+----------++       
#            10.00     20.00      30.00     40.00      50.00     60.00      70.00
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
