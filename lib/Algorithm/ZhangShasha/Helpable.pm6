use v6.c;
unit role Algorithm::ZhangShasha::Helpable:ver<0.0.1>:auth<cpan:TITSUKI>[::NodeT];

method delete-cost(NodeT $this --> Int) { ... }
method insert-cost(NodeT $another --> Int) { ... }
method replace-cost(NodeT $this, NodeT $another --> Int) { ... }
method children(NodeT $node) { ... }

