use v6.c;
unit role Algorithm::ZhangShasha::Tree:ver<0.0.1>:auth<cpan:TITSUKI>[::NodeT];

has NodeT $.root;
has @!idx2node;
has Int $.size;
has @.td;
has @.ops;
has @.children;
has $!count;
has $!helper;

submethod BUILD(NodeT :$!root!, :$!helper!) {
    $!size = self.traverse2($!root);
    $!count = 1;
    self.traverse($!root);
}

method get-node(Int $idx) {
    @!idx2node[$idx];
}

method get-left-most-node($idx --> Int) {
    my $current = $idx;
    while @!children[$current] > 0 {
	$current = @!children[$current].clone.shift;
    }
    $current;
}

method traverse2(NodeT $parent --> Int) {
    if $!helper.children($parent).elems == 0 {
        return 1;
    }
    my $ret = 1;
    for $!helper.children($parent) -> $child {
        $ret += self.traverse2($child);
    }
    $ret;
}

method traverse(NodeT $parent) {
    my @tmp-children;
    for $!helper.children($parent) -> $child {
        @tmp-children.append: self.traverse($child);
    }
    @!idx2node[$!count] = $parent;
    @!children[$!count] = @tmp-children;
    $!count++;
}

method lr-keyroots(--> List) {
    my Bool @same-l;
    my Int @keyroots;
    for @(1..self.size).reverse -> $idx {
	my $node-i = self.get-left-most-node($idx);
        if @same-l[$node-i]:!exists {
            @keyroots.unshift: $idx;
        }
        @same-l[$node-i] = True;
    }
    @keyroots;
}

method tree-distance(Algorithm::ZhangShasha::Tree $another --> Pair) {
    my @td[self.size;$another.size];
    @td[.[0];.[1]] = Inf for ^(self.size) X ^($another.size);
    @!td := @td;
    
    for self.lr-keyroots -> $i {
        for $another.lr-keyroots -> $j {
            self.forest-distance($i, $j, $another);
        }
    }
    Pair.new(@!td[self.size-1;$another.size-1], @!ops[self.size-1;$another.size-1]);
}

method forest-distance(Int $i, Int $j, Algorithm::ZhangShasha::Tree $another) {
    my enum OPS <DELETE INSERT REPLACE KEEP>;

    my Int $li = self.get-left-most-node($i);
    my Int $lj = $another.get-left-most-node($j);
    my Int $offset-i = $li - 1;
    my Int $offset-j = $lj - 1;

    my @fd[$i-$li+2;$j-$lj+2]; # forest distance
    my @local-ops[$i-$li+2;$j-$lj+2]; # ops

    @fd[0;0] = 0;
    @local-ops[0;0] = [];
    for $li..$i -> $i1 {
        my $idx = $i1 - $li + 1;
        @fd[$idx;0] = @fd[$idx-1;0] + $!helper.delete-cost(self.get-node($i1));
	@local-ops[$idx;0] = @local-ops[$idx-1;0].clone.append: %(op => DELETE, pair => Pair.new($i1,0)).item;
    }

    for $lj..$j -> $j1 {
        my $idx = $j1 - $lj + 1;
        @fd[0;$idx] = @fd[0;$idx-1] + $!helper.insert-cost($another.get-node($j1));
	@local-ops[0;$idx] = @local-ops[0;$idx-1].clone.append: %(op => INSERT, pair => Pair.new(0,$j1)).item;
    }

    for $li .. $i -> $i1 {
        for $lj .. $j -> $j1 {
            my Int $li1 = self.get-left-most-node($i1);
            my Int $lj1 = $another.get-left-most-node($j1);
            my Int $fd-i = $i1 - $li + 1;
            my Int $fd-j = $j1 - $lj + 1;

            if $li1 == $li and $lj1 == $lj {
		my $min = (@fd[$fd-i - 1;$fd-j] + $!helper.delete-cost(self.get-node($i1)),
			   @fd[$fd-i;$fd-j - 1] + $!helper.insert-cost($another.get-node($j1)),
			   @fd[$fd-i - 1;$fd-j - 1] + $!helper.replace-cost(self.get-node($i1), $another.get-node($j1)))\
		.pairs.max: { $^a.value < $^b.value };

                @fd[$fd-i;$fd-j] = $min.value;
		given OPS($min.key) {
		    when DELETE {
			my %op = %(op => OPS($min.key), pair => Pair.new($i1,$j1));
			@local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i - 1;$fd-j] // []) .clone.append: %op.item;
		    }
		    when INSERT {
			my %op = %(op =>OPS($min.key), pair => Pair.new($i1,$j1));
			@local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i;$fd-j - 1] // []) .clone.append: %op.item;
		    }
		    default {
			if @fd[$fd-i - 1;$fd-j - 1] - @fd[$fd-i;$fd-j] == 0 {
			    # TODO: min never contains KEEP
			    my %op = %(op => KEEP, pair => Pair.new($i1,$j1));
			    @local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i - 1;$fd-j - 1] // []) .clone.append: %op.item;
			} else {
			    my %op = %(op => OPS($min.key), pair => Pair.new($i1,$j1));
			    @local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i - 1;$fd-j - 1] // []) .clone.append: %op.item;
			}
		    }
		}
		@!ops[$i1-1;$j1-1] = @local-ops[$fd-i;$fd-j];
                @!td[$i1-1;$j1-1] = @fd[$fd-i;$fd-j];
            } else {
		my $min = (@fd[$fd-i - 1;$fd-j] + $!helper.delete-cost(self.get-node($i1)),
			   @fd[$fd-i;$fd-j - 1] + $!helper.insert-cost($another.get-node($j1)),
			   @fd[$li1-$li;$lj1-$lj] + @!td[$i1-1; $j1-1])\
		.pairs.max: { $^a.value < $^b.value };
		@fd[$fd-i;$fd-j] = $min.value;

		given OPS($min.key) {
		    when DELETE {
			my %op = %(op => OPS($min.key), pair => Pair.new($i1,$j1));
			@local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i - 1;$fd-j] // []) .clone.append: %op.item;
		    }
		    when INSERT {
			my %op = %(op => OPS($min.key), pair => Pair.new($i1,$j1));
			@local-ops[$fd-i;$fd-j] = (@local-ops[$fd-i;$fd-j - 1] // []) .clone.append: %op.item;
		    }
		    default {
			@local-ops[$fd-i;$fd-j] = (@local-ops[$li1-$li;$lj1-$lj] // []) .clone.append: @!ops[$i1-1;$j1-1].flat;
		    }
		}
            }
        }
    }
}

