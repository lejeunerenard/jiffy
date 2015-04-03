package App::Jiffy::TimeEntry;

use strict;
use warnings;

use Scalar::Util qw( blessed );
use MongoDB;
use MongoDB::OID;

use Moo;

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
   default => sub {
     DateTime->now();
   },
);

has title => (
   is  => 'rw',
   required => 1,
);

has cfg => (
  is => 'ro',
);

=head2 db

C<db> get the db handler from MongoDB

=cut

sub db {
  my $self = shift;
  my $client = MongoDB::MongoClient->new;
  return $client->get_database( $self->cfg->{db} || 'jiffy' );
}

=head2 save

C<save> will commit the current state of the C<TimeEntry> to the database.

=cut

sub save {
   my $self = shift;
   my $_id = $self->id;
   my $document = {
     start_time => $self->start_time,
     title =>$self->title,
   };
   if ( $_id ) {
     # Update the existing record
     $self->db->get_collection('timeEntry')->update( { _id => $self->id  }, { '$set' => $document  }  );
   } else {
     # Insert new record
     $_id = $self->db->get_collection('timeEntry')->insert($document);
     # Update id
     $self->id($_id);
   }
}

=head2 find

C<find> will return a single document. The query will use the provided C<_id>.

=cut

sub find {
  my $cfg = shift;
  my $_id = shift;

  my $client = MongoDB::MongoClient->new;
  my $entry = $client->get_database( $cfg->{db} )->get_collection('timeEntry')->find_one({ _id => $_id });
  return unless $entry;
  return App::Jiffy::TimeEntry->new(
    id => $entry->{_id},
    title => $entry->{title},
    start_time => $entry->{start_time},
    cfg => $cfg,
  );
}
1;
