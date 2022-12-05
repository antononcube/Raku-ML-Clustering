# Raku ML::Clustering

[![SparkyCI](https://ci.sparrowhub.io/project/gh-antononcube-Raku-ML-Clustering/badge)](https://ci.sparrowhub.io)
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

```shell
zef install ML::Clustering
```

From GitHub:

```shell
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
# +------------------------------+-----------------------------+
# | 1                            | 0                           |
# +------------------------------+-----------------------------+
# | Min    => 2.3898838030195453 | Min    => 2.304900205776566 |
# | 1st-Qu => 5.706881157103716  | 1st-Qu => 5.736769825514594 |
# | Mean   => 7.784565074436171  | Mean   => 8.02083978767615  |
# | Median => 8.324205488000889  | Median => 9.333349983753054 |
# | 3rd-Qu => 9.667770938027495  | 3rd-Qu => 9.951571353489859 |
# | Max    => 12.366646976770186 | Max    => 11.87813636253523 |
# +------------------------------+-----------------------------+
```

Here we plot the points:

```perl6
use Text::Plot;
text-list-plot(@data3)
```
```
# +-+----------+----------+---------+----------+----------+--+       
# |                                                          |       
# +                                        *    *            +  12.00
# |                                         **** * *         |       
# +                                     * * *** ** *     *   +  10.00
# |                                    *  * *  **  *   **    |       
# +                                *   *      **** *   *     +   8.00
# |                                         * ** *           |       
# |       *     *     * *                                    |       
# +   *  ***         *    *      *                           +   6.00
# |   *     * **      * * *      *    *                      |       
# +           *            *                                 +   4.00
# |        *         *   *                                   |       
# +                                                          +   2.00
# +-+----------+----------+---------+----------+----------+--+       
#   2.00       4.00       6.00      8.00       10.00      12.00
```

**Problem:** Group the points in such a way that each group has close (or similar) points.

Here is how we use the function `find-clusters` to give an answer:

```perl6
use ML::Clustering;
my %res = find-clusters(@data3, 2, prop => 'All');
%res<Clusters>>>.elems
```
```
# (31 49)
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
# ((7.739550750023431 7.869526528329702) (7.436113407675195 5.047068255152369) (3.137868648226576 6.18246060543501))
# ((10.196518357205878 10.291337792828818) (9.514778751211171 10.904815191998523) (10.118479992486252 8.418809517175601))
```

Here are the centers of the clusters (the mean points):

```perl6
%res<MeanPoints>
```
```
# [(10.013273073426063 9.513630351537644) (5.805077424361722 6.072817033230708)]
```

We can verify the result by looking at the plot of the found clusters:

```perl6
text-list-plot((|%res<Clusters>, %res<MeanPoints>), point-char => <▽ ☐ ●>, title => '▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers')
```
```
# ▽ - 1st cluster; ☐ - 2nd cluster; ● - cluster centers    
# ++----------+-----------+----------+----------+-----------++       
# |                                         ☐                |       
# +                                              ☐           +  12.00
# |                                          ☐☐☐☐ ☐ ☐        |       
# +                                      ☐ ☐ ☐☐☐☐☐ ☐ ☐   ☐ ☐ +  10.00
# |                                    ☐☐  ☐ ☐  ●☐   ☐   ☐   |       
# +                                 ▽   ☐      ☐☐☐☐  ☐   ☐   +   8.00
# |                                          ☐ ☐☐☐☐          |       
# |      ▽      ▽     ▽ ▽●                                   |       
# +  ▽   ▽▽          ▽    ▽      ▽                           +   6.00
# |        ▽  ▽▽      ▽ ▽  ▽     ▽▽    ▽                     |       
# +  ▽        ▽       ▽    ▽                                 +   4.00
# |        ▽             ▽                                   |       
# +                  ▽                                       +   2.00
# ++----------+-----------+----------+----------+-----------++       
#  2.00       4.00        6.00       8.00       10.00       12.00
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
# ++---------------+--------------+---------------+----------+        
# |                                                          |        
# |                                          *  **  **       |        
# |                                       *  *************   |        
# +                                         **************   +  100.00
# |                      *                   * ** * ***      |        
# |                  *********                       *       |        
# |                 ***********                              |        
# +                    ****                                  +   50.00
# |                *******    **                             |        
# |               ******************                         |        
# +    ******         **   **********                        +    0.00
# |   *******                 * **                           |        
# |                                                          |        
# ++---------------+--------------+---------------+----------+        
#  -50.00          0.00           50.00           100.00
```

Here we find clusters and plot them together with their mean points:

```perl6
srand(32);
my %clRes = find-clusters(@data2D5, 5, prop=>'All');
text-list-plot([|%clRes<Clusters>, %clRes<MeanPoints>], point-char=><1 2 3 4 5 ●>)
```
```
# +---------------+---------------+----------------+---------+        
# |                                                4         |        
# |                                          4   44444 44    |        
# +                                        4 444444●44444444 +  100.00
# |                                           444444444444   |        
# |                     3                        4  444 4    |        
# |                 3333333333                               |        
# |                33333●33333                               |        
# +                   333333                                 +   50.00
# |                22222      1                              |        
# |              2222●222221 111111                          |        
# |  555555       22222222 1111●1111                         |        
# + 5555●555               11111111 1                        +    0.00
# |5  5 555                                                  |        
# +---------------+---------------+----------------+---------+        
#                 0.00            50.00            100.00
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
