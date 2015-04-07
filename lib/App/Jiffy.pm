package App::Jiffy;

use strict;
use warnings;

use 5.008_005;
our $VERSION = '0.02';

use App::Jiffy::TimeEntry;
use YAML::Any qw( LoadFile );

use Moo;

has cfg => (
  is  => 'ro',
  default => sub {
    LoadFile($ENV{HOME} . '/.jiffy.yml') || {};
  },
);

has terminator_regex => (
  is => 'ro',
  isa => sub {
    die 'terminator_regex must be a regex ref' unless ref $_[0] eq 'Regexp';
  },
  default => sub {
    qr/^end$|
    ^done$|
    ^eod$|
    ^finished$|
    ^\\\(^\s*\.^\s*\)\/$| # This is a smily face with hands raised
    ^✓$|
    ^x$/x;
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

sub current_time {
  my $self = shift;

  my $duration = App::Jiffy::TimeEntry::last_entry($self->cfg)->duration;

  print '"' . $latest->title . '" has been running for';

  my %deltas = $duration->deltas;
  foreach my $unit ( keys %deltas ) {
    next unless $deltas{$unit};
    print " " . $deltas{$unit} . " ". $unit;
  }
  print ".\n";
}

sub time_sheet {
  my $self = shift;
  my @entries = App::Jiffy::TimeEntry::search(
    $self->cfg,
    query => {
      start_time => { '$gt' => DateTime->now->truncate( to => 'day' ), },
    },
    sort => {
      start_time => 1,
    },
  );

  print "Today's timesheet:\n\n";

  foreach my $entry ( @entries ) {
    next if $entry->title =~ $self->terminator_regex;
    my %deltas = $entry->duration->deltas;
    foreach my $unit ( keys %deltas ) {
      next unless $deltas{$unit};
      print $deltas{$unit} . " ". $unit . " ";
    }
    print "\t " . $entry->title . "\n";
  }
}

sub run {
  my $self = shift;
  my @args = @_;

  if ( $args[0] eq 'current' ) {
    return $self->current_time(@_);
  } elsif ( $args[0] eq 'timesheet' ) {
    return $self->time_sheet(@_);
  }

  return $self->add_entry(join ' ' , @_);
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
  jiffy current # Returns the elapsed time for the current task

  # Run server
  jiffyd
  curl -d "title=Meeting with Client X" http://localhost:3000/timeentry

=head1 DESCRIPTION

App::Jiffy's philosophy is that you should have to do as little as possible to track your time. Instead you should focus on working. App::Jiffy also focuses on precision. Many times time tracking results in globbing activities together masking the fact that your 5 hours of work on project "X" was actually 3 hours of work with interruptions from your coworker asking about project "Y".

In order to be precise with as little effort as possible, App::Jiffy will be available via a myriad of mediums and devices but will have a central server to combine all the information. Plans currently include the following applications:

=over

=item Command line tool

=item Web app L<App::Jiffyd>

=item iPhone app ( potentially )

=back

=head1 INSTALLATION

  curl -L https://cpanmin.us | perl - git://github.com/lejeunerenard/jiffy

=head1 METHODS

The following are methods available on the C<App::Jiffy> object.

=head2 add_entry

C<add_entry> will create a new TimeEntry with the current time as the entry's start_time.

=cut

=head2 current_time

C<current_time> will print out the elapsed time for the current task (AKA the time since the last entry was created).

=cut

=head2 time_sheet

C<time_sheet> will print out a time sheet including the time spent for each C<TimeEntry>.

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
