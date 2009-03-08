package Memcache::Queue::Manager;

use Moose;
use MooseX::WithCache;

with_cache 'cache' => (
    backend => 'Cache::Memcached',
);


__PACKAGE__->meta->make_immutable;
no Moose;
no MooseX::WithCache;

sub enqueue{
    my ($self, $work_class , $arg) = @_;

    $self->cache_set( $work_class , $arg , 100 );

    return 1;

}

sub dequeue{
    my ($self, $work_class , $arg) = @_;
}

sub work_once{
    my ($self, $work_class) = @_;

    my $arg = $self->cache_get( $work_class );

    return if ! $arg;

    my $work_ret = $work_class->work_safely( $self , $arg );

    if( $work_ret ){
        $self->cache_del( $work_class );
    }

    return 1;

}
1;
