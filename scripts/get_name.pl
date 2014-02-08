use application "common";

my $p = shift;

my $n;
unless(defined($n = $p->name)) {
    $n="<unnamed>";
};

return $n;