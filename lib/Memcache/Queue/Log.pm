package Memcache::Queue::Log;
use Moose;
use Log::Dispatch;
use UNIVERSAL::require;

with qw/ Memcache::Queue::Role::Log /;

has 'dispatch_conf' => (
    is => 'ro',
    isa => 'HashRef',
    required => 1,
);

has 'dispatch' =>(
    is => 'ro',
    isa => 'Log::Dispatch',
    lazy_build => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

sub _build_dispatch{
    my $self  = shift;
    
    my $dispatcher = Log::Dispatch->new;
    my $class = "Log::Dispatch::$self->{dispatch_conf}->{class}";
    $class->use or die $@;
    $dispatcher->add(
       $class->new( %{ $self->{dispatch_conf}->{attribute} })
    ) or die $@;
   
    return $dispatcher;
};


sub output{
    my ($self, $job , $e) = @_;

    $self->dispatch->log(level => 'error', message => $e );
}

1;
