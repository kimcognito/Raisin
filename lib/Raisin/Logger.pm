package Raisin::Logger;

use strict;
use warnings;

my $FH = *STDERR;

my %LEVELS = (
    DEBUG     => 0,
    INFO      => 1,
    NOTICE    => 2,
    WARNING   => 3,
    WARN      => 3,
    ERROR     => 4,
    CRITICAL  => 5,
    ALERT     => 6,
    EMERGENCY => 7,
);

sub new {
    my ($class, %args) = @_;
    my $self = bless { %args }, $class;
    $self;
}

sub min_level { shift->{min_level} || 'WARNING' }

sub log {
    my ($self, %args) = @_;
    return if $LEVELS{ uc($args{level}) } < $LEVELS{ uc($self->min_level) };
    printf $FH '%s %s', uc($args{level}), $args{message};
}

1;

__END__

=head1 NAME

Raisin::Logger - Default logger for Raisin.

=head1 SYNOPSIS

    my $logger = Raisin::Logger->new;
    $logger->log(info => 'Hello, world!');

=head1 DESCRIPTION

Simple logger for Raisin.

=head1 METHODS

=head2 log

Accept's two parameters: C<level> and C<message>.

=head1 AUTHOR

Artur Khabibullin - rtkh E<lt>atE<gt> cpan.org

=head1 LICENSE

This module and all the modules in this package are governed by the same license
as Perl itself.

=cut
