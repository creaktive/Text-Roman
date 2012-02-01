#!perl
use strict;
use utf8;
use warnings 'all';

use Test::More tests => 6;

use_ok('Text::Roman');

ok(isroman('DCLXVI'), 'isroman');
ok(ismroman('L_X_XXIII'), 'ismroman');

ok(roman2int('DCLXVI') == 666, 'roman2int');
ok(mroman2int('L_X_XXIII') == 60023, 'mroman2int');

ok(roman(666) eq 'DCLXVI', 'roman');
