package App::Jiffy::TimeEntry;

use strict;
use warnings;

use Moo;
use Scalar::Util qw( blessed );

has id => (
   is    => 'rw',
   isa => sub {
      die 'id must be a MongoDB::OID' unless blessed $_[0] and $_[0]->isa('MongoDB::OID');
   },
);


has start_time => (
   is  => 'rw',
   isa => sub {
      die 'start_time is not a DateTime object' unless blessed $_[0] and $_[0]->isa('DateTime');
   },
);

has title => (
   is  => 'rw',
   isa => sub {
   },
   required => 1,
);

=head2 save

C<save> will commit the current state of the C<TimeEntry> to the database.

=cut

sub save {
   my $self = shift;
   my $_id = $self->id;
   if ( $_id ) {
      # Update the existing record
   } else {
      # Insert new record
   }
}
1;

__END__
