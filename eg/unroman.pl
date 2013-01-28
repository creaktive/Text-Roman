#!/usr/bin/env perl
use strict;
use warnings qw(all);

use Text::Roman qw(ismilhar milhar2int);

# Filter text, replacing Roman numerals by Arabic equivalent

while (<>) {
    s/
        \b
        ([IVXLCDM_]+)
        \b
    /
        ismilhar(uc $1)
            ? milhar2int(uc $1)
            : $1
    /egix;

    print;
}
