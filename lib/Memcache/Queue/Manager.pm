package Memcache::Queue::Manager;

use Moose;
use Memcache::Queue::Log;
has 'logger' => (
    is      => 'ro' , 
    isa     => 'Memcache::Queue::Log',
    lazy_build => 1,
);
has 'log_conf' =>(
    is       => 'rw',
    isa      => 'HashRef',
    default  => sub{
        +{
            class     => 'Screen',
            attribute => {
                name      => 'Mem-Queue-Logger',
                min_level => 'debug',
                stderr    => 0,
            }
        }
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

sub _build_logger{
    my $self = shift;
    
    my $logger = Memcache::Queue::Log->new(
        dispatch_conf => $self->log_conf
    );
    return $logger;
}

sub enqueue{
    my ($self, $work_class , $arg) = @_;

    my $cnt = $self->_assign_cnt( $work_class );

    my $key = $self->_make_key( $work_class , $cnt );

    $self->cache_set( $key , $arg , QUEUE_EXPIRE );

    return $cnt;
}

sub dequeue{
    my ($self, $work_class , $cnt) = @_;

    my $key = $self->_make_key( $work_class , $cnt );

    $self->cache_del( $key );

    return 1;
}

sub _make_current_key{
    my ($self, $work_class ) = @_;

    return sprintf("%s", $work_class);
}

sub _get_current_cnt{
    my ($self, $work_class ) = @_;

    my $current_key = $self->_make_current_key($work_class);
    return $self->cache_get( $current_key );
}

sub _update_current_cnt{
    my ($self, $work_class , $cnt) = @_;

    my $current_key = $self->_make_current_key($work_class);
    $self->cache_set( $current_key , $cnt , CLASS_CNT_EXPIRE);
    return ;
}


sub _make_done_key{
    my ($self, $work_class ) = @_;

    return sprintf("%s_done" , $work_class);
}

sub _get_done_cnt{
    my ($self, $work_class ) = @_;

    my $done_key = $self->_make_done_key($work_class);
    return $self->cache_get( $done_key );
}

sub _update_done_cnt{
    my ($self, $work_class , $cnt) = @_;

    my $done_key = $self->_make_done_key($work_class);
    $self->cache_set( $done_key , $cnt , CLASS_CNT_EXPIRE);
    return ;
}

sub _assign_cnt{
    my ($self, $work_class ) = @_;

    my $max_cnt = $self->_get_current_cnt( $work_class );

    my $key_cnt = $max_cnt ? ++$max_cnt : 1;

    $self->_update_current_cnt( $work_class , $key_cnt );

    return $key_cnt;
}

sub _make_key{
    my ($self, $work_class , $cnt ) = @_;

    return sprintf("%s_%s" , $work_class , $cnt );
}


sub work_start{
    my ($self, $work_class) = @_;

    $work_class->use() or die;

    my $done_cnt = $self->_get_done_cnt( $work_class ) || 1;
    
    while(1){
        last if $done_cnt > ($self->_get_current_cnt($work_class) || 0);

        my $key = $self->_make_key($work_class, $done_cnt);
        my $arg = $self->cache_get( $key );

        if( $arg ){
            $self->cache_del( $key );

            $work_class->work_safely( $self , $arg );
        }

        $self->_update_done_cnt($work_class , $done_cnt);
        $done_cnt++;
    }

    return 1;

}

sub job_failed{
    my ($self, $job , $exception) = @_;

    $self->logger->output( $job , $exception );

}

1;
