use v6.c;
use Test;
use Algorithm::ZhangShasha;
use DOM::Tiny;

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

subtest "Test Algorithm::ZhangShasha::Node" => sub {

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

    is $tree1.size, 6;
    is $tree2.size, 6;
    is $tree1.lr-keyroots, (3,5,6);
    is $tree2.lr-keyroots, (2,5,6);
    is $tree1.tree-distance($tree2).key, 2;
    is $tree1.td, $((0,1,2,3,1,5), (1,0,2,3,1,5), (2,1,2,2,2,4), (3,3,1,2,4,4), (1,1,3,4,0,5), (5,5,3,3,5,2)), "The tree distance table should be same as FIG. 8 in the paper";
$*ERR.say: $tree1.ops[5;5];
    my enum OPS <DELETE INSERT REPLACE KEEP>;
    is $tree1.ops[5;5].map(*.<op>).grep(KEEP).elems, 5;
    is $tree1.ops[5;5].map(*.<op>).grep(DELETE).elems, 1;
    is $tree1.ops[5;5].map(*.<op>).grep(INSERT).elems, 1;
}

my class DOMHelper does Algorithm::ZhangShasha::Helpable[DOM::Tiny] {
    method delete-cost(DOM::Tiny $this --> Int) {
	1;
    }

    method insert-cost(DOM::Tiny $another --> Int) {
	1;
    }

    method replace-cost(DOM::Tiny $this, DOM::Tiny $another --> Int) {
	$another.tag eq $this.tag ?? 0 !! 1;
    }

    method children(DOM::Tiny $node) {
	$node.children
    }
}

subtest "Test DOM::Tiny" => sub {
    my $dom1 = DOM::Tiny.parse('<div><p id="a">Test</p><p id="b">123</p></div>');
    my Algorithm::ZhangShasha::Tree[DOM::Tiny] $tree1 .= new(:root($dom1.root[0]), :helper(DOMHelper.new));
    my $dom2 = DOM::Tiny.parse('<div><p id="a">Test<a href="http://example.com"></a></p><p id="b">123</p></div>');
    my Algorithm::ZhangShasha::Tree[DOM::Tiny] $tree2 .= new(:root($dom2.root[0]), :helper(DOMHelper.new));
    is $tree1.size, 3;
    is $tree2.size, 4;
    is $tree1.lr-keyroots, (2,3);
    is $tree2.lr-keyroots, (3,4);
    is $tree1.tree-distance($tree2).key, 1;
}

done-testing;
