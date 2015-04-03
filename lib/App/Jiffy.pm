package App::Jiffy;

use strict;
use warnings;

use 5.008_005;
our $VERSION = '0.01';

use App::Jiffy::TimeEntry;
use YAML::Any qw( LoadFile );

use Moo;

has cfg => (
  is  => 'ro',
  default => sub {
    LoadFile($ENV{HOME} . '/.jiffy.yml') || {};
  },
);

=head2 add_entry

C<add_entry> will create a new TimeEntry with the current time as the entry's start_time.

=cut

sub add_entry {
  my $self = shift;
  my $title = shift;

  # Create and save Entry
  App::Jiffy::TimeEntry->new(
    title => $title,
    cfg => $self->cfg,
  )->save;
}

=head2 run

C<run> will start an instance of the Jiffy app.

=cut

sub run {
  my $self = shift;
  my @args = @_;

  $self->add_entry(join ' ' , @_);
}

1;
__END__

=encoding utf-8

=head1 NAME

App::Jiffy - Blah blah blah

=head1 SYNOPSIS

  use App::Jiffy;

=head1 DESCRIPTION

App::Jiffy is

=head1 AUTHOR

Sean Zellmer E<lt>sean@lejeunerenard.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Sean Zellmer

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
