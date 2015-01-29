package Parcel::Track;
# ABSTRACT: Driver-based API for tracking parcel

use Moo;
use Types::Standard qw( Object );

use Carp;
use Module::Runtime;
use Params::Util 0.14 ();
use Try::Tiny;

our $VERSION = '0.005';

has driver => (
    is      => 'ro',
    isa     => Object,
    handles => [qw( id uri )],
);

sub BUILDARGS {
    my ( $class, $driver_class, $id, @args ) = @_;

    unless ( defined $driver_class && !ref $driver_class && length $driver_class ) {
        Carp::croak("Did not provide a Parcel::Track driver name");
    }
    unless ( Params::Util::_CLASS($driver_class) ) {
        Carp::croak("Not a valid Parcel::Track driver name");
    }

    unless ( defined $id && !ref $id && length $id ) {
        Carp::croak("Did not provide a Parcel::Track tracking number");
    }

    my $driver_name = $driver_class;
    $driver_class = "Parcel::Track::$driver_class";
    try {
        Module::Runtime::require_module($driver_class);
    }
    catch {
        if (m/^Can't locate /) {
            # Driver does not exist
            Carp::croak("Parcel::Track driver $driver_name does not exist, or is not installed");
        }
        else {
            # Fatal error within the driver itself
            # Pass on without change
            Carp::croak($_);
        }
    };
    unless ( $driver_class->can('new') ) {
        Carp::croak("$driver_class does not have new method");
    }
    my $driver = $driver_class->new(
        id => $id,
        $class->_PRIVATE(@args),
    );
    unless ( $driver->can('does') && $driver->does('Parcel::Track::Role::Base') ) {
        Carp::croak("$driver_class does not have Parcel::Track::Role::Base role");
    }

    return +{ driver => $driver };
}

sub track {
    my $self = shift;

    my $rv = $self->driver->track;
    Carp::croak("Driver did not return a result")
        unless Params::Util::_HASH($rv);
    Carp::croak("Driver returned an invalid \$result->{from}")
        unless Params::Util::_SCALAR0( \$rv->{from} );
    Carp::croak("Driver returned an invalid \$result->{to}")
        unless Params::Util::_SCALAR0( \$rv->{to} );
    Carp::croak("Driver returned an invalid \$result->{result}")
        unless Params::Util::_SCALAR0( \$rv->{result} );
    Carp::croak("Driver returned an invalid \$result->{descs}")
        unless Params::Util::_ARRAY0( $rv->{descs} );
    Carp::croak("Driver returned an invalid \$result->{htmls}")
        unless Params::Util::_ARRAY0( $rv->{htmls} );

    return $rv;
}

# Filter params for only the private params
sub _PRIVATE {
    my $class  = ref $_[0] ? ref shift : shift;
    my @input  = @_;
    my @output = ();
    while (@input) {
        my $key   = shift @input;
        my $value = shift @input;
        if ( Params::Util::_STRING($key) and $key =~ /^_/ ) {
            $key =~ s/^_//;
            push @output, $key, $value;
        }
    }
    return @output;
}

1;

# COPYRIGHT

__END__

=for Pod::Coverage BUILDARGS

=head1 SYNOPSIS

    # Create a tracker
    my $tracker = Parcel::Track->new( 'KR::Test', '64537-0301-2020' );

    # ID & URI
    print $tracker->id . "\n";
    print $tracker->uri . "\n";
    
    # Track the information
    my $result = $tracker->track;
    
    # Get the information what you want.
    if ( $result ) {
        print "$result->{from}\n";
        print "$result->{to}\n";
        print "$result->{result}\n";
        print "$_\n" for @{ $result->{descs} };
        print "$_\n" for @{ $result->{htmls} };
    }
    else {
        print "Failed to track information\n";
    }


=head1 DESCRIPTION

C<Parcel::Track> is intended to provide a driver-based single API for tracking
parcel information. The intent is to provide a single API against which to
write the code to track the parcel information.

C<Parcel::Track> drivers are installed seperately.

The design of this module is almost stolen from L<SMS::Send>.


=attr driver

Returns loaded driver object.
You can access attributes and methods of specific driver.

    $tracker = Parcel::Track->new( 'MyDriver', '123-456-789-012',
        _username => 'keedi',
        _password => 'keedi',
    );
    $tracker->driver->username; # NOT _username BUT username
    $tracker->driver->password; # NOT _password BUT password
    $tracker->driver->foo( $dummy1 );
    $tracker->driver->bar( $dummy2, $dummy3 );


=method new

    # The most basic tracker
    $tracker = Parcel::Track->new( 'Test', '123-456-789-012' );
    
    # Indicate regional driver with ::
    $tracker = Parcel::Track->new( 'KR::Test', '123-456-789-012' );
    
    # Pass arbitrary params to the driver
    $tracker = Parcel::Track->new( 'MyDriver', '123-456-789-012',
        _username => 'keedi',
        _password => 'keedi',
    );

The C<new> constructor creates a new Parcel tracker.

It takes as its first parameter a driver name. These names map the class
names. For example driver "Test" matches the testing driver
L<Parcel::Track::Test>.

It takes as its second parameter a tracking number.

Any additional params should be key/value pairs, split into two types.

Params without a leading underscore are "public" options and relate to
standardised features within the L<Parcel::Track> API itself. At this
time, there are no usable public options.

Params B<with> a leading underscore are "private" driver-specific options
and will be passed through to the driver B<without> the underscore.

    $tracker = Parcel::Track->new( 'MyDriver', '123-456-789-012',
        _username => 'keedi',
        _password => 'keedi',
    );
    $tracker->driver->username; # NOT _username BUT username
    $tracker->driver->password; # NOT _password BUT password

Returns a new L<Parcel::Track> object, or dies on error.


=method id

Returns tracking number.


=method uri

Returns official link to track parcel.


=method track

Returns C<HASHREF> which contains information of tracking the parcel.

    my $tracker = Parcel::Track->new( 'KR::Test', '64537-0301-2020' );
    my $info = $tracker->track;
    print "$info->{from}\n";
    print "$info->{to}\n";
    print "$info->{result}\n";
    print "$_\n" for @{ $info->{htmls} };
    print "$_\n" for @{ $info->{descs} };

C<HASHREF> MUST contain following key and value pairs.

=for :list
* C<from>: C<SCALAR>.
* C<to>: C<SCALAR>.
* C<result>: C<SCALAR>.
* C<htmls>: C<ARRAYREF>.
* C<descs>: C<ARRAYREF>.


=head1 SEE ALSO

=for :list
* L<Parcel::Track::KR::CJKorea>
* L<Parcel::Track::KR::PostOffice>
* L<SMS::Send>
