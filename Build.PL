use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'TV::ProgrammesSchedules::BBC',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/TV/ProgrammesSchedules/BBC.pm',
    add_to_cleanup    => [ 'TV-ProgrammesSchedules-BBC-*' ],    
    build_requires    => {
        'Test::More'      => 0,
        'Readonly'        => '1.03',
        'Time::localtime' => '1.02',
        'HTTP::Request'   => '1.40',
        'LWP::UserAgent'  => '2.33',
    },
);

$builder->create_build_script();