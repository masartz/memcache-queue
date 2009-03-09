use strict;
use warnings;

use Test::More tests => 3;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;

# memcache clear
{
    use Cache::Memcached;
    my $mem = Cache::Memcached->new({
        servers => 'localhost:11211'
    });
    $mem->flush_all();
}

my $mem_q = Memcache::Queue->new();
isa_ok( $mem_q , 'Memcache::Queue' , 'object new OK');
can_ok( $mem_q , qw/ manager / );

my $manager = $mem_q->manager;

$manager->enqueue('Worker::Test', {'arg'=>'TTTEEESSSTTT'} );
stdout_is( sub { $manager->work_start( 'Worker::Test' );  } , 'TTTEEESSSTTT');


package Worker::Test;
use base qw/ Memcache::Queue::Worker /;

sub work {
    my ($class, $job) = @_;

    print STDOUT $job->{arg};

    return 1;
}
