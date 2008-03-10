# 01-Term-Title.t
# Copyright (c) 2008 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

use strict;
use warnings;

use Test::More;

plan tests => 5;


require_ok( 'Term::Title' );

can_ok( 'Term::Title', 'set_titlebar', '_is_supported' );

Term::Title->import('set_titlebar');

can_ok( 'main', 'set_titlebar' );

# reclaim STDOUT from Test::More
local *STDOUT;
open STDOUT, ">>&=0" or die "Couldn't reclaim STDOUT from Test::More";

diag "Term appears to be '$ENV{TERM}'";

SKIP:
{
    skip "Automated testing not supported", 2
        if $ENV{AUTOMATED_TESTING};

    skip "Term::Title not supported on this terminal type", 2
        unless Term::Title::_is_supported();

    my $phrase = "Hello";

    set_titlebar("[$phrase]","# Setting title to ", "'[$phrase]'");
    print STDERR "\n# Do you see '[$phrase]' in the title bar (or tab) of this window? (y/n)\n";
    my $answer = <STDIN>;
    ok( substr(lc $answer, 0, 1) eq 'y', "Title set correctly" );

    # clear
    set_titlebar();
    print STDERR "\n# Has the title bar (or tab) been cleared? (y/n)\n";
    $answer = <STDIN>;
    ok( substr(lc $answer, 0, 1) eq 'y', "Title cleared correctly" );

}
