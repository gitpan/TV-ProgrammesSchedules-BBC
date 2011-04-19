package TV::ProgrammesSchedules::BBC;

use strict; use warnings;

use overload q("") => \&as_string, fallback => 1;

use Carp;
use Readonly;
use Data::Dumper;
use HTTP::Request;
use LWP::UserAgent;
use Time::localtime;

=head1 NAME

TV::ProgrammesSchedules::BBC - Interface to BBC TV Programmes Schedules.

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

Readonly my $BASE_URL => 'http://www.bbc.co.uk';
Readonly my $CHANNELS => 
{
    bbcone     => 'BBC One',
    bbctwo     => 'BBC Two',
    bbcthree   => 'BBC Three',
    bbcfour    => 'BBC Four',
    bbchd      => 'BBC HD',
    cbbc       => 'CBBC',
    cbeebies   => 'CBeebies',
    bbcnews    => 'BBC News Channel',
    parliament => 'BBC Parliament',
    bbcalba    => 'BBC ALBA'
};

Readonly my $LOCATIONS =>
{
    bbcone => { cambridge       => 'Cambridgeshire',
                channel_islands => 'Channel Islands',
                east            => 'East',
                east_midlands   => 'East Midlands',
                hd              => 'HD',
                london          => 'London',
                north_east      => 'North East & Cumbria',
                ni              => 'Northern Ireland',
                oxford          => 'Oxfordshire',
                scotland        => 'Scotland',
                south           => 'South',
                south_east      => 'South East',
                south_west      => 'South West',
                west_midlands   => 'West Midlands',
                east_yorkshire  => 'Yorks & Lincs' },
    bbctwo => { england         => 'England',
                ni              => 'Northern Ireland',
                ni_analogue     => 'Northern Ireland (Analogue)',
                scotland        => 'Scotland',
                wales           => 'Wales',
                wales_analogue  => 'Wales (Analogue)' },
};

=head1 DESCRIPTION

The module  provides  programmes  schedules for BBC One, BBC Two, BBC Three, BBC Four, BBC HD,
CBBC, CBeebies, BBC News, BBC Parliament, BBC ALBA. 

    +----------------+-----------------------------+
    | Name           | Location                    |
    +----------------+-----------------------------+
    | BBC One        | Cambridgeshire              |
    |                | Channel Islands             |
    |                | East                        |
    |                | East Midlands               |
    |                | HD                          |
    |                | London                      |
    |                | North East & Cumbria        |
    |                | Northern Ireland            |
    |                | Oxfordshire                 |
    |                | Scotland                    |
    |                | South                       |
    |                | South East                  |
    |                | South West                  |
    |                | West Midlands               |
    |                | Yorks & Lincs               |
    +----------------+-----------------------------+
    | BBC Two        | England                     |
    |                | Northern Ireland            |
    |                | Northern Ireland (Analogue) |
    |                | Scotland                    |
    |                | Wales                       |
    |                | Wales (Analogue)            |
    +----------------+-----------------------------+
    | BBC Three      | N/A                         |
    +----------------+-----------------------------+
    | BBC Four       | N/A                         |
    +----------------+-----------------------------+
    | BBC HD         | N/A                         |
    +----------------+-----------------------------+
    | CBBC           | N/A                         |
    +----------------+-----------------------------+
    | CBeebies       | N/A                         |
    +----------------+-----------------------------+
    | BBC News       | N/A                         |
    +----------------+-----------------------------+
    | BBC Parliament | N/A                         |
    +----------------+-----------------------------+
    | BBC ALBA       | N/A                         |
    +----------------------------------------------+

=cut

=head1 CONSTRUCTOR

The constructor expects a reference to an anonymous hash as input parameter. Table below shows 
the  possible  value of various key (channel, location, yyyy, mm, dd). The yyyy, mm and dd are 
optional. If missing picks up the current year, month and day.

    +----------------+------------+-----------------+------+----+----+
    | Name           | Channel    | Location        | YYYY | MM | DD |
    +----------------+------------+-----------------+------+----+----+
    | BBC One        | bbcone     | cambridge       | 2011 |  4 |  7 |
    |                |            | channel_islands |      |    |    |
    |                |            | east            |      |    |    |
    |                |            | east_midlands   |      |    |    |
    |                |            | hd              |      |    |    |
    |                |            | london          |      |    |    |
    |                |            | north_east      |      |    |    |
    |                |            | ni              |      |    |    |
    |                |            | oxford          |      |    |    |
    |                |            | scotland        |      |    |    |
    |                |            | south           |      |    |    |
    |                |            | south_east      |      |    |    |
    |                |            | south_west      |      |    |    |
    |                |            | west_midlands   |      |    |    |
    |                |            | east_yorkshire  |      |    |    |
    +----------------+------------+-----------------+------+----+----+
    | BBC Two        | bbctwo     | england         | 2011 |  4 |  7 |
    |                |            | ni              |      |    |    |
    |                |            | ni_analogue     |      |    |    |
    |                |            | scotland        |      |    |    |
    |                |            | wales           |      |    |    |
    |                |            | wales_analogue  |      |    |    |
    +----------------+------------+-----------------+------+----+----+
    | BBC Three      | bbcthree   | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | BBC Four       | bbcfour    | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | BBC HD         | hd         | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | CBBC           | cbbc       | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | CBeebies       | cbeebies   | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | BBC News       | bbcnews    | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | BBC Parliament | parliament | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+
    | BBC ALBA       | bbcalba    | N/A             | 2011 |  4 |  7 |
    +----------------+------------+-----------------+------+----+----+

=cut

sub new
{
    my $class = shift;
    my $param = shift;
    
    _validate_param($param);
    $param->{_browser} = LWP::UserAgent->new();
    unless (defined($param->{yyyy}) && defined($param->{mm}) && defined($param->{dd}))
    {
        my $today = localtime; 
        $param->{yyyy} = $today->year+1900;
        $param->{mm}   = $today->mon+1;
        $param->{dd}   = $today->mday;
    }    
    bless $param, $class;
    return $param;
}

=head1 METHODS

=head2 get_url()

Prepare and return URL using the given information.

    use strict; use warnings;
    use TV::ProgrammesSchedules::BBC;
    
    my $bbc = TV::ProgrammesSchedules::BBC->new({ channel => 'bbcone', location => 'london' });
    print $bbc->get_url();

=cut

sub get_url
{
    my $self = shift;
    my $url  = sprintf("%s/%s/programmes/schedules", $BASE_URL, $self->{channel});
    $url .= '/'. $self->{location} 
        if (defined($self->{location}) && exists($LOCATIONS->{$self->{channel}}->{$self->{location}}));
    $url .= '/'. join("/", $self->{yyyy}, $self->{mm}, $self->{dd}, "ataglance");
    
    return $url;
}

=head2 get_listings()

Return the programmes listings for the given channel and location  (if applicable). Data would
be in the form of reference to a list containing anonymous hash with keys start_time,end_time, 
title and url for each of the programmes.

    use strict; use warnings;
    use TV::ProgrammesSchedules::BBC;
    
    my $bbc = TV::ProgrammesSchedules::BBC->new({ channel => 'bbcone', location => 'london' });
    my $listings = $bbc->get_listings();

=cut

sub get_listings
{
    my $self = shift;
    return $self->{listings} if defined($self->{listings});
        
    my $url      = $self->get_url();
    my $browser  = $self->{_browser};
    my $request  = HTTP::Request->new(GET=>$url);
    my $response = $browser->request($request);
    croak("ERROR: Couldn't connect to [$url].\n") 
        unless $response->is_success;
    
    my ($contents, $listings, $program, $count);
    $contents = $response->content;
    $count    = 0;
    
    foreach (split(/\n/,$contents))
    {
        chomp;
        s/^\s+//g;
        s/\s+$//g;
        next if /^$/;
    
        if (/\<span class=\"starttime\"\>(.*)\<\/span\>\<span class=\"endtime\"\>&#8211\;(.*)\<\/span\>/)
        {
            my($hh,$mm) = split/\:/,$1,2;
            last if ($count > 3 && $hh == 0);
            $program->{start_time} = $1;
            $program->{end_time}   = $2;
        }
        elsif (/class=\"url\" href=\"(.*)\"\>/)
        {
            $program->{url} = $BASE_URL . $1;
        }
        elsif (/class\=\"title\"\>(.*)\<\/span\>/)
        {
            $program->{title} = $1;
            push @$listings, $program if ((defined $program) && scalar(keys %{$program}) == 4);
            $program = undef;
            $count++;
        }
    }
    
    $self->{listings} = $listings;
    return $listings;
}

=head2 as_string()

Returns listings in a human readable format.

    use strict; use warnings;
    use TV::ProgrammesSchedules::BBC;

    my $bbc = TV::ProgrammesSchedules::BBC->new({ channel => 'bbcone', location => 'london' });

    print $bbc->as_string();

    # or even simply
    print $bbc;

=cut

sub as_string
{
    my $self = shift;
    my ($listings);
    
    $self->{listings} = $self->get_listings()
        unless defined($self->{listings});

    foreach (@{$self->{listings}})
    {
        $listings .= sprintf("Start Time: %s\n", $_->{start_time});
        $listings .= sprintf("  End Time: %s\n", $_->{end_time});
        $listings .= sprintf("     Title: %s\n", $_->{title});
        $listings .= sprintf("       URL: %s\n", $_->{url});
        $listings .= "-------------------\n";
    }
    return $listings;
}

sub _validate_param
{
    my $param = shift;
    
    croak("ERROR: Input param has to be a ref to HASH.\n")
        if (ref($param) ne 'HASH');
    croak("ERROR: Missing key channel.\n")
        unless exists($param->{channel});
    croak("ERROR: Invalid value for channel.\n")
        unless exists($CHANNELS->{$param->{channel}});
    croak("ERROR: Missing key mm from input hash.\n")
        if (defined($param->{yyyy}) && !exists($param->{mm}));
    croak("ERROR: Missing key dd from input hash.\n")
        if (defined($param->{yyyy}) && !exists($param->{dd}));
    croak("ERROR: Missing key yyyy from input hash.\n")
        if (defined($param->{mm}) && !exists($param->{yyyy}));
    croak("ERROR: Missing key dd from input hash.\n")
        if (defined($param->{mm}) && !exists($param->{dd}));
    croak("ERROR: Missing key yyyy from input hash.\n")
        if (defined($param->{dd}) && !exists($param->{yyyy}));
    croak("ERROR: Missing key mm from input hash.\n")
        if (defined($param->{dd}) && !exists($param->{mm}));
    my $count = 0;
    $count = 3 if (defined($param->{yyyy}) && defined($param->{mm}) && defined($param->{dd}));    
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($param->{channel} =~ /bbc[one|two]/i) && (scalar(keys %{$param}) != (2+$count)));
    croak("ERROR: Invalid number of keys found in the input hash.\n")
        if (($param->{channel} !~ /bbc[one|two]/i) && (scalar(keys %{$param}) != (1+$count)));
    croak("ERROR: Missing key location.\n")
        if (($param->{channel} =~ /bbc[one|two]/i) && !exists($param->{location}));
    croak("ERROR: Invalid value for location.\n")
        if (($param->{channel} =~ /bbc[one|two]/i) && !exists($LOCATIONS->{$param->{channel}}->{$param->{location}}));
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs/feature  requests  to C<bug-tv-programmesschedules-bbc at rt.cpan.org>, 
or through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=TV-ProgrammesSchedules-BBC>.  
I will be  notified,  and  then you'll automatically be notified of progress on your  bug as I 
make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc TV::ProgrammesSchedules::BBC

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=TV-ProgrammesSchedules-BBC>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/TV-ProgrammesSchedules-BBC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/TV-ProgrammesSchedules-BBC>

=item * Search CPAN

L<http://search.cpan.org/dist/TV-ProgrammesSchedules-BBC/>

=back

=head1 ACKNOWLEDGEMENTS

TV::ProgrammesSchedules::BBC provides  information from BBC official website. This information 
should be used as it is without any modifications. BBC remains the sole owner of the data. The 
terms and condition for Personal and Non-business use can be found here http://www.bbc.co.uk/terms/personal.shtml.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY; 
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

1; # End of TV::ProgrammesSchedules::BBC