# lib/Term/Title.pm
# Copyright (c) 2008 by David Golden. All rights reserved.
# Licensed under Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://www.apache.org/licenses/LICENSE-2.0

package Term::Title;
use strict;
use warnings;

our $VERSION = '0.01';
$VERSION = eval $VERSION; ## no critic

use Exporter;
our @ISA = 'Exporter';
our @EXPORT_OK = qw/set_titlebar/;

# encodings by terminal type -- except for mswin32 get matched as regex
# against $ENV{TERM}
# code ref gets title and text to print
my %terminal = (
    'xterm|rxvt' => {
        pre => "\033]2;",
        post => "\007",
    },
    'mswin32' => sub {
        my ($title, @optional) = @_;
        my $c = Win32::Console->new();
        $c->Title($title);
        print STDOUT @optional, "\n";
    },
);

sub set_titlebar {
    my ($title, @optional) = @_;
    $title = q{ } unless defined $title;
    @optional = qw{} unless @optional;
    my $type = _is_supported();

    if ( $type ) {
        if ( ref $terminal{$type} eq 'CODE' ) {
            $terminal{$type}->( $title, @optional );
        }
        elsif (ref $terminal{$type} eq 'HASH' ) {
            print STDOUT $terminal{$type}{pre},  $title, 
                         $terminal{$type}{post}, @optional, "\n";
        }
    }
    else {
        print STDOUT @optional, "\n";
    }
    return;
}

sub _is_supported {
    if ( $^O eq 'MSWin32' ) {
        return 'mswin32' if eval { require Win32::Console };
    }
    else {
        return unless $ENV{TERM};
        for my $k ( keys %terminal ) {
            return $k if $ENV{TERM} =~ /^(?:$k)/;
        }
    }
    return;
}

1;

__END__

=begin wikidoc

= NAME

Term::Title - Portable API to set the terminal titlebar

= VERSION

This documentation describes version %%VERSION%%.

= SYNOPSIS

    use Term::Title 'set_titlebar';

    set_titlebar("This goes into the title");

    set_titlebar("Title", "And also print this to the terminal");

= DESCRIPTION

Term::Title provides an abstraction for setting the titlebar (or title tab)
across different types of terminals.  For *nix terminals, it prints the
appropriate escape sequences to set the terminal title based on the value of
{$ENV{TERM}}.  On Windows, it uses [Win32::Console] to set the title directly.  

Currently, supported terminals include:

* xterm
* rxvt
* Win32 console

= USAGE

== {set_titlebar()}

    set_titlebar( $title, @optional_text );

Sets the titlebar to {$title} or clears the titlebar if {$title} is 
undefined.   

On terminals that require printing escape codes to the terminal, a newline
character is also printed to the terminal.  If {@optional_text} is given, it
will be printed to the terminal prior to the newline.  Thus, to keep terminal
output cleaner, use {set_titlebar()} in place of a {print()} statement to
set the titlebar and print at the same time.

= BUGS

Please report any bugs or feature using the CPAN Request Tracker.  
Bugs can be submitted through the web interface at 
[http://rt.cpan.org/Dist/Display.html?Queue=Term-Title]

When submitting a bug or request, please include a test-file or a patch to an
existing test-file that illustrates the bug or desired feature.

= SEE ALSO

* [Win32::Console]
* [http://www.ibiblio.org/pub/Linux/docs/HOWTO/Xterm-Title]

= AUTHOR

David A. Golden (DAGOLDEN)

= COPYRIGHT AND LICENSE

Copyright (c) 2008 by David A. Golden. All rights reserved.

Licensed under Apache License, Version 2.0 (the "License").
You may not use this file except in compliance with the License.
A copy of the License was distributed with this file or you may obtain a 
copy of the License from http://www.apache.org/licenses/LICENSE-2.0

Files produced as output though the use of this software, shall not be
considered Derivative Works, but shall be considered the original work of the
Licensor.

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=end wikidoc

=cut

