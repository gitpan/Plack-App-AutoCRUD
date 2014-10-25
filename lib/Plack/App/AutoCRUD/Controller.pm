package Plack::App::AutoCRUD::Controller;

use 5.010;
use strict;
use warnings;

use Moose;
use Time::HiRes qw/time/;
use namespace::clean -except => 'meta';


has 'context' => (is => 'ro', isa => 'Plack::App::AutoCRUD::Context',
                  required => 1,
                  handles => [qw/app config dir logger datasource/]);


sub respond {
  my ($self) = @_;

  # compute response data
  my $t0   = time;
  my $data = $self->serve();
  my $t1   = time;

  # record processing time
  my $context = $self->context;
  $context->set_process_time($t1-$t0);

  # render through view
  my $view = $context->view;
  return $view->render($data, $context);
}


sub serve {
  die "attempt to serve() from abstract class Controller.pm";
}


sub redirect {
  my ($self, $url) = @_;

  my $context    = $self->context;
  my $view_class = $context->app->find_class("View::Redirect")
    or die "no Redirect view";
  $context->set_view($view_class->new);
  return $url;
}



1;

__END__


=head1 NAME

Plack::App::AutoCRUD::Controller - parent class for controllers

=head1 DESCRIPTION

Parent class for all controllers

=head1 METHODS

=head2 respond

Calls the L</serve> method to build response data; then calls the
L<Plack::App::AutoCRUD::View/render> method within the appropriate
view to build the Plack response.

=head2 serve

Abstract method (to be redefined in subclasses);
should return the datastructure to be passed to the
L<Plack::App::AutoCRUD::View> class.

=head2 redirect

  $controller->redirect($url);

Convenience method to redirect to another URL.
Sets the C<view> attribute in L<Plack::App::AutoCRUD::Context>
to an instance of L<Plack::App::AutoCRUD::View::Redirect>;
then returns the given URL.


