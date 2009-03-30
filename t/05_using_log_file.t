use strict;
use warnings;

use Test::More tests => 1;
use File::Temp; 
use IO::All;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::05_Log_File';

# memcache clear
Memcache::Queue::Test::init_memcache();

my $DIR    = '/tmp';
my $FILE   = '05_testXXXX';
my $SUFFIX = '.txt';
my $tmp = File::Temp->new( UNLINK=>1,DIR => $DIR , TEMPLATE => $FILE , SUFFIX => $SUFFIX );
my $filename  = $tmp->filename;

my %conf_hash = (
    class => 'File',
    attribute  => {
        name      =>'test05',
        filename  => $filename,
        min_level => 'debug', 
        stderr    => 1, 
        mode      => 'append'
    },
);
my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager();
$manager->log_conf(\%conf_hash);

# single enqueue
{
    $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    $manager->work_start( $TEST_CLASS );
}

like( io($filename)->all , qr/^$TEST_CLASS ERROR !!!/ , 'File output OK');

1;
