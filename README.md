
<!-- README.md is generated from README.Rmd. Please edit that file -->

# slash <a><img src='man/figures/slash.png' align="right" height="200" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/feddelegrand7/slash/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/feddelegrand7/slash/actions/workflows/R-CMD-check.yaml)
[![R
badge](https://img.shields.io/badge/Build%20with-♥%20and%20R-blue)](https://github.com/feddelegrand7/rlowdb)
[![Codecov test
coverage](https://codecov.io/gh/feddelegrand7/slash/branch/main/graph/badge.svg)](https://app.codecov.io/gh/feddelegrand7/slash?branch=main)
[![CRAN
status](https://www.r-pkg.org/badges/version/slash)](https://CRAN.R-project.org/package=slash)
<!-- badges: end -->

The goal of slash is to provide a hierarchical key-value store where
elements can be accessed and modified using simple path-like strings,
such as `"cars/1/model"` or `"garage/vw/golf/color"`.

It supports:

- Named and unnamed lists
- Nested access with `/` paths
- Optional strict mode
- List path enumeration
- Full get/set/delete API

## Installation

You can install `slash` from `CRAN` with:

``` r
install.packages("slash")
```

You can install the development version of `slash` like so:

``` r
devtools::install_github("feddelegrand7/slash")
```

## Getting elements from a `list`

Consider the following `list` object:

``` r
cars_list <- list(
  cars = list(
    list(manufacturer = "VW", model = "Golf V", year = 2005),
    list(manufacturer = "Toyota", model = "Corolla", year = 2010),
    list(manufacturer = "Tesla", model = "Model S", year = 2022)
  )
)
```

If one wants to access the `manufacturer` element, one can do:

``` r
cars_list$cars[[1]]$manufacturer
#> [1] "VW"
```

Using `slash`, you can access the same element using a `file-path`
syntax:

``` r
library(slash)

sl <- slash$new(data = cars_list)

sl$get(path = "cars/1/manufacturer")
#> [1] "VW"
```

`slash` can operate on unnamed elements like above and/or on named
elements like the following:

``` r
garage <- list(
  vw = list(
    golf = list(year = 2005, color = "black"),
    passat = list(year = 2011)
  ),
  toyota = list(
    corolla = list(year = 2010)
  )
)
```

Let’s say we want to access the color of the **VW Golf**. While in
standard `R` one can do:

``` r
garage$vw$golf$color
#> [1] "black"
```

Using `slash`, we can operate as the following:

``` r
sl <- slash$new(data = garage)
sl$get("vw/golf/color")
#> [1] "black"
```

If now, for example, we would want to access all the properties of the
`Golf` car, we would do:

``` r
sl <- slash$new(data = garage)
sl$get("vw/golf")
#> $year
#> [1] 2005
#> 
#> $color
#> [1] "black"
```

It is possible to return the whole list if needed using the `get_all`
method:

``` r
sl$get_all()
#> $vw
#> $vw$golf
#> $vw$golf$year
#> [1] 2005
#> 
#> $vw$golf$color
#> [1] "black"
#> 
#> 
#> $vw$passat
#> $vw$passat$year
#> [1] 2011
#> 
#> 
#> 
#> $toyota
#> $toyota$corolla
#> $toyota$corolla$year
#> [1] 2010
```

You’ll also get the whole `list` element when `NULL` (the default) is
provided to the `get` method:

``` r
sl$get(NULL)
#> $vw
#> $vw$golf
#> $vw$golf$year
#> [1] 2005
#> 
#> $vw$golf$color
#> [1] "black"
#> 
#> 
#> $vw$passat
#> $vw$passat$year
#> [1] 2011
#> 
#> 
#> 
#> $toyota
#> $toyota$corolla
#> $toyota$corolla$year
#> [1] 2010
```

If you try to access an element that does not exist, you’ll get a `NULL`
as the returned value:

``` r
sl$get("vw/polo")
#> NULL
```

You can change this behavior and get an `error` back when an element is
not found using the `strict` parameter. You can set the parameter at the
initialization of the instance:

``` r
sl <- slash$new(data = garage, strict = TRUE)
```

or afterward, using the `set_strict` method:

``` r
sl$set_strict(strict = TRUE)
```

This way, we get an `error` back when an element is not found:

``` r
sl$get("vw/polo")
#> Error in sl$get("vw/polo"): Element at path 'vw/polo' does not exist
```

## Setting elements in a `list`

You can change the value of an element or add a new element within a
list using the `set` method, suppose I want to add a new car to my
previous list:

``` r
sl$set(path = "vw/polo/year", value = 2013)
sl$set(path = "vw/polo/color", value = "Steelblue")

sl$get("vw")
#> $golf
#> $golf$year
#> [1] 2005
#> 
#> $golf$color
#> [1] "black"
#> 
#> 
#> $passat
#> $passat$year
#> [1] 2011
#> 
#> 
#> $polo
#> $polo$year
#> [1] 2013
#> 
#> $polo$color
#> [1] "Steelblue"
```

Now, if you want to modify the year from `2013` to `2023` for example,
you can do:

``` r
sl$set(path = "vw/polo/year", value = 2023)
sl$get("vw")
#> $golf
#> $golf$year
#> [1] 2005
#> 
#> $golf$color
#> [1] "black"
#> 
#> 
#> $passat
#> $passat$year
#> [1] 2011
#> 
#> 
#> $polo
#> $polo$year
#> [1] 2023
#> 
#> $polo$color
#> [1] "Steelblue"
```

You can even build your list element from scrath:

``` r
sl <- slash$new()
sl$get()
#> list()
```

``` r
sl$set("vw/golf/year", value = 2005)
sl$set("vw/golf/color", value = "black")
sl$set("vw/passat/year", value = 2011)
sl$set("vw/polo/year", value = "Steelblue")
sl$set("vw/polo/color", value = 2023)

sl$get("vw")
#> $golf
#> $golf$year
#> [1] 2005
#> 
#> $golf$color
#> [1] "black"
#> 
#> 
#> $passat
#> $passat$year
#> [1] 2011
#> 
#> 
#> $polo
#> $polo$year
#> [1] "Steelblue"
#> 
#> $polo$color
#> [1] 2023
```

## Deleting an element from the `list`

You can delete an element using the `delete` method, suppose we don’t
need the `polo` car element anymore, we could do:

``` r
sl$delete("vw/polo")
sl$get("vw")
#> $golf
#> $golf$year
#> [1] 2005
#> 
#> $golf$color
#> [1] "black"
#> 
#> 
#> $passat
#> $passat$year
#> [1] 2011
```

You can delete at any level on the list, for example if we want to
delete the `color` field of the `golf` element, we could do:

``` r
sl$delete("vw/golf/color")
sl$get("vw")
#> $golf
#> $golf$year
#> [1] 2005
#> 
#> 
#> $passat
#> $passat$year
#> [1] 2011
```

## Listing the available paths

If you want to list the available paths of your `list` object, you can
call the `list_paths()` method:

``` r
sl$list_paths()
#> [1] "vw"             "vw/golf"        "vw/golf/year"   "vw/passat"     
#> [5] "vw/passat/year"
```

## Check if an element exists:

Use the `exists` method to check if a particular path exists:

``` r
sl$exists("vw")
#> [1] TRUE
sl$exists("vw/golf")
#> [1] TRUE
sl$exists("vw/golf/color")
#> [1] FALSE
sl$exists("porshe/911")
#> [1] FALSE
```

## Printing a `slash` object

A `slash` object has a particular `print` method attached to it, it
prints a nice view of the available paths among other information
(`strict mode`):

``` r
sl
#> slash object (non-strict mode)
#> Use $get() or $get_all() to view contents
#> Available Paths:
#> - vw
#> - vw/golf
#> - vw/golf/year
#> - vw/passat
#> - vw/passat/year
```

## Printing the `list` object

Each `slash` object is build on top of a `list` object, if you want to
print the `list` it-self, use the `print_list` method:

``` r
sl$print_list()
#> list(vw = list(golf = list(year = 2005), passat = list(year = 2011)))
```

## Printing a `Tree` representation

You can print a `Tree` representation of your `slash` object and its
underlying list using the `print_tree` method:

``` r
sl$print_tree()
#> <root> 
#> └── vw
#>     ├── golf
#>     │   └── year: 2005
#>     └── passat
#>         └── year: 2011
```

``` r
# Adding the 208 peugeot model
# Make sure to quote the `208`, otherwise slash will 
# understand it as indices (Not name)

sl$set("peugeot/`208`/year", 2013)

sl$print_tree()
#> <root> 
#> ├── vw
#> │   ├── golf
#> │   │   └── year: 2005
#> │   └── passat
#> │       └── year: 2011
#> └── peugeot
#>     └── `208`
#>         └── year: 2013
```

``` r
sl$print_tree("peugeot")
#> peugeot 
#> └── `208`
#>     └── year: 2013
```

``` r
sl$set("peugeot/`208`/energy/class", "Diesel")
sl$print_tree("peugeot/`208`/energy")
#> peugeot/`208`/energy 
#> └── class: Diesel
```

## Code of Conduct

Please note that the slash project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
