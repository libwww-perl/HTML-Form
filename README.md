# NAME

HTML::Form - Class that represents an HTML form element

# VERSION

version 6.12

# SYNOPSIS

    use HTML::Form;
    $form = HTML::Form->parse($html, $base_uri);
    $form->value(query => "Perl");

    use LWP::UserAgent;
    $ua = LWP::UserAgent->new;
    $response = $ua->request($form->click);

# DESCRIPTION

Objects of the `HTML::Form` class represents a single HTML
`<form> ... </form>` instance.  A form consists of a
sequence of inputs that usually have names, and which can take on
various values.  The state of a form can be tweaked and it can then be
asked to provide [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest) objects that can be passed to the
request() method of [LWP::UserAgent](https://metacpan.org/pod/LWP%3A%3AUserAgent).

The following methods are available:

- @forms = HTML::Form->parse( $html\_document, $base\_uri )
- @forms = HTML::Form->parse( $html\_document, base => $base\_uri, %opt )
- @forms = HTML::Form->parse( $response, %opt )

    The parse() class method will parse an HTML document and build up
    `HTML::Form` objects for each &lt;form> element found.  If called in scalar
    context only returns the first &lt;form>.  Returns an empty list if there
    are no forms to be found.

    The required arguments is the HTML document to parse ($html\_document) and the
    URI used to retrieve the document ($base\_uri).  The base URI is needed to resolve
    relative action URIs.  The provided HTML document should be a Unicode string
    (or US-ASCII).

    By default HTML::Form assumes that the original document was UTF-8 encoded and
    thus encode forms that don't specify an explicit _accept-charset_ as UTF-8.
    The charset assumed can be overridden by providing the `charset` option to
    parse().  It's a good idea to be explicit about this parameter as well, thus
    the recommended simplest invocation becomes:

        my @forms = HTML::Form->parse(
            Encode::decode($encoding, $html_document_bytes),
            base => $base_uri,
            charset => $encoding,
        );

    If the document was retrieved with LWP then the response object provide methods
    to obtain a proper value for `base` and `charset`:

        my $ua = LWP::UserAgent->new;
        my $response = $ua->get("http://www.example.com/form.html");
        my @forms = HTML::Form->parse($response->decoded_content,
            base => $response->base,
            charset => $response->content_charset,
        );

    In fact, the parse() method can parse from an [HTTP::Response](https://metacpan.org/pod/HTTP%3A%3AResponse) object
    directly, so the example above can be more conveniently written as:

        my $ua = LWP::UserAgent->new;
        my $response = $ua->get("http://www.example.com/form.html");
        my @forms = HTML::Form->parse($response);

    Note that any object that implements a decoded\_content(), base() and
    content\_charset() method with similar behaviour as [HTTP::Response](https://metacpan.org/pod/HTTP%3A%3AResponse) will do.

    Additional options might be passed in to control how the parse method
    behaves.  The following are all the options currently recognized:

    - `base => $uri`

        This is the URI used to retrieve the original document.  This option is not optional ;-)

    - `charset => $str`

        Specify what charset the original document was encoded in.  This is used as
        the default for accept\_charset.  If not provided this defaults to "UTF-8".

    - `verbose => $bool`

        Warn (print messages to STDERR) about any bad HTML form constructs found.
        You can trap these with $SIG{\_\_WARN\_\_}.  The default is not to issue warnings.

    - `strict => $bool`

        Initialize any form objects with the given strict attribute.
        If the strict is turned on the methods that change values of the form will croak if you try
        to set illegal values or modify readonly fields.
        The default is not to be strict.

- $form->push\_input( $type, \\%attr, $verbose )

    This method adds additional inputs to the form.
    The first argument is the type of input (e.g. hidden, option, etc.).
    The second argument is a reference to a hash of the input attributes.
    The third argument is optional, and will issue warnings about unknown input types.

    Example:

        push_input( 'hidden', {
            name  => 'NewFormElement',
            id    => 'NewFormElementId',
            value => 'some value',
        });

- $method = $form->method
- $form->method( $new\_method )

    This method is gets/sets the _method_ name used for the
    [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest) generated.  It is a string like "GET" or "POST".

- $action = $form->action
- $form->action( $new\_action )

    This method gets/sets the URI which we want to apply the request
    _method_ to.

- $enctype = $form->enctype
- $form->enctype( $new\_enctype )

    This method gets/sets the encoding type for the form data.  It is a
    string like "application/x-www-form-urlencoded" or "multipart/form-data".

- $accept = $form->accept\_charset
- $form->accept\_charset( $new\_accept )

    This method gets/sets the list of charset encodings that the server processing
    the form accepts. Current implementation supports only one-element lists.
    Default value is "UNKNOWN" which we interpret as a request to use document
    charset as specified by the 'charset' parameter of the parse() method.

- $value = $form->attr( $name )
- $form->attr( $name, $new\_value )

    This method give access to the original HTML attributes of the &lt;form> tag.
    The $name should always be passed in lower case.

    Example:

        @f = HTML::Form->parse( $html, $foo );
        @f = grep $_->attr("id") eq "foo", @f;
        die "No form named 'foo' found" unless @f;
        $foo = shift @f;

- $bool = $form->strict
- $form->strict( $bool )

    Gets/sets the strict attribute of a form.  If the strict is turned on
    the methods that change values of the form will croak if you try to
    set illegal values or modify readonly fields.  The default is not to be strict.

- @inputs = $form->inputs

    This method returns the list of inputs in the form.  If called in
    scalar context it returns the number of inputs contained in the form.
    See ["INPUTS"](#inputs) for what methods are available for the input objects
    returned.

- $input = $form->find\_input( $selector )
- $input = $form->find\_input( $selector, $type )
- $input = $form->find\_input( $selector, $type, $index )
- @inputs = $form->find\_input( $selector )
- @inputs = $form->find\_input( $selector, $type )

    This method is used to locate specific inputs within the form.  All
    inputs that match the arguments given are returned.  In scalar context
    only the first is returned, or `undef` if none match.

    If `$selector` is not `undef`, then the input's _name_, _id_ or _class_
    attribute must match.
    A selector prefixed with '#' must match the _id_ attribute of the input.
    A selector prefixed with '.' matches the _class_ attribute. A selector prefixed
    with '^' or with no prefix matches the _name_ attribute.

        my @by_id         = $form->find_input( '#some-id' );
        my @by_class      = $form->find_input( '.some-class' );
        my @by_name       = $form->find_input( '^some-name' );
        my @also_by_name  = $form->find_input( 'some-name' );

    If you want to find an input that has no _name_ at all, pass in a reference
    to `undef`.

        my @nameless_inputs = $form->find_input( \undef );

    If `$type` is not `undef`, then the input must have the specified type.
    The following type names are used: "text", "password", "hidden",
    "textarea", "file", "image", "submit", "radio", "checkbox" and "option".

    The `$index` is the sequence number of the input matched where 1 is the
    first.  If combined with `$selector` and/or `$type`, then it selects the
    _n_th input with the given _name_ and/or type.

- $value = $form->value( $selector )
- $form->value( $selector, $new\_value )

    The value() method can be used to get/set the value of some input.  If
    strict is enabled and no input has the indicated name, then this method will croak.

    If multiple inputs have the same name, only the first one will be
    affected.

    The call:

        $form->value('foo')

    is basically a short-hand for:

        $form->find_input('foo')->value;

- @names = $form->param
- @values = $form->param( $name )
- $form->param( $name, $value, ... )
- $form->param( $name, \\@values )

    Alternative interface to examining and setting the values of the form.

    If called without arguments then it returns the names of all the
    inputs in the form.  The names will not repeat even if multiple inputs
    have the same name.  In scalar context the number of different names
    is returned.

    If called with a single argument then it returns the value or values
    of inputs with the given name.  If called in scalar context only the
    first value is returned.  If no input exists with the given name, then
    `undef` is returned.

    If called with 2 or more arguments then it will set values of the
    named inputs.  This form will croak if no inputs have the given name
    or if any of the values provided does not fit.  Values can also be
    provided as a reference to an array.  This form will allow unsetting
    all values with the given name as well.

    This interface resembles that of the param() function of the CGI
    module.

- $form->try\_others( \\&callback )

    This method will iterate over all permutations of unvisited enumerated
    values (&lt;select>, &lt;radio>, &lt;checkbox>) and invoke the callback for
    each.  The callback is passed the $form as argument.  The return value
    from the callback is ignored and the try\_others() method itself does
    not return anything.

- $request = $form->make\_request

    Will return an [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest) object that reflects the current setting
    of the form.  You might want to use the click() method instead.

- $request = $form->click
- $request = $form->click( $selector )
- $request = $form->click( $x, $y )
- $request = $form->click( $selector, $x, $y )

    Will "click" on the first clickable input (which will be of type
    `submit` or `image`).  The result of clicking is an [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest)
    object that can then be passed to [LWP::UserAgent](https://metacpan.org/pod/LWP%3A%3AUserAgent) if you want to
    obtain the server response.

    If a $selector is specified, we will click on the first clickable input
    matching the selector, and the method will croak if no matching clickable
    input is found.  If $selector is _not_ specified, then it
    is ok if the form contains no clickable inputs.  In this case the
    click() method returns the same request as the make\_request() method
    would do.  See description of the find\_input() method above for how
    the $selector is specified.

    If there are multiple clickable inputs with the same name, then there
    is no way to get the click() method of the `HTML::Form` to click on
    any but the first.  If you need this you would have to locate the
    input with find\_input() and invoke the click() method on the given
    input yourself.

    A click coordinate pair can also be provided, but this only makes a
    difference if you clicked on an image.  The default coordinate is
    (1,1).  The upper-left corner of the image is (0,0), but some badly
    coded CGI scripts are known to not recognize this.  Therefore (1,1) was
    selected as a safer default.

- @kw = $form->form

    Returns the current setting as a sequence of key/value pairs.  Note
    that keys might be repeated, which means that some values might be
    lost if the return values are assigned to a hash.

    In scalar context this method returns the number of key/value pairs
    generated.

- $form->dump

    Returns a textual representation of current state of the form.  Mainly
    useful for debugging.  If called in void context, then the dump is
    printed on STDERR.

# NAME

HTML::Form - Class that represents an HTML form element

# INPUTS

An `HTML::Form` object contains a sequence of _inputs_.  References to
the inputs can be obtained with the $form->inputs or $form->find\_input
methods.

Note that there is _not_ a one-to-one correspondence between input
_objects_ and &lt;input> _elements_ in the HTML document.  An
input object basically represents a name/value pair, so when multiple
HTML elements contribute to the same name/value pair in the submitted
form they are combined.

The input elements that are mapped one-to-one are "text", "textarea",
"password", "hidden", "file", "image", "submit" and "checkbox".  For
the "radio" and "option" inputs the story is not as simple: All
&lt;input type="radio"> elements with the same name will
contribute to the same input radio object.  The number of radio input
objects will be the same as the number of distinct names used for the
&lt;input type="radio"> elements.  For a &lt;select> element
without the `multiple` attribute there will be one input object of
type of "option".  For a &lt;select multiple> element there will
be one input object for each contained &lt;option> element.  Each
one of these option objects will have the same name.

The following methods are available for the _input_ objects:

- $input->type

    Returns the type of this input.  The type is one of the following
    strings: "text", "password", "hidden", "textarea", "file", "image", "submit",
    "radio", "checkbox" or "option".

- $name = $input->name
- $input->name( $new\_name )

    This method can be used to get/set the current name of the input.

- $input->id
- $input->class

    These methods can be used to get/set the current id or class attribute for the input.

- $input->selected( $selector )

    Returns TRUE if the given selector matched the input.  See the description of
    the find\_input() method above for a description of the selector syntax.

- $value = $input->value
- $input->value( $new\_value )

    This method can be used to get/set the current value of an
    input.

    If strict is enabled and the input only can take an enumerated list of values,
    then it is an error to try to set it to something else and the method will
    croak if you try.

    You will also be able to set the value of read-only inputs, but a
    warning will be generated if running under `perl -w`.

- $autocomplete = $input->autocomplete
- $input->autocomplete( $new\_autocomplete )

    This method can be used to get/set the current value (if any) of `autcomplete` for the input.

- $input->possible\_values

    Returns a list of all values that an input can take.  For inputs that
    do not have discrete values, this returns an empty list.

- $input->other\_possible\_values

    Returns a list of all values not tried yet.

- $input->value\_names

    For some inputs the values can have names that are different from the
    values themselves.  The number of names returned by this method will
    match the number of values reported by $input->possible\_values.

    When setting values using the value() method it is also possible to
    use the value names in place of the value itself.

- $bool = $input->readonly
- $input->readonly( $bool )

    This method is used to get/set the value of the readonly attribute.
    You are allowed to modify the value of readonly inputs, but setting
    the value will generate some noise when warnings are enabled.  Hidden
    fields always start out readonly.

- $bool = $input->disabled
- $input->disabled( $bool )

    This method is used to get/set the value of the disabled attribute.
    Disabled inputs do not contribute any key/value pairs for the form
    value.

- $input->form\_name\_value

    Returns a (possible empty) list of key/value pairs that should be
    incorporated in the form value from this input.

- $input->check

    Some input types represent toggles that can be turned on/off.  This
    includes "checkbox" and "option" inputs.  Calling this method turns
    this input on without having to know the value name.  If the input is
    already on, then nothing happens.

    This has the same effect as:

        $input->value($input->possible_values[1]);

    The input can be turned off with:

        $input->value(undef);

- $input->click($form, $x, $y)

    Some input types (currently "submit" buttons and "images") can be
    clicked to submit the form.  The click() method returns the
    corresponding [HTTP::Request](https://metacpan.org/pod/HTTP%3A%3ARequest) object.

If the input is of type `file`, then it has these additional methods:

- $input->file

    This is just an alias for the value() method.  It sets the filename to
    read data from.

    For security reasons this field will never be initialized from the parsing
    of a form.  This prevents the server from triggering stealth uploads of
    arbitrary files from the client machine.

- $filename = $input->filename
- $input->filename( $new\_filename )

    This get/sets the filename reported to the server during file upload.
    This attribute defaults to the value reported by the file() method.

- $content = $input->content
- $input->content( $new\_content )

    This get/sets the file content provided to the server during file
    upload.  This method can be used if you do not want the content to be
    read from an actual file.

- @headers = $input->headers
- input->headers($key => $value, .... )

    This get/set additional header fields describing the file uploaded.
    This can for instance be used to set the `Content-Type` reported for
    the file.

# SEE ALSO

[LWP](https://metacpan.org/pod/LWP), [LWP::UserAgent](https://metacpan.org/pod/LWP%3A%3AUserAgent), [HTML::Parser](https://metacpan.org/pod/HTML%3A%3AParser)

# AUTHOR

Gisle Aas <gisle@activestate.com>

# COPYRIGHT AND LICENSE

This software is copyright (c) 1998 by Gisle Aas.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
