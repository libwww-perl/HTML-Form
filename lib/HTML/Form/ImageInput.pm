package HTML::Form::ImageInput;

use strict;
use parent 'HTML::Form::SubmitInput';

our $VERSION = '6.12';

# ABSTRACT: An HTML form image input element for use with HTML::Form

sub form_name_value {
    my $self    = shift;
    my $clicked = $self->{clicked};
    return unless $clicked;
    return if $self->{disabled};
    my $name = $self->{name};
    $name = ( defined($name) && length($name) ) ? "$name." : "";
    return (
        "${name}x" => $clicked->[0],
        "${name}y" => $clicked->[1]
    );
}

1;
