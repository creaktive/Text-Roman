#!perl
use strict;
use warnings qw(all);

use Test::More;

use Text::Roman qw(:all);

ok(isroman('DCLXVI'), 'isroman');
ok(ismilhar('L_X_XXIII'), 'ismilhar');

is(roman2int('DCLXVI'), 666, 'roman2int');
is(milhar2int('L_X_XXIII'), 60023, 'milhar2int');

is(int2roman(666), 'DCLXVI', 'int2roman');

done_testing 5;
