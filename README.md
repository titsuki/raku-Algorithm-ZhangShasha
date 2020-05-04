[![Build Status](https://travis-ci.org/titsuki/raku-Algorithm-ZhangShasha.svg?branch=master)](https://travis-ci.org/titsuki/raku-Algorithm-ZhangShasha)

NAME
====

Algorithm::ZhangShasha - Tree edit distance between trees

SYNOPSIS
========

```perl6
use Algorithm::ZhangShasha;

my class SimpleHelper does Algorithm::ZhangShasha::Helpable[Algorithm::ZhangShasha::Node] {
    method delete-cost(Algorithm::ZhangShasha::Node $this --> Int) {
        1;
    }

    method insert-cost(Algorithm::ZhangShasha::Node $another --> Int) {
        1;
    }

    method replace-cost(Algorithm::ZhangShasha::Node $this, Algorithm::ZhangShasha::Node $another --> Int) {
        $another.content eq $this.content ?? 0 !! 1;
    }

    method children(Algorithm::ZhangShasha::Node $node) {
        $node.children
    }
}

my constant $ZN = 'Algorithm::ZhangShasha::Node';

my $root1 = ::($ZN).new(:content("f"))\
                   .add-child(::($ZN).new(:content("d"))\
                                     .add-child(::($ZN).new(:content("a")))\
                                     .add-child(::($ZN).new(:content("c"))\
                                                       .add-child(::($ZN).new(:content("b")))\
                                               )\
                             )\
                   .add-child(::($ZN).new(:content("e")));

my $root2 = ::($ZN).new(:content("f"))\
                   .add-child(::($ZN).new(:content("c"))\
                                     .add-child(::($ZN).new(:content("d"))\
                                                       .add-child(::($ZN).new(:content("a")))\
                                                       .add-child(::($ZN).new(:content("b")))\
                                               )\
                             )\
                   .add-child(::($ZN).new(:content("e")));

my Algorithm::ZhangShasha::Tree[Algorithm::ZhangShasha::Node] $tree1 .= new(:root($root1), :helper(SimpleHelper.new));
my Algorithm::ZhangShasha::Tree[Algorithm::ZhangShasha::Node] $tree2 .= new(:root($root2), :helper(SimpleHelper.new));

say $tree1.tree-distance($tree2).key; # 2
say $tree1.tree-distance($tree2).value; # ({op => KEEP, pair => 1 => 1} {op => KEEP, pair => 2 => 2} {op => DELETE, pair => 3 => 2} {op => KEEP, pair => 4 => 3} {op => INSERT, pair => 4 => 4} {op => KEEP, pair => 5 => 5} {op => KEEP, pair => 6 => 6})
```

DESCRIPTION
===========

Algorithm::ZhangShasha is an implementation for efficiently computing tree edit distance between trees.

METHODS of Algorithm::ZhangShasha::Tree
---------------------------------------

### BUILD

Defined as:

```perl6
submethod BUILD(NodeT :$!root!, Algorithm::ZhangShasha::Helpable :$!helper!)
```

Creates an `Algorithm::ZhangShasha::Tree` instance.

  * `$!root` is the root node of the tree

  * `$!helper` is the helper class that implements four methods: `delete-cost`, `insert-cost`, `replace-cost`, `children`. If you want to combine 3rd-party node representation (e.g., `DOM::Tiny`), you should define a custom helper. (See `t/01-basic.t`. It implements an exmple for `DOM::Tiny`.)

### size

Defined as:

```perl6
method size(--> Int)
```

Returns the size of the tree.

### tree-distance

Defined as:

```perl6
method tree-distance(Algorithm::ZhangShasha::Tree $another --> Pair)
```

Returns a `Pair` instance that has the optimal edit distance and the corresponding operations (e.g., DELETE(3,2)) between the two trees. Where `.key` has the distance and `.value` has the operations.

AUTHOR
======

Itsuki Toyota <titsuki@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2020 Itsuki Toyota

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

This algorithm is from

  * [0] Zhang, Kaizhong, and Dennis Shasha. "Simple fast algorithms for the editing distance between trees and related problems." SIAM journal on computing 18.6 (1989): 1245-1262.

