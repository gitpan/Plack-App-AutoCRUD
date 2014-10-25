package Plack::App::AutoCRUD::View::TT;

use 5.010;
use strict;
use warnings;

use Moose;
extends 'Plack::App::AutoCRUD::View';

use Template;
use Encode qw/encode_utf8/;

use namespace::clean -except => 'meta';

has 'tt_args' => ( is => 'bare', isa => 'HashRef', default => sub {{}} );


sub render {
  my ($self, $data, $context) = @_;

  # where to find templates
  my @dirs = map {"$_/templates"} $context->app->share_paths;
  unshift @dirs, $context->dir . "/templates";

  my %tt_args = (
    INCLUDE_PATH => \@dirs,
    PRE_PROCESS  => 'lib/config',
    WRAPPER      => 'lib/site/wrapper',
    ERROR        => 'src/error.tt',
    ENCODING     => 'utf8',
    %{$self->{tt_args}},
   );

  my $renderer = Template->new(%tt_args);
  my $template = $context->template
    or die "no template for TT view";
  $renderer->process("src/$template",
                     {data => $data, c => $context},
                     \my $output)
    or die $renderer->error;

  return [200, ['Content-type'    => 'text/html; charset=utf-8',
                'X-UA-Compatible' => "IE=edge", # enforce latest MSIE rendering
               ],
               [encode_utf8($output)] ];
}

1;


__END__


# code partially borrowed from Catalyst::Helper::View::TTSite
