package Term::Title;

use strict;
use warnings;

# ABSTRACT: Portable API to set the terminal titlebar
# VERSION

use Exporter;
our @ISA       = 'Exporter';
our @EXPORT_OK = qw/set_titlebar set_tab_title/;

# encodings by terminal type -- except for mswin32 get matched as regex
# against $ENV{TERM}
# code ref gets passed title

my %terminal =
	(
		'xterm|rxvt' =>
		{
			pre  => "\033]2;",
			post => "\007",
		},
		'screen' =>
		{
			pre  => "\ek",
			post => "\e\\",
		},
		'mswin32' => sub
		{
			my ( $title ) = @_;
			my $c = Win32::Console->new();
			$c->Title($title);
		},
	);

my %terminal_tabs =
	(
		'iterm2' =>
		{
			is_supported => sub
			{
				$ENV{TERM_PROGRAM} and $ENV{TERM_PROGRAM} eq 'iTerm.app';
			},
			pre  => "\033]1;",
			post => "\007",
		},
	);

sub _set
{
    my ( $type_cb, $types, $title ) = @_;
    $title = q{ } unless defined $title;
    my $type = $type_cb->();

    if ($type)
	{
        if ( ref $types->{$type} eq 'CODE' )
		{
            $types->{$type}->( $title );
        }
        elsif ( ref $types->{$type} eq 'HASH' )
		{
            print STDOUT $types->{$type}{pre}, $title, $types->{$type}{post};
        }
    }
    return;
}

sub set_titlebar { _set( \&_is_supported, \%terminal, @_ ) }

sub set_tab_title { _set( \&_is_supported_tabs, \%terminal_tabs, @_ ) }

sub _is_supported
{
    if ( lc($^O) eq 'mswin32' )
	{
        return 'mswin32' if eval { require Win32::Console };
    }
    else
	{
        return unless $ENV{TERM};
        for my $k ( keys %terminal )
		{
            return $k if $ENV{TERM} =~ /^(?:$k)/;
        }
    }
    return;
}

sub _is_supported_tabs
{
    for my $k ( keys %terminal_tabs )
	{
        return $k if $terminal_tabs{$k}{is_supported}->();
    }
    return;
}

1;

__END__

=head1 SYNOPSIS

    use Term::Title 'set_titlebar', 'set_tab_title';

    set_titlebar("This goes into the title");

    set_tab_title("This goes into the tab title");

=head1 DESCRIPTION

Term::Title provides an abstraction for setting the titlebar or the tab title
across different types of terminals.  For *nix terminals, it prints the
appropriate escape sequences to set the terminal or tab title based on the
value of C<$ENV{TERM}>.  On Windows, it uses L<Win32::Console> to set the
title directly.

Currently, changing the titlebar is supported in these terminals:

=for :list
* xterm
* rxvt
* screen
* iTerm2.app
* Win32 console

The terminals that support changing the tab title include:

=for :list
* iTerm2.app

=head1 USAGE

=head2 set_titlebar

    set_titlebar( $title );

Sets the titlebar to C<$title> or clears the titlebar if C<$title> is
undefined.

If the terminal is not supported, set_titlebar silently continues.

=head2 set_tab_title

    set_tab_title( $title );

Has the exact same semantics as the L</set_titlebar> but changes the tab title.

=head1 SEE ALSO

=for :list
* L<Win32::Console>
* L<http://www.ibiblio.org/pub/Linux/docs/HOWTO/Xterm-Title>

=cut
