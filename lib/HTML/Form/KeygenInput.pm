package HTML::Form::KeygenInput;

use strict;
use parent 'HTML::Form::Input';

our $VERSION = '6.12';

# ABSTRACT: An HTML form keygen input element for use with HTML::Form

sub challenge {
    my $self = shift;
    return $self->{challenge};
}

sub keytype {
    my $self = shift;
    return lc( $self->{keytype} || 'rsa' );
}

1;
