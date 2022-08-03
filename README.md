# Raku ML::Clustering

[![SparkyCI](http://sparrowhub.io:2222/project/gh-antononcube-Raku-ML-Clustering/badge)](http://sparrowhub.io:2222)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This repository has the code of a Raku package for
Machine Learning (ML)
[Clustering (or Cluster analysis)](https://en.wikipedia.org/wiki/Cluster_analysis)
functions, [Wk1].

The Clustering framework includes the algorithms 
[K-means](https://en.wikipedia.org/wiki/K-means_clustering) 
and 
[K-medoids](https://en.wikipedia.org/wiki/K-medoids), 
and the distance functions Euclidean, Cosine, Hamming, Manhattan, and others,
and their corresponding similarity functions.

The data in the examples below is generated and manipulated with the packages
["Data::Generators"](https://raku.land/zef:antononcube/Data::Generators),
["Data::Reshapers"](https://raku.land/zef:antononcube/Data::Reshapers), and
["Data::Summarizers"](https://raku.land/zef:antononcube/Data::Summarizers), described in the article
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
[AA1].

The plots are made with the package
["Text::Plot"](https://raku.land/zef:antononcube/Text::Plot), [AAp6].

-------

## Installation

Via zef-ecosystem:

```shell
zef install ML::Clustering
```

From GitHub:

```shell
zef install https://github.com/antononcube/Raku-ML-Clustering
```

-------

## Cluster finding 

Here we derive a set of random points, and summarize it:

```perl6
use Data::Generators;
use Data::Summarizers;
use Text::Plot;

my $n = 100;
my @data1 = (random-variate(NormalDistribution.new(5,1.5), $n) X random-variate(NormalDistribution.new(5,1), $n)).pick(30);
my @data2 = (random-variate(NormalDistribution.new(10,1), $n) X random-variate(NormalDistribution.new(10,1), $n)).pick(50);
my @data3 = [|@data1, |@data2].pick(*);
records-summary(@data3)
```
```
# +------------------------------+------------------------------+
# | 1                            | 0                            |
# +------------------------------+------------------------------+
# | Min    => 2.508872359103074  | Min    => 3.34250672383671   |
# | 1st-Qu => 5.242794859784507  | 1st-Qu => 5.826260262755103  |
# | Mean   => 8.181760850229328  | Mean   => 8.473786224860143  |
# | Median => 9.211569064687094  | Median => 9.645738445834139  |
# | 3rd-Qu => 10.539313854115932 | 3rd-Qu => 10.57619701530749  |
# | Max    => 12.412513816117531 | Max    => 12.680659012242906 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data3)
```
```
# +------+----------+----------+----------+-----------+------+       
# |                                                          |       
# +                                        *  *              +  12.00
# |                       *            * ***** **   **       |       
# +                              *   *** *** * *** *     *   +  10.00
# |                                       *    * *     *     |       
# +                                *  * * **** **            +   8.00
# |                                                          |       
# |           *  *                                           |       
# +   *     * *  **  * *    *                                +   6.00
# |   ** *   *    ****  *                                    |       
# +                ** *                                      +   4.00
# |       *  *    *                                          |       
# +                                                          +   2.00
# +------+----------+----------+----------+-----------+------+       
#        4.00       6.00       8.00       10.00       12.00
```

**Problem:** Group the points in such a way that each group has close (or similar) points.

Here is how we use the function `find-clusters` to give an answer:

```perl6
use ML::Clustering;
my %res = find-clusters(@data3, 2, prop => 'All');
%res<Clusters>>>.elems
```
```
# (50 30)
```

**Remark:** The first argument is data points list-of-numeric-lists. 
The second argument is number of clusters to be found. (See the TODO section below.)  

**Remark:** The function `find-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are sample points from each found cluster:

```perl6
.say for %res<Clusters>>>.pick(3);
```
```
# ((11.848142327296804 11.375395352114566) (10.153040921729506 10.150711593382594) (10.939090442933948 8.790582220370437))
# ((4.183757887265591 2.508872359103074) (4.503457574076106 5.678724979399392) (5.863702472090488 4.059667088990481))
```

Here are the centers of the clusters (the mean points):

```perl6
%res<MeanPoints>
```
```
# [(10.37837350731946 10.27497009622672) (6.130395165656584 5.690548255119461)]
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot((|%res<Clusters>, %res<MeanPoints>), point-char => <▽ ☐ ●>, title => '▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers    
# +-----+-----------+----------+-----------+----------+------+       
# |                                        ▽   ▽             |       
# +                                       ▽     ▽    ▽       +  12.00
# |                       ▽          ▽ ▽ ▽  ▽▽ ▽▽ ▽ ▽     ▽  |       
# +                              ▽     ▽   ▽▽●▽▽▽▽           +  10.00
# |                                    ▽  ▽▽    ▽ ▽     ▽    |       
# +                                ▽    ▽  ▽▽▽  ▽            +   8.00
# |                                                          |       
# |          ☐  ☐                                            |       
# + ☐      ☐ ☐  ☐☐  ● ☐                                      +   6.00
# | ☐ ☐ ☐   ☐     ☐ ☐  ☐   ☐☐                                |       
# +               ☐☐  ☐                                      +   4.00
# |              ☐                                           |       
# +      ☐  ☐                                                +   2.00
# +-----+-----------+----------+-----------+----------+------+       
#       4.00        6.00       8.00        10.00      12.00
```

**Remark:** By default `find-clusters` uses the K-means algorithm. The functions `k-means` and `k-medoids`
call `find-clusters` with the option settings `method=>'K-means'` and `method=>'K-medoids'` respectively.

### More interesting looking data

Here is more interesting looking 2D, `data2D2`:

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
# +---------------+---------------+---------------+----------+        
# |                                                          |        
# |                                           **********     |        
# +                                         ************ *   +  100.00
# |                                        *  ***********    |        
# |                    * ***                     **  **      |        
# |                 ************                             |        
# +                 * ********                               +   50.00
# |                   * **** *                               |        
# |                ******       **                           |        
# |               ******** **********                        |        
# |   ********      *** *  **********                        |        
# +   *******                *****                           +    0.00
# |                                                          |        
# +---------------+---------------+---------------+----------+        
#                 0.00            50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +--------------+----------------+-----------------+--------+        
# +                                             4 4444 4     +  120.00
# |                                         44 4444444444  4 |        
# +                                         44444444●44444   +  100.00
# |                   2                     4  44444444444   |        
# +                   2  22                        4   4     +   80.00
# |                22222222222 2                             |        
# +                2 222●2222                                +   60.00
# +                   222222 2                               +   40.00
# |                 11                                       |        
# +              11111111 111111111 1                        +   20.00
# | 5555533       111111 ● 11111111111                       |        
# +555●5●333               1 111111  1                       +    0.00
# |  53333                      1                            |        
# +--------------+----------------+-----------------+--------+        
#                0.00             50.00             100.00
```

-------

## Control parameters (named arguments)

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
# +--------------+----------------+-----------------+--------+        
# +                                             o oooo o     +  120.00
# |                                          o oooooooo o  o |        
# +                                          ooooooooooooo   +  100.00
# |                    ®                    o  ooooooooooo   |        
# +                   ®  ® ®                       o   o     +   80.00
# |                ®®®®®®®®®®® ®                             |        
# +                ® ®®®®®®®®                                +   60.00
# +                   ®®®®®® ®                               +   40.00
# |                 ®®                                       |        
# +              ®®®®®®®® ®®®®®®®®® ®                        +   20.00
# | *******       ®®®®®®®  ®®®®®®®®®®®                       |        
# +*********               ®®®®®®®®  ®                       +    0.00
# |  *****                      ®                            |        
# +--------------+----------------+-----------------+--------+        
#                0.00             50.00             100.00            
# 
#                  distance function: Cosine                  
# +--------------+----------------+---------------+----------+        
# |                                                          |        
# +                                           ®®®®®®®®®®     +  120.00
# +                                         ®®®®®®®®®®®®® ®  +  100.00
# |                                        ®® ®®®®®®®®®®®    |        
# +                   o o o                     ®®®  ®®      +   80.00
# |                ooooooooo oo                              |        
# +               ooooooooooo                                +   60.00
# +                 oooooooo®                                +   40.00
# |                ooo                                       |        
# +              oooooo®® ®®®®®®®®®®                         +   20.00
# | ********      ooo®®®   ®®®®®®®®®®                        |        
# +********               ®®®®®®®®  ®                        +    0.00
# |    **                                                    |        
# +--------------+----------------+---------------+----------+        
#                0.00             50.00           100.00
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
# +                                             *  *****     +  120.00
# |                                          * **********  * |        
# +                                          *************   +  100.00
# |                    o                     *  **********   |        
# +                    ooooo                           *     +   80.00
# +                 ooooooooooo o                            +   60.00
# |                 oooooooooo                               |        
# +                     oo   o                               +   40.00
# |               ooooooo        o                           |        
# +               oooooooo ooooooooooo                       +   20.00
# |  oooooooo      oooo o   oooooooooo                       |        
# +  ooooooo                  ooooo                          +    0.00
# +     o                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.1                   
# +---------------+----------------+----------------+--------+        
# +                                             o  ooooo     +  120.00
# |                                          o oooooooooo  o |        
# +                                          ooooooooooooo   +  100.00
# |                    *                     o  oooooooooo   |        
# +                    *****                           o     +   80.00
# +                 *********** *                            +   60.00
# |                 **********                               |        
# +                     **   *                               +   40.00
# |               *******        *                           |        
# +               ******** ***********                       +   20.00
# |  ********      **** *   **********                       |        
# +  *******                  *****                          +    0.00
# +     *                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                    learning-parameter:0.7                   
# +--------------+----------------+----------------+---------+        
# |                                                          |        
# +                                           oooooooooo     +  120.00
# +                                         ooooooooooooo o  +  100.00
# |                                        oo ooooooooooo    |        
# +                   o ooo                     ooo  oo      +   80.00
# |                ooooooooo o o                             |        
# +                o oooooooo                                +   60.00
# +                  oooooooo                                +   40.00
# |                 oo                                       |        
# +              **oooooo oooooooooo                         +   20.00
# | ****** *      ***ooo   oooooooooo                        |        
# + *******                o ooooo  o                        +    0.00
# |    **                                                    |        
# +--------------+----------------+----------------+---------+        
#                0.00             50.00            100.00
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
# +---------------+---------------+----------------+---------+        
# |                                                          |        
# |                                            ooooooooo     |        
# +                                         ooooooooooooo o  +  100.00
# |                                         o oooooooooooo   |        
# |                    * * *                      oo  oo     |        
# |                 *********o o                             |        
# +                * ********                                +   50.00
# |                   *****o o                               |        
# |               *****         o                            |        
# |               ******* ooooooooooo                        |        
# | *********      *****   oooooooooo                        |        
# + ********               o ooooo                           +    0.00
# |    **                                                    |        
# +---------------+---------------+----------------+---------+        
#                 0.00            50.00            100.00             
# 
#                       maximum steps: 4                      
# +---------------+----------------+----------------+--------+        
# +                                             *  *****     +  120.00
# |                                          * **********  * |        
# +                                          *************   +  100.00
# |                    o                     *  **********   |        
# +                    ooooo                           *     +   80.00
# +                 ooooooooooo o                            +   60.00
# |                 oooooooooo                               |        
# +                     oo   o                               +   40.00
# |               ooooooo        o                           |        
# +               oooooooo ooooooooooo                       +   20.00
# |  oooooooo      oooo o   oooooooooo                       |        
# +  ooooooo                  ooooo                          +    0.00
# +     o                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      maximum steps: 100                     
# +---------------+----------------+----------------+--------+        
# +                                             *  *****     +  120.00
# |                                          * **********  * |        
# +                                          *************   +  100.00
# |                    o                     *  **********   |        
# +                    ooooo                           *     +   80.00
# +                 ooooooooooo o                            +   60.00
# |                 oooooooooo                               |        
# +                     oo   o                               +   40.00
# |               ooooooo        o                           |        
# +               oooooooo ooooooooooo                       +   20.00
# |  oooooooo      oooo o   oooooooooo                       |        
# +  ooooooo                  ooooo                          +    0.00
# +     o                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

### Minimum reassignments fraction

The value `m` of the option "min-reassignments-fraction" is used in the stopping criteria of the implemented K-means algorithm -- 
if in the last iteration step the fraction of the number of points that have changed clusters is less m then the algorithms stops. 
Here is example that shows better clustering results is obtained with a smaller fraction:

```perl6
(0.01, 0.3).map({ say find-clusters(@data2D5, 3, min-reassigments-fraction => $_).&text-list-plot(title => 'min-reassigments-fraction: ' ~ $_.Str, point-char=>Whatever), "\n" });
```
```
# min-reassigments-fraction: 0.01               
# +---------------+----------------+----------------+--------+        
# +                                             *  *****     +  120.00
# |                                          * **********  * |        
# +                                          *************   +  100.00
# |                    □                     * ***********   |        
# +                    □ □□□                       *   *     +   80.00
# |                 □□□□□□□□□□□ □                            |        
# +                 □□□□□□□□□□                               +   60.00
# +                   □ □□□□□□                               +   40.00
# |                  ❍❍❍         □                           |        
# +               ❍❍❍❍❍❍❍❍ ❍❍❍❍❍❍❍❍❍❍                        +   20.00
# |  ❍❍❍❍❍❍❍❍      ❍❍❍❍❍❍   ❍❍❍❍❍❍❍❍❍❍                       |        
# +  ❍❍❍❍❍❍❍                ❍ ❍❍❍❍❍  ❍                       +    0.00
# |     ❍❍                                                   |        
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                min-reassigments-fraction: 0.3               
# +--------------+----------------+-----------------+--------+        
# +                                             ❍ ❍❍❍❍ ❍     +  120.00
# |                                          ❍ ❍❍❍❍❍❍❍❍ ❍  ❍ |        
# +                                          ❍❍❍❍❍❍❍❍❍❍❍❍❍   +  100.00
# |                    *                    ❍  ❍❍❍❍❍❍❍❍❍❍❍   |        
# +                   *  * *                       ❍   ❍     +   80.00
# |                *********** *                             |        
# +                * ********                                +   60.00
# +                   ****** *                               +   40.00
# |                 **                                       |        
# +              ******** ********* *                        +   20.00
# | □□□□□□□       *******  ***********                       |        
# +□□□□□□□□□               ********  *                       +    0.00
# |  □□□□□                      *                            |        
# +--------------+----------------+-----------------+--------+        
#                0.00             50.00             100.00
```

### Precision goal

The value `p` of the named argument `precision-goal` is used specify in stopping criteria that evaluates 
the differences between the "old" and "new" clusters centers -- 
id the maximum of that difference is less than `1 ** (-p)` then the cluster finding iterations stop. 
Here is example that shows using the different precision goals:

```perl6
(0.2, 5).map({ say find-clusters(@data2D5, 2, precision-goal => $_).&text-list-plot(title => 'precision goal: ' ~ $_.Str, point-char=>Whatever), "\n" });
```
```
# precision goal: 0.2                     
# +---------------+----------------+----------------+--------+        
# +                                             □  □□□□□     +  120.00
# |                                          □ □□□□□□□□□□  □ |        
# +                                          □□□□□□□□□□□□□   +  100.00
# |                    *                     □  □□□□□□□□□□   |        
# +                    *****                           □     +   80.00
# +                 *********** *                            +   60.00
# |                 **********                               |        
# +                     **   *                               +   40.00
# |               *******        *                           |        
# +               ******** ***********                       +   20.00
# |  ********      **** *   **********                       |        
# +  *******                  *****                          +    0.00
# +     *                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00            
# 
#                      precision goal: 5                      
# +---------------+----------------+----------------+--------+        
# +                                             *  *****     +  120.00
# |                                          * **********  * |        
# +                                          *************   +  100.00
# |                    □                     *  **********   |        
# +                    □□□□□                           *     +   80.00
# +                 □□□□□□□□□□□ □                            +   60.00
# |                 □□□□□□□□□□                               |        
# +                     □□   □                               +   40.00
# |               □□□□□□□        □                           |        
# +               □□□□□□□□ □□□□□□□□□□□                       +   20.00
# |  □□□□□□□□      □□□□ □   □□□□□□□□□□                       |        
# +  □□□□□□□                  □□□□□                          +    0.00
# +     □                                                    +  -20.00
# +---------------+----------------+----------------+--------+        
#                 0.00             50.00            100.00
```

-------

## Implementation considerations

### UML diagram

Here is a UML diagram that shows package's structure:

![](./resources/class-diagram.png)


The
[PlantUML spec](./resources/class-diagram.puml)
and
[diagram](./resources/class-diagram.png)
were obtained with the CLI script `to-uml-spec` of the package "UML::Translators", [AAp6].

Here we get the [PlantUML spec](./resources/class-diagram.puml):

```shell
to-uml-spec ML::AssociationRuleLearning > ./resources/class-diagram.puml
```

Here get the [diagram](./resources/class-diagram.png):

```shell
to-uml-spec ML::Clustering | java -jar ~/PlantUML/plantuml-1.2022.5.jar -pipe > ./resources/class-diagram.png
```

**Remark:** Maybe it is a good idea to have an abstract class named, say,
`ML::Clustering::AbstractFinder` that is a parent of
`ML::Clustering::KMeans`, `ML::Clustering::KMedoids`, `ML::Clustering::BiSectionalKMeans`, etc.,
but I have not found to be necessary. (At this point of development.)

**Remark:** It seems it is better to have a separate package for the distance functions, named, say,
"ML::DistanceFunctions". (Although distance functions are not just for ML...)
After thinking over package and function names I will make such a package. 

-------

## TODO

- [ ] Implement Bi-sectional K-means algorithm, [AAp1].

- [ ] Implement K-medoids algorithm.

- [ ] Automatic determination of the number of clusters.

- [ ] Allow data points to be `Pair` objects the keys of which are point labels.

   - Hence, the returned clusters consist of those labels, not points themselves.

- [ ] Implement Agglomerate algorithm.

- [ ] Factor-out the distance functions in a separate package.

-------

## References

### Articles

[Wk1] Wikipedia entry, ["Cluster Analysis"](https://en.wikipedia.org/wiki/Cluster_analysis).

[AA1] Anton Antonov,
["Introduction to data wrangling with Raku"](https://rakuforprediction.wordpress.com/2021/12/31/introduction-to-data-wrangling-with-raku/),
(2021),
[RakuForPrediction at WordPress](https://rakuforprediction.wordpress.com).

### Packages

[AAp1] Anton Antonov,
[Bi-sectional K-means algorithm in Mathematica](https://github.com/antononcube/MathematicaForPrediction/blob/master/BiSectionalKMeans.m),
(2020),
[MathematicaForPrediction at GitHub/antononcube](https://github.com/antononcube/MathematicaForPrediction/).

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
