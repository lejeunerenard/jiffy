package App::Jiffy;

use strict;
use warnings;

use 5.008_005;
our $VERSION = '0.02';

use App::Jiffy::TimeEntry;
use YAML::Any qw( LoadFile );

use Getopt::Long;
Getopt::Long::Configure("pass_through");

use Moo;

has cfg => (
  is      => 'ro',
  default => sub {
    LoadFile( $ENV{HOME} . '/.jiffy.yml' ) || {};
  },
);

has terminator_regex => (
  is  => 'ro',
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
  my $self    = shift;
  my $options = shift;
  my $title;
  if ( ref $options ne 'HASH' ) {
    $title = $options;
    undef $options;
  } else {
    $title = shift;
  }

  my $start_time;
  my $now = DateTime->now( time_zone => 'local' );

  if ( $options->{time} ) {
    require DateTime::Format::Strptime;

    # @TODO Figure out something more flexible and powerful to get time

    # First try H:M:S
    my $strp = DateTime::Format::Strptime->new(
      pattern   => '%T',
      time_zone => 'local',
    );
    $start_time = $strp->parse_datetime( $options->{time} );

    # If no time found try just H:M
    if ( not $start_time ) {
      my $strp = DateTime::Format::Strptime->new(
        pattern   => '%R',
        time_zone => 'local',
      );
      $start_time = $strp->parse_datetime( $options->{time} );
    }

    # Make sure the date part of the datetime is not set to the
    # beginning of time.
    if ( $start_time and $start_time->year < $now->year ) {
      $start_time->set(
        day   => $now->day,
        month => $now->month,
        year  => $now->year,
      );
    }
  }

  # Create and save Entry
  App::Jiffy::TimeEntry->new(
    title      => $title,
    start_time => $start_time // $now,
    cfg        => $self->cfg,
  )->save;
}

sub current_time {
  my $self = shift;

  my $latest   = App::Jiffy::TimeEntry::last_entry( $self->cfg );
  my $duration = $latest->duration;

  print '"' . $latest->title . '" has been running for';

  my %deltas = $duration->deltas;
  foreach my $unit ( keys %deltas ) {
    next unless $deltas{$unit};
    print " " . $deltas{$unit} . " " . $unit;
  }
  print ".\n";
}

sub time_sheet {
  my $self = shift;
  my $from = shift;

  my $from_date = DateTime->today;

  if ( defined $from ) {
    $from_date->subtract( days => $from );
  }

  my @entries = App::Jiffy::TimeEntry::search(
    $self->cfg,
    query => {
      start_time => { '$gt' => $from_date, },
    },
    sort => {
      start_time => 1,
    },
  );

  if ($from) {
    print "The past " . $from . " days' timesheet:\n\n";
  } else {
    print "Today's timesheet:\n\n";
  }

  my $current_day = $entries[0]->start_time->clone->truncate( to => 'day' );
  if ($from) {
    print "Date: " . $current_day->mdy('/') . "\n";
  }

  foreach my $entry (@entries) {

    # Skip terminators
    next if $entry->title =~ $self->terminator_regex;

    my $start_time = $entry->start_time->clone;

    if (
      DateTime->compare( $current_day, $start_time->truncate( to => 'day' ) )
      == -1 )
    {
      $current_day = $start_time->truncate( to => 'day' );
      print "\nDate: " . $current_day->mdy('/') . "\n";
    }

    # Get the deltas
    my %deltas = $entry->duration->deltas;
    foreach my $unit ( keys %deltas ) {
      next unless $deltas{$unit};
      print $deltas{$unit} . " " . $unit . " ";
    }
    print "\t " . $entry->title . "\n";
  }
}

sub run {
  my $self = shift;
  my @args = @_;

  if ( $args[0] eq 'current' ) {
    shift @args;
    return $self->current_time(@args);
  } elsif ( $args[0] eq 'timesheet' ) {
    shift @args;
    return $self->time_sheet(@args);
  }

  my $p = Getopt::Long::Parser->new( config => ['pass_through'], );
  $p->getoptionsfromarray( \@args, 'time=s' => \my $time, );

  return $self->add_entry( {
      time => $time,
    },
    join ' ',
    @args
  );
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
