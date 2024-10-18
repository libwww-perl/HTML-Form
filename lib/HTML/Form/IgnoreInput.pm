package HTML::Form::IgnoreInput;

use strict;
use parent 'HTML::Form::Input';

our $VERSION = '6.13';

# ABSTRACT: An HTML form ignored input element for use with HTML::Form

# This represents buttons and resets whose values shouldn't matter
# but should buttons not be like submits?!

#input/button
#input/reset

sub value { return }

1;
