#!perl
use strict;
use warnings;

use Test::More tests => 1;

BEGIN {
    use_ok('Text::Roman');
}

diag("Testing Text::Roman v$Text::Roman::VERSION, Perl $], $^X");
