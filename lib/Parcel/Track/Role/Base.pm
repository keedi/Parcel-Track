package Parcel::Track::Role::Base;
# ABSTRACT: Parcel::Track base role

use Moo::Role;
use Types::Standard qw( Str );

our $VERSION = '0.001';

has id => (
    is  => 'ro',
    isa => Str,
);

requires 'uri';
requires 'track';

1;

# COPYRIGHT

__END__

=head1 SYNOPSIS

    package Parcel::Track::KR::MyDriver;

    use Moo;

    with 'Parcel::Track::Role::Base';

    sub uri {
        ...
    }

    sub track {
        ...
    }


=head1 DESCRIPTION

The C<Parcel::Track::Role::Base> class provides an abstract base class
for all L<Parcel::Track> driver classes.

At this time it does not provide any implementation code for drivers
(although this may change in the future).
It does serve as something you should sub-class your driver from
to identify it as a L<Parcel::Track> driver.

Please note that if your driver class not B<not> return true for
C<$driver->does('Parcel::Track::Role::Base')> then the L<Parcel::Track>
constructor will refuse to use your class as a driver.


=attr id

Returns tracking number.


=method uri

Returns official link to track parcel.


=method track

Returns C<HASHREF> which contains information of tracking the parcel.
C<HASHREF> MUST contain following key and value pairs.

=for :list
* C<from>: C<SCALAR>.
* C<to>: C<SCALAR>.
* C<result>: C<SCALAR>.
* C<htmls>: C<ARRAYREF>.
* C<descs>: C<ARRAYREF>.
