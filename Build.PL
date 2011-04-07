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
        'Test::More'  => 0,
    },
);

$builder->create_build_script();