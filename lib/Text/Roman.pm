package Text::Roman;
# ABSTRACT: Converts Roman digits to integer numbers and the contrary, recognize digits

=head1 SYNOPSIS

    use Text::Roman;

    my $roman = "XXXV";
    my $mroman = 'L_X_XXIII';
    print roman(123), "\n";
    print roman2int($roman), "\n" if isroman($roman);
    print mroman2int($mroman), "\n" if ismroman($mroman);

=head1 DESCRIPTION

C<Text::Roman::roman()> is a very simple digit converter.
It converts a single integer (in Arabic digits) at a time to its Roman correspondent.
The conventional Roman numbers goes from 1 up to 3999. MROMANS (milhar romans) range is 1 up to I<3999 * 1000 + 3999 = 4002999>.

There is no concern for mix cases, like 'Xv', 'XiiI', as legal Roman digit numbers.

=cut

use strict;
use warnings qw(all);

## no critic (ProhibitAutomaticExportation, ProhibitExplicitISA)
our @ISA = qw(Exporter);
our @EXPORT = qw(roman int2roman roman2int isroman mroman2int milhar2int ismroman ismilhar);

# VERSION

my @alg = split '', 'IVXLCDM';
my @alginf = (-1, 0, 0, 2, 2, 4, 4);
my %parsub = (
    IV  => 'A',
    IX  => 'B',
    XL  => 'E',
    XC  => 'F',
    CD  => 'G',
    CM  => 'H',
);
my %val = (
    I   => 1,
    V   => 5,
    X   => 10,
    L   => 50,
    C   => 100,
    D   => 500,
    M   => 1000,
    A   => 4,
    B   => 9,
    E   => 40,
    F   => 90,
    G   => 400,
    H   => 900,
);
my %maxpos = (
    I   => 2,
    V   => 3,
    X   => 29,
    L   => 39,
    C   => 299,
    D   => 399,
    M   => 2999,
    A   => 0,
    B   => 0,
    E   => 9,
    F   => 9,
    G   => 99,
    H   => 99,
);

my @valg;
for my $i (0 .. $#alg){
    $valg[$i] = $val{$alg[$i]};
}

=for Pod::Coverage
roman_stx
roman_div
roman_do
=cut

sub roman_stx {
    my $x   = shift;
    my $aux = $$x;

    $$x = uc $$x;
    if ($$x eq $aux || lc $$x eq $aux){
        if ($$x =~ /^[IXCMVLD]+$/x && $$x !~ /([IXCM])\1{3,}|([VLD])\2+/x) {
            $$x =~ s/(IV|IX|XL|XC|CD|CM)/$parsub{$1}/gx;
            return $$x !~ /[AB].*?I|[EF].*?X|[GH].*?C/x;
        } else {
            return '';
        }
    } else {
        return '';
    }
}

=func roman2int($str)

Return '' if C<$str> is not Roman or return integer if it is.

=cut

sub roman2int {
    my $x = shift;
    my ($at, $i);
    my $val = 0;
    my $ant = 0;
    my @U;

    if (roman_stx(\$x)){
        @U = split('', $x);
        for ($i = $#U; $i >= 0; $i--) {
            $at = $val{$U[$i]};
            return '' if ($at < $ant);
            $val += $at;
            $ant = $at;
        }
        return $val;
    } else {
        return '';
    }
}

=func mroman2int($str) / milhar2int($str)

Return '' if C<$str> is not Roman or return integer if it is.
(milhar support)

=cut

# allows '_' milhar syntax (LX_XXIII, L_X_XXIII)
sub milhar2int { return mroman2int(shift) }
sub mroman2int {
    my $x = shift;
    my $s = 0;
    my ($sroman, $aux);
    my $y = '';
    my @partes;

    @partes = split('_', $x);
    $sroman = pop @partes;
    for my $i (@partes){
        $y .= $i;
    }
    $aux = roman2int($y);
    return '' if ($y =~ /^(I{1,3})$/x || !$aux);
    $s += $aux * 1000;
    $aux = roman2int($sroman);
    return '' if (!$aux);
    return $s + $aux;
}

=func ismroman($str) / ismilhar($str)

Verify whether the given string is a milhar Roman number, if it is return 1; if it is not return 0.

=cut

# allows '_' milhar syntax (LX_XXIII, L_X_XXIII)
sub ismilhar { return ismroman(shift) }
sub ismroman {
    my $x = shift;
    my ($sroman);
    my $y = '';
    my @partes;

    if ($x =~ /^[_IXCMVLD]+$/x) {
        @partes = split('_', $x);
        $sroman = pop @partes;
        for my $i (@partes) {
            $y .= $i;
        }
        return '' if ($y =~ /^(I{1,3})$/x || !isroman($y));
        return isroman($sroman);
    }
}

=func isroman($str)

Verify whether the given string is a conventional Roman number, if it is return 1; if it is not return 0.

=cut

# same efect that (roman2int($x)>0), but fasted
sub isroman {
    my $x = shift;
    my $y = $x;
    $x = uc $x;

    ## no critic (ProhibitComplexRegexes)
    return ($x eq $y || lc $x eq $y) && $x =~ /
        ^(M{1,3}(D(C{1,3}(L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3})))?|
        C{0,3}XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))?|
        CD(XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))?|
        (C{1,3}(L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3})))?|
        C{0,3}XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3})))))?|
        M{0,3}CM(XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))?|
        (D(C{1,3}(L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3})))?|
        C{0,3}XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))?|
        CD(XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))?|
        (C{1,3}(L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3})))?|
        C{0,3}XC(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (L(X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        XL(IX|
        (VI{0,3}|
        IV|
        I{1,3}))?|
        (X{1,3}(VI{0,3}|
        IV|
        I{1,3})?|
        X{0,3}IX|
        (VI{0,3}|
        IV|
        I{1,3}))))))$
    /x;
}

sub roman_div {
    my ($a, $b) = @_;
    my $inf = $alginf[$b];

    if ($b < 0) {
        return (0, -1);
    } elsif (int($a / $valg[$b]) > 0) {
        return ($b, -1);
    } elsif ($a + $valg[$inf] >= $valg[$b]) {
        return ($b, $inf);
    } else {
        return roman_div($a, $b - 1);
    }
}

sub roman_do {
    my ($x, $str_x) = @_;
    my ($aux, $inf);

    ($aux, $inf) = roman_div($x, $#alg);
    if ($x > 0 && $inf < 0) {
        return roman_do($x - $valg[$aux], $str_x . $alg[$aux]);
    } elsif ($x > 0 && $inf >= 0) {
        return roman_do($x + $valg[$inf] - $valg[$aux], $str_x . $alg[$inf] . $alg[$aux]);
    } else {
        return $str_x;
    }
}

=func roman($int) / int2roman($int)

Return string containing the Roman corresponding to the given integer, or '' if the integer is out of domain.

=cut

sub int2roman { return roman(shift) }
sub roman {
    my ($x) = @_;
    if ($x < 1 || $x > 3999){
        return '';
    } else {
        return roman_do($x, "");
    }
}

1;

__END__

=head1 SPECIFICATION

Roman number has origin in following BNF-like formula:

    a = I{1,3}
    b = V\a?|IV|\a
    e = X{1,3}\b?|X{0,3}IX|\b
    ee = IX|\b
    f = L\e?|XL\ee?|\e
    g = C{1,3}\f?|C{0,3}XC\ee?|\f
    gg = XC\ee?|\f
    h = D\g?|CD\gg?|\g
    j = M{1,3}\h?|M{0,3}CM\gg?|\h

=head1 REFERENCES

Specification supplied by redactor's manual of newspaper "O Estado de São Paulo".
URL: L<http://web.archive.org/web/20020819094718/http://www.estado.com.br/redac/norn-nro.html>

=cut
