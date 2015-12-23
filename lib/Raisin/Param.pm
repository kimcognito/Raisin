package Raisin::Param;

use strict;
use warnings;

use Carp;
use Raisin::Attributes;

has 'named';
has 'required';

has 'default';
has 'name';
has 'type';
has 'regex';
has 'desc';

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;

    $self->{named} = $args{named} || 0;
    $self->{required} = $args{type} =~ /^require(s|d)$/ ? 1 : 0;

    $self->_parse($args{spec});

    $self;
}

sub app {
    Raisin::API->app
}

sub _parse {
    my ($self, $spec) = @_;
    $self->{$_} = $spec->{$_} for qw(name type default regex desc);
}

sub validate {
    my ($self, $ref_value) = @_;

    # Required
    # Only optional parameters can have default value
    if ($self->required && !defined($$ref_value)) {
        $self->app->log(warn => '`%s` is required', $self->name);
        return;
    }

    # Optional and empty
    if (!defined($$ref_value) && !$self->required) {
        $self->app->log(debug => '`%s` is optional and empty', $self->name);
        return 1;
    }

    # TODO: validate HASHes
    if ($$ref_value && ref $$ref_value && ref $$ref_value ne 'ARRAY') {
        $self->app->log(debug => '`%s` is %s should be SCALAR or ARRAY',
            $self->name, ref $$ref_value);
        return 1;
    }

    my $was_scalar;
    if (ref $$ref_value ne 'ARRAY') {
        $was_scalar = 1;
        $$ref_value = [$$ref_value];
    }

    for my $v (@$$ref_value) {
        # Type check
        eval { $v = $self->type->($v) } or do {
            $self->app->log(debug => '`%s` failed type constraint `%s` with "%s"',
                $self->name, $self->type->name, $v);
            return;
        };

        # Param check
        if ($self->regex && $v !~ $self->regex) {
            $self->app->log(debug => '`%s` failed regex constraint `%s` with "%s"',
                $self->name, $self->regex, $v);
            return;
        }
    }

    $$ref_value = $$ref_value->[0] if $was_scalar;

    1;
}

1;

__END__

=head1 NAME

Raisin::Param - Parameter class for Raisin.

=head1 DESCRIPTION

Parameter class for L<Raisin>. Validates request paramters.

=head3 default

Returns default value if exists or C<undef>.

=head3 desc

Returns parameter description.

=head3 name

Returns parameter name.

=head3 named

Returns C<true> if it's path parameter.

=head3 regex

Return paramter regex if exists or C<undef>.

=head3 required { shift->{required} }

Returns C<true> if it's required parameter.

=head3 type

Returns parameter type object.

=head3 validate

Process and validate parameter. Takes B<reference> as the input paramter.

    $p->validate(\$value);

=head1 AUTHOR

Artur Khabibullin - rtkh E<lt>atE<gt> cpan.org

=head1 LICENSE

This module and all the modules in this package are governed by the same license
as Perl itself.

=cut
