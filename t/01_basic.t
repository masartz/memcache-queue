use strict;
use Test::More tests => 7;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;

my $mem_q = Memcache::Queue->new();
isa_ok( $mem_q , 'Memcache::Queue' , 'object new OK');
can_ok( $mem_q , qw/ manager / );

my $manager = $mem_q->manager;
isa_ok( $manager , 'Memcache::Queue::Manager' , 'Manager object OK');
can_ok( $manager , qw/ enqueue dequeue work_once / );

my $cache = $manager->cache;
isa_ok( $cache , 'Cache::Memcached' , 'Cache object OK');
can_ok( $manager , qw/ cache_get cache_set cache_del 
                     cache_get_multi cache_incr cache_decr / );

$manager->enqueue('Worker::Test', {'arg'=>'TTTEEESSSTTT'} );
stdout_is( sub { $manager->work_once( 'Worker::Test' );  } , 'TTTEEESSSTTT');


package Worker::Test;
use base qw/ Memcache::Queue::Worker /;

sub work {
    my ($class, $job) = @_;

    print STDOUT $job->{arg};
#    $job->completed;

    return 1;
}
