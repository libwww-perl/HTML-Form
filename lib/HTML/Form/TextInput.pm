package HTML::Form::TextInput;

use strict;
use parent 'HTML::Form::Input';

our $VERSION = '6.11';

# ABSTRACT: An HTML form text input element for use with HTML::Form

#input/text
#input/password
#input/hidden
#textarea

sub value {
    my $self = shift;
    my $old  = $self->{value};
    $old = "" unless defined $old;
    if (@_) {
        Carp::croak("Input '$self->{name}' is readonly")
            if $self->{strict} && $self->{readonly};
        my $new = shift;
        my $n   = exists $self->{maxlength} ? $self->{maxlength} : undef;
        Carp::croak("Input '$self->{name}' has maxlength '$n'")
            if $self->{strict}
            && defined($n)
            && defined($new)
            && length($new) > $n;
        $self->{value} = $new;
    }
    $old;
}

1;
