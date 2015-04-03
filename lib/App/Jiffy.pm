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

sub add_entry {
  my $self = shift;
  my $title = shift;

  # Create and save Entry
  App::Jiffy::TimeEntry->new(
    title => $title,
    cfg => $self->cfg,
  )->save;
}

sub run {
  my $self = shift;
  my @args = @_;

  $self->add_entry(join ' ' , @_);
}

1;
__END__

=encoding utf-8

=head1 NAME

App::Jiffy - A minimalist time tracking app focused on precision and effortlessness.

=head1 SYNOPSIS

  use App::Jiffy;

  # cmd line tool
  jiffy Solving world hunger
  jiffy Cleaning the plasma manifolds

=head1 DESCRIPTION

App::Jiffy's philosophy is that you should have to do as little as possible to track your time. Instead you should focus on working. App::Jiffy also focuses on precision. Many times time tracking results in globbing activities together masking the fact that your 5 hours of work on project "X" was actually 3 hours of work with interruptions from your coworker asking about project "Y".

In order to be precise with as little effort as possible, App::Jiffy will be available via a myriad of mediums and devices but will have a central server to combine all the information. Plans currently include the following applications:

=over

=item Command line tool

=item Web app

=item iPhone app ( potentially )

=back

=head2 add_entry

C<add_entry> will create a new TimeEntry with the current time as the entry's start_time.

=cut

=head2 run

C<run> will start an instance of the Jiffy app.

=cut

=head1 AUTHOR

Sean Zellmer E<lt>sean@lejeunerenard.comE<gt>

=head1 COPYRIGHT

Copyright 2015- Sean Zellmer

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
