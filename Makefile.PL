use inc::Module::Install;

name     'Net-Lighthouse';
all_from 'lib/Net/Lighthouse.pm';
author   'sunnavy <sunnavy@bestpractical.com>';
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

