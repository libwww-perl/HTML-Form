package HTML::Form::SubmitInput;

use strict;
use parent 'HTML::Form::Input';

our $VERSION = '6.14';

# ABSTRACT: An HTML form submit input element for use with HTML::Form

#input/image
#input/submit

sub click {
    my ( $self, $form, $x, $y ) = @_;
    for ( $x, $y ) { $_ = 1 unless defined; }
    local ( $self->{clicked} ) = [ $x, $y ];
    local ( $self->{value} )   = "" unless defined $self->value;
    return $form->make_request;
}

sub form_name_value {
    my $self = shift;
    return unless $self->{clicked};
    return $self->SUPER::form_name_value(@_);
}

1;
