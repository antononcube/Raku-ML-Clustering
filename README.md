# Raku ML::Clustering

[![MacOS](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/macos.yml/badge.svg)](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/macos.yml)
[![Linux](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/linux.yml/badge.svg)](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/linux.yml)
[![Win64](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/windows.yml/badge.svg)](https://github.com/antononcube/Raku-ML-Clustering/actions/workflows/windows.yml)
[![https://raku.land/zef:antononcube/ML::Clustering](https://raku.land/zef:antononcube/ML::Clustering/badges/version)](https://raku.land/zef:antononcube/ML::Clustering)
[![License: Artistic-2.0](https://img.shields.io/badge/License-Artistic%202.0-0298c3.svg)](https://opensource.org/licenses/Artistic-2.0)

This repository has the code of a Raku package for
Machine Learning (ML)
[Clustering (or Cluster analysis)](https://en.wikipedia.org/wiki/Cluster_analysis)
functions, [Wk1].

The Clustering framework includes:

- The algorithms 
  [K-means](https://en.wikipedia.org/wiki/K-means_clustering) 
  and 
  [K-medoids](https://en.wikipedia.org/wiki/K-medoids), 
  and others

- The distance functions Euclidean, Cosine, Hamming, Manhattan, and others,
  and their corresponding similarity functions

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

```
zef install ML::Clustering
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-ML-Clustering
```

-------

## Usage example

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
# | 0                            | 1                            |
# +------------------------------+------------------------------+
# | Min    => 1.9418286393831807 | Min    => 2.5537453527288423 |
# | 1st-Qu => 5.23355791998377   | 1st-Qu => 5.802659698503382  |
# | Mean   => 7.812329106122415  | Mean   => 8.221053043444616  |
# | Median => 8.529233471757092  | Median => 8.859544342245552  |
# | 3rd-Qu => 9.74722507929462   | 3rd-Qu => 10.392817343154189 |
# | Max    => 12.161509848446896 | Max    => 11.851232468041157 |
# +------------------------------+------------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data3)
```
```
# +---+---------+---------+---------+---------+---------+----+       
# +                                                          +  12.00
# |                                    *  *  *        *      |       
# |                                 ****  * ** **   ***      |       
# +                                   * *   ** **        *   +  10.00
# |                                   *   ****   **          |       
# +                                  *    *  *        *      +   8.00
# |      *       *         *                                 |       
# +      *   *        *   **                                 +   6.00
# |          * ** ****    *         *                        |       
# |   *          *  *    *                                   |       
# +             **   **        *                             +   4.00
# |         *                 *                              |       
# +                                                          +   2.00
# +---+---------+---------+---------+---------+---------+----+       
#     2.00      4.00      6.00      8.00      10.00     12.00
```

**Problem:** Group the points in such a way that each group has close (or similar) points.

Here is how we use the function `find-clusters` to give an answer:

```perl6
use ML::Clustering;
my %res = find-clusters(@data3, 2, prop => 'All');
%res<Clusters>>>.elems
```
```
# (30 50)
```

**Remark:** The first argument is data points that is a list-of-numeric-lists. 
The second argument is a number of clusters to be found. 
(It is in the TODO list to have the number clusters automatically determined -- currently they are not.)  

**Remark:** The function `find-clusters` can return results of different types controlled with the named argument "prop".
Using `prop => 'All'` returns a hash with all properties of the cluster finding result.

Here are sample points from each found cluster:

```perl6
.say for %res<Clusters>>>.pick(3);
```
```
# ((6.8442730684339805 2.5537453527288423) (5.988371242806578 6.690825577391333) (3.9052242620581974 5.826205768330279))
# ((10.302490764954882 10.91125277165973) (8.821337333605817 9.715938302825638) (8.278089768928224 8.666124184959127))
```

Here are the centers of the clusters (the mean points):

```perl6
%res<MeanPoints>
```
```
# [(4.693753655533249 4.977193937166397) (9.411502770521118 9.768925531106525)]
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot((|%res<Clusters>, %res<MeanPoints>), point-char => <▽ ☐ ●>, title => '▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers    
# +--+----------+---------+----------+---------+----------+--+       
# +                                     ☐                    +  12.00
# |                                   ☐    ☐ ☐☐ ☐☐    ☐ ☐    |       
# |                                 ☐ ☐☐☐    ☐☐ ☐    ☐  ☐    |       
# +                                   ☐☐ ☐  ●☐☐ ☐☐         ☐ +  10.00
# |                                   ☐    ☐☐ ☐   ☐☐         |       
# +              ▽                    ☐    ☐  ☐        ☐     +   8.00
# |     ▽                  ▽                                 |       
# +     ▽   ▽         ▽   ▽▽                                 +   6.00
# |         ▽ ▽▽ ▽ ▽▽     ▽          ▽                       |       
# |  ▽           ▽ ●▽    ▽                                   |       
# +            ▽ ▽  ▽ ▽         ▽                            +   4.00
# |                                                          |       
# +        ▽                   ▽                             +   2.00
# +--+----------+---------+----------+---------+----------+--+       
#    2.00       4.00      6.00       8.00      10.00      12.00
```

**Remark:** By default `find-clusters` uses the K-means algorithm. The functions `k-means` and `k-medoids`
call `find-clusters` with the option settings `method=>'K-means'` and `method=>'K-medoids'` respectively.

------

## More interesting looking data

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
# +---------------+---------------+---------------+----------+        
# |                                                          |        
# |                                            ***** ***     |        
# +                                        ***************   +  100.00
# |                                         **************   |        
# |                    * *  *                   ***          |        
# |                 ***********                              |        
# +                 ***********                              +   50.00
# |                  ***  * *                                |        
# |                 *****                                    |        
# |               *******  *********                         |        
# |   *******       **** * **********                        |        
# +   *******            *  ** ***                           +    0.00
# |                                                          |        
# +---------------+---------------+---------------+----------+        
#                 0.00            50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(32);
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +--------------+-----------------+----------------+--------+        
# +                                             3   33       +  120.00
# |                                            3 33333 5555  |        
# +                                         333333●355●55555 +  100.00
# |                                            3335555555555 |        
# +                   1 11  1                                +   80.00
# |                111111111 11                              |        
# +                11111●111111                              +   60.00
# +                 1 11 11 1                                +   40.00
# |               2 2                                        |        
# +              22222222 22 222222                          +   20.00
# | 444444        2222222 ●2222222222                        |        
# +4444●444              2  222222222                        +    0.00
# | 44444 4                    2                             |        
# +--------------+-----------------+----------------+--------+        
#                0.00              50.00            100.00
```

-------

## Detailed function pages

Detailed parameter explanations and usage examples for the functions provided by the package are given in:

- ["K-means function page"](./doc/K-means-function-page.md)

- ["K-medoids function page"]()

- ["Bi-sectional-K-means function page"]()

-------

## Implementation considerations

### UML diagram

Here is a UML diagram that shows package's structure (in Mermaid-JS):

```shell, output.prompt=NONE, output.lang=mermaid
to-uml-spec ML::Clustering --format=mermaid
```
```mermaid
classDiagram
class k_means {
  <<routine>>
}
k_means --|> Routine
k_means --|> Block
k_means --|> Code
k_means --|> Callable


class find_clusters {
  <<routine>>
}
find_clusters --|> Routine
find_clusters --|> Block
find_clusters --|> Code
find_clusters --|> Callable


class ML_Clustering_KMeans {
  +BUILDALL()
  +args-check()
  +bray-curtis-distance()
  +canberra-distance()
  +chessboard-distance()
  +cosine-distance()
  +euclidean-distance()
  +find-clusters()
  +get-distance-function()
  +hamming-distance()
  +known-distance-function-specs()
  +manhattan-distance()
  +norm()
  +squared-euclidean-distance()
}
ML_Clustering_KMeans --|> Math_DistanceFunctionish
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

- [X] DONE Factor-out the distance functions in a separate package.

- [ ] TODO Implement Bi-sectional K-means algorithm, [AAp1].

- [ ] TODO Implement K-medoids algorithm.

- [ ] TODO Automatic determination of the number of clusters.

- [ ] TODO Allow data points to be `Pair` objects the keys of which are point labels.

   - Hence, the returned clusters consist of those labels, not points themselves.

- [ ] TODO Implement Agglomerate algorithm.

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
