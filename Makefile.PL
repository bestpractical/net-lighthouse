use inc::Module::Install;

name     'Net-Lighthouse';
all_from 'lib/Net/Lighthouse.pm';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

requires 'Any::Moose';
requires 'Params::Validate';
requires 'XML::Simple';
requires 'LWP';
requires 'MIME::Base64';
requires 'YAML::Syck';
requires 'DateTime';

test_requires 'Test::More';
test_requires 'Test::Mock::LWP';

auto_install;

WriteAll;

