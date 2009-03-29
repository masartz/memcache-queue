package Memcache::Queue::Manager;

use Moose;
use Memcache::Queue::Log;
has 'logger' => (
    is      => 'ro' , 
    does    => 'Memcache::Queue::Log',
    default => sub { 
        Memcache::Queue::Log->new(
            dispatch_class => 'Screen',
            dispatch_conf  => {
                name      => 'TestLogger',
                min_level => 'debug',
                stderr    => 0,
            },
        );
    },
);

use MooseX::WithCache;
with_cache 'cache' => (
    backend => 'Cache::Memcached',
);
no MooseX::WithCache;

__PACKAGE__->meta->make_immutable;
no Moose;

use UNIVERSAL::require;
use constant {
    QUEUE_EXPIRE => (60 * 60 ),
    CLASS_CNT_EXPIRE => (60 * 60 * 24),
};

sub enqueue{
    my ($self, $work_class , $arg) = @_;

    my $cnt = $self->_assign_cnt( $work_class );

    my $key = $self->_make_key( $work_class , $cnt );

    $self->cache_set( $key , $arg , QUEUE_EXPIRE );

    return $cnt;

}

sub _get_cnt{
    my ($self, $work_class ) = @_;

    return $self->cache_get( $work_class );
}

sub _assign_cnt{
    my ($self, $work_class ) = @_;

    my $max_cnt = $self->_get_cnt( $work_class );

    my $key_cnt = $max_cnt ? ++$max_cnt : 1;

    $self->cache_set( $work_class ,  $key_cnt , CLASS_CNT_EXPIRE );

    return $key_cnt;
}

sub _make_key{
    my ($self, $work_class , $cnt ) = @_;

    return sprintf("%s_%s" , $work_class , $cnt );
}


sub work_start{
    my ($self, $work_class) = @_;

    $work_class->use() or die;

    my $cnt = $self->_get_cnt( $work_class );
    
    while(1){
        my $key = $self->_make_key($work_class, $cnt);
        my $arg = $self->cache_get( $key );

        last if ! $arg;

        $self->cache_del( $key );

        $work_class->work_safely( $self , $arg );

        $cnt--;
    }

    return 1;

}

sub job_failed{
    my ($self, $job , $exception) = @_;

    $self->logger->output( $job , $exception );

}

1;
