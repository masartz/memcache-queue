use inc::Module::Install;
name 'Memcached-Queue';
all_from 'lib/Memcached/Queue.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
