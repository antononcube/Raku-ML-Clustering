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
# | Min    => 2.698581683788763  | Min    => 1.4819154339628895 |
# | 1st-Qu => 5.432956492366866  | 1st-Qu => 5.4023111425285055 |
# | Mean   => 8.148305216627143  | Mean   => 8.113476738729794  |
# | Median => 9.006384705224104  | Median => 9.112610128276433  |
# | 3rd-Qu => 10.228647097853418 | 3rd-Qu => 10.132264794134208 |
# | Max    => 12.850646902026524 | Max    => 11.56185351862909  |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data2D2)
```
```
# +-----+----------+---------+---------+---------+----------++       
# |                                                          |       
# +                                             ** *         +  12.00
# |                                   *   *  **   *    *     |       
# |                                       * *** **  * ****   |       
# +                                        **  ***** * * *   +  10.00
# |                                        * *** *****       |       
# +                                       * *  *             +   8.00
# |                                                          |       
# +   *      *   * ** * *      *   *                         +   6.00
# |           *  *  ***         *    **       *              |       
# +         *    **         *   * *                          +   4.00
# |                    *                                     |       
# +                                                          +   2.00
# +-----+----------+---------+---------+---------+----------++       
#       2.00       4.00      6.00      8.00      10.00      12.00
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
# ((9.15733388629455 10.186143635665534) (9.840301069203338 9.810307332586431) (10.44218576131974 10.777891233008647))
# ((4.709334697818281 4.872381116790246) (4.6335344043983975 5.5149526255842) (6.446854331507217 6.271574237135668))
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot(@cls, point-char => <▽ ☐>, title => '▽ - 1st cluster; ☐ - 2nd cluster')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster              
# +-----+----------+---------+----------+----------+---------+       
# |                                                ▽         |       
# +                                               ▽ ▽        +  12.00
# |                                    ▽   ▽  ▽▽   ▽     ▽   |       
# |                                        ▽ ▽▽▽ ▽▽▽ ▽  ▽▽▽  |       
# +                                         ▽ ▽ ▽ ▽▽▽ ▽ ▽▽▽▽ +  10.00
# |                                         ▽ ▽▽▽ ▽▽▽ ▽      |       
# +                                                          +   8.00
# |                                        ▽ ▽   ▽           |       
# +  ☐       ☐   ☐ ☐☐   ☐       ☐   ☐                        +   6.00
# |           ☐  ☐  ☐☐☐              ☐ ☐        ☐            |       
# +         ☐    ☐               ☐ ☐                         +   4.00
# |               ☐     ☐   ☐                                |       
# |                    ☐                                     |       
# +-----+----------+---------+----------+----------+---------+       
#       2.00       4.00      6.00       8.00       10.00
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
# |                                           *   *          |        
# |                                            ********* *   |        
# +                                          ************    +  100.00
# |                                           ***********    |        
# |                    ******* *                *  *         |        
# |                 ************                             |        
# +                   ******* *                              +   50.00
# |                  ***                                     |        
# |               ********* *******                          |        
# |   *******       * ***  ***********                       |        
# +   ********              **** *                           +    0.00
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
# +---------------+----------------+-----------------+-------+        
# |                                             4            |        
# |                                                 444  4 4 |        
# |                                           444444444444 4 |        
# +                                           4444444●44444  +  100.00
# |                                            4 4444444444  |        
# |                   333333333                   4          |        
# |               3 33333●333333                             |        
# +                  33333333 3                              +   50.00
# |                   5                                      |        
# |               5555●555  2222222                          |        
# |1 11111       55555555 222222●2222 2                      |        
# + 111●11111             2222222222 2                       +    0.00
# | 111111                                                   |        
# +---------------+----------------+-----------------+-------+        
#                 0.00             50.00             100.00
```

**Remark:** The function `k-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are the centers of the clusters (the mean points):

```perl6
%clRes<MeanPoints>
```
```
# [(38.803056705599346 10.082277323752416) (99.03271089487261 100.36033198335849) (10.042437748181943 20.327767889869744) (-30.56355222775767 0.22830710099969354) (20.089159106923262 59.7669094532978)]
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
# |                                             o            |        
# |                                                 oo o o o |        
# |                                           o oooooooooo o |        
# +                                            oooooooooooo  +  100.00
# |                                            o oo ooooooo  |        
# |                    ******* *                  o          |        
# |                * ***********                             |        
# +                   ******** *                             +   50.00
# |                    ®                                     |        
# |               ®®®®®®®®® ®®®®®®®®                         |        
# |  ®®®®®®®      ®®®®®®®® ®®®®®®®®®®®®                      |        
# +  ®®®®®®®®®             ® ®®®®®®®  ®                      +    0.00
# |  ®®®® ®                                                  |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                  distance function: Cosine                  
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# |                                            o   *         |        
# |                                            ************  |        
# +                                          *************   +  100.00
# |                                           ************   |        
# |                  oooooo o o                  *  *        |        
# |                oooooooooooo                              |        
# +               o ooooooooooo                              +   50.00
# |                   o                                      |        
# |              oooooooo* ********                          |        
# |® ®®®®®       oooooo*  ********** *                       |        
# + ®®®®®®®®              ********* *                        +    0.00
# | ®®®®®®                                                   |        
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
# |                                             o            |        
# |                                                 oo o o o |        
# |                                           o oooooooooooo |        
# +                                            oooooooooooo  +  100.00
# |                                            o oo ooooooo  |        
# |                    ******* *                             |        
# |                * ***********                             |        
# +                   ******** *                             +   50.00
# |                  * *                                     |        
# |               ********* ********                         |        
# |  *******        ****** ************                      |        
# +  *********               ******                          +    0.00
# |  *                                                       |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.1                   
# +----------------+----------------+----------------+-------+        
# |                                             *            |        
# |                                                 ** * * * |        
# |                                           * ************ |        
# +                                            ************  +  100.00
# |                                            * ** *******  |        
# |                    ooooooo o                             |        
# |                o ooooooooooo                             |        
# +                   oooooooo o                             +   50.00
# |                  o o                                     |        
# |               ooooooooo oooooooo                         |        
# |  ooooooo        oooooo oooooooooooo                      |        
# +  ooooooooo               oooooo                          +    0.00
# |  o                                                       |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                    learning-parameter:0.7                   
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# |                                            *  *          |        
# |                                            ************  |        
# +                                          *************   +  100.00
# |                                           ********** *   |        
# |                   ******* *                  *  *   *    |        
# |                 ***********                              |        
# +               *  **********                              +   50.00
# |                   *                                      |        
# |               ooo***** ********                          |        
# | oooooo       ooooo*** ********** *                       |        
# + ooooooooo             *********  *                       +    0.00
# | oooooo                                                   |        
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
# |                                                          |        
# |                                            *   *         |        
# |                                            ************  |        
# +                                          *************   +  100.00
# |                                           ************   |        
# |                   ******* *                  *  *        |        
# |               o ***********                              |        
# +                  ******** *                              +   50.00
# |                   *                                      |        
# |              ooo****** ********                          |        
# | ooooooo      ooo***** ********** *                       |        
# + ooooooooo             *********  *                       +    0.00
# | o o o                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                       maximum steps: 4                      
# +---------------+----------------+----------------+--------+        
# |                                                          |        
# |                                            o   o         |        
# |                                            oooooooooooo  |        
# +                                          ooooooooooooo   +  100.00
# |                                           oooo ooooooo   |        
# |                   ooooooooo                  o  o        |        
# |                *ooooooooooo                              |        
# +                  oooooooo o                              +   50.00
# |                   *                                      |        
# |               ********  **ooooo                          |        
# | * *****      * ******  ****ooooooo                       |        
# +  ********             * *******  o                       +    0.00
# |  * **                                                    |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      maximum steps: 100                     
# +----------------+----------------+----------------+-------+        
# |                                             o            |        
# |                                                 oo o o o |        
# |                                           o oooooooooooo |        
# +                                            oooooooooooo  +  100.00
# |                                            o oo ooooooo  |        
# |                    ******* *                             |        
# |                * ***********                             |        
# +                   ******** *                             +   50.00
# |                  * *                                     |        
# |               ********* ********                         |        
# |  *******        ****** ************                      |        
# +  *********               ******                          +    0.00
# |  *                                                       |        
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
# +---------------+----------------+-----------------+-------+        
# |                                             ▽            |        
# |                                                 ▽▽▽  ▽ ▽ |        
# |                                           ▽▽▽▽▽▽▽▽▽▽▽▽ ▽ |        
# +                                           ▽▽▽▽▽▽▽▽▽▽▽▽▽  +  100.00
# |                                            ▽ ▽▽▽▽▽▽▽▽▽▽  |        
# |                   □□□□□□□□□                   ▽          |        
# |               □ □□□□□□□□□□□□                             |        
# +                  □□□□□□□□ □                              +   50.00
# |                   □                                      |        
# |               □□□□□□□□  □□□□□□□                          |        
# |* *****       □□□□□□□□ □□□□□□□□□□□ □                      |        
# + *********             □□□□□□□□□□ □                       +    0.00
# | ******                                                   |        
# +---------------+----------------+-----------------+-------+        
#                 0.00             50.00             100.00           
# 
#                min-reassigments-fraction: 0.3               
# +---------------+----------------+-----------------+-------+        
# |                                             ▽            |        
# |                                                 ▽▽▽  ▽ ▽ |        
# |                                           ▽▽▽▽▽▽▽▽▽▽▽▽ ▽ |        
# +                                           ▽▽▽▽▽▽▽▽▽▽▽▽▽  +  100.00
# |                                            ▽ ▽▽▽▽▽▽▽▽▽▽  |        
# |                   □□□□□□□□□                   ▽          |        
# |               □ □□□□□□□□□□□□                             |        
# +                  □□□□□□□□ □                              +   50.00
# |                   □                                      |        
# |               □□□□□□□□  □□□□□□□                          |        
# |* *****       □□□□□□□□ □□□□□□□□□□□ □                      |        
# + *********             □□□□□□□□□□ □                       +    0.00
# | ******                                                   |        
# +---------------+----------------+-----------------+-------+        
#                 0.00             50.00             100.00
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
# |                                             □            |        
# |                                                 □□ □ □ □ |        
# |                                           □ □□□□□□□□□□□□ |        
# +                                            □□□□□□□□□□□□  +  100.00
# |                                            □ □□ □□□□□□□  |        
# |                    ******* *                             |        
# |                * ***********                             |        
# +                   ******** *                             +   50.00
# |                  * *                                     |        
# |               ********* ********                         |        
# |  *******        ****** ************                      |        
# +  *********               ******                          +    0.00
# |  *                                                       |        
# +----------------+----------------+----------------+-------+        
#                  0.00             50.00            100.00           
# 
#                      precision goal: 5                      
# +----------------+----------------+----------------+-------+        
# |                                             *            |        
# |                                                 ** * * * |        
# |                                           * ************ |        
# +                                            ************  +  100.00
# |                                            * ** *******  |        
# |                    □□□□□□□ □                             |        
# |                □ □□□□□□□□□□□                             |        
# +                   □□□□□□□□ □                             +   50.00
# |                  □ □                                     |        
# |               □□□□□□□□□ □□□□□□□□                         |        
# |  □□□□□□□        □□□□□□ □□□□□□□□□□□□                      |        
# +  □□□□□□□□□               □□□□□□                          +    0.00
# |  □                                                       |        
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

Extract point-vectors from a rasterized formula:

Plot the extracted point-vectors:

Cluster and plot the clusters using different distance functions:


-------

## References

### Articles, books

[Wk1] Wikipedia entry, ["Cluster Analysis"](https://en.wikipedia.org/wiki/K-means_clustering).

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
