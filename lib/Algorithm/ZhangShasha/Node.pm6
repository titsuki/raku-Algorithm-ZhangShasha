use v6.c;

unit class Algorithm::ZhangShasha::Node:ver<0.0.3>:auth<cpan:TITSUKI>;

has Str $.content;
has Algorithm::ZhangShasha::Node @.children;

method add-child(Algorithm::ZhangShasha::Node $child --> ::?CLASS) {
    @!children.push: $child;
    self;
}
