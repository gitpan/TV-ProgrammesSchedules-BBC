#!perl

use strict; use warnings;
use TV::ProgrammesSchedules::BBC;
use Test::More tests => 14;

my ($tv);

eval { $tv = TV::ProgrammesSchedules::BBC->new(channel => 'bbcone'); };
like($@, qr/ERROR: Input param has to be a ref to HASH./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({xyz => 'bbcone'}); };
like($@, qr/ERROR: Missing key channel./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcx'}); };
like($@, qr/ERROR: Invalid value for channel./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone'}); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbctwo'}); };
like($@, qr/ERROR: Invalid number of keys found in the input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', xyz => 1}); };
like($@, qr/ERROR: Missing key location./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbctwo', xyz => 1}); };
like($@, qr/ERROR: Missing key location./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 1}); };
like($@, qr/ERROR: Invalid value for location./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', yyyy => 2011}); };
like($@, qr/ERROR: Missing key mm from input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', yyyy => 2011, mm => 4}); };
like($@, qr/ERROR: Missing key dd from input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', mm => 4}); };
like($@, qr/ERROR: Missing key yyyy from input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', yyyy => 2011, mm => 4}); };
like($@, qr/ERROR: Missing key dd from input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', dd => 4}); };
like($@, qr/ERROR: Missing key yyyy from input hash./);

eval { $tv = TV::ProgrammesSchedules::BBC->new({channel => 'bbcone', location => 'london', yyyy => 2011, dd => 11}); };
like($@, qr/ERROR: Missing key mm from input hash./);