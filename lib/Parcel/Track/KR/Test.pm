package Parcel::Track::KR::Test;
# ABSTRACT: Parcel::Track driver for the Regional-Class Test

use utf8;

use Moo;

our $VERSION = '0.001';

with 'Parcel::Track::Role::Base';

use Encode qw( encode_utf8 );

our $URI = 'http://kr-test?tracking_number=%s';

sub BUILDARGS {
    my ( $class, @args ) = @_;

    my %params;
    if ( ref $args[0] eq 'HASH' ) {
        %params = %{ $args[0] };
    }
    else {
        %params = @args;
    }
    $params{id} =~ s/\D//g;

    return \%params;
}

sub uri { sprintf( $URI, $_[0]->id ) }

sub track {
    my $self = shift;

    my %result = (
        from   => encode_utf8(q{김도형}),
        to     => encode_utf8(q{CPAN}),
        result => encode_utf8(q{2015.01.27 도착}),
        htmls  => [
            encode_utf8(q{<div>더미 1</div>}), encode_utf8(q{<div>더미 2</div>}),
            encode_utf8(q{<div>더미 3</div>}),
        ],
        descs => [
            encode_utf8(q{2015.01.24. 17:34 접수}),
            encode_utf8(q{2015.01.25. 09:00 광진지점}),
            encode_utf8(q{2015.01.25. 13:01 상차}),
            encode_utf8(q{2015.01.26. 15:23 하차}),
            encode_utf8(q{2015.01.27. 10:45 강동지점}),
            encode_utf8(q{2015.01.27. 16:13 배송완료}),
        ],
    );

    return \%result;
}

sub clear { 1 }

1;

# COPYRIGHT

__END__

=for Pod::Coverage BUILDARGS

=head1 SYNOPSIS

    # create a testing tracker
    my $tracker = Parcel::Track->new( 'KR::Test', '64537-0301-2020' );

    # get the tracking number
    say $tracker->id;

    # get the tracking information official uri
    say $tracker->uri;

    # get the tracking information
    my $info = $tracker->track;
    say $info->{from};
    say $info->{to};
    say $info->{result};
    say for @{ $info->{descs} };
    say for @{ $info->{htmls} };


=head1 DESCRIPTION

This module is a Parcel::Track driver for the Regional-Class Test.
Except for the name, it is otherwise identical to L<Parcel::Track::Test>.


=attr id

=method uri

=method track

=method clear
