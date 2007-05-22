#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#

package POE::Component::Client::MPD::Playlist;

use strict;
use warnings;

use POE;
use POE::Component::Client::MPD::Message;
use base qw[ Class::Accessor::Fast ];

# -- Playlist: retrieving information

#
# event: pl.as_items()
#
# Return an array of C<POCOCM::Item::Song>s, one for each of the
# songs in the current playlist.
#
sub _onpub_as_items {
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $SEND,
        _commands => [ 'playlistinfo' ],
        _cooking  => $AS_ITEMS,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}


#
# event: pl.items_changed_since( $plversion )
#
# Return a list with all the songs (as POCOM::Item::Song objects) added to
# the playlist since playlist $plversion.
#
sub _onpub_items_changed_since {
    my $plid = $_[ARG0];
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $SEND,
        _commands => [ "plchanges $plid" ],
        _cooking  => $AS_ITEMS,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}


# -- Playlist: adding / removing songs

#
# event: pl.add( $path, $path, ... )
#
# Add the songs identified by $path (relative to MPD's music directory) to
# the current playlist.
# No return event.
#
sub _onpub_add {
    my @pathes   = @_[ARG0 .. $#_];    # args of the poe event
    my @commands = (                   # build the commands
        'command_list_begin',
        map( qq[add "$_"], @pathes ),
        'command_list_end',
    );
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $DISCARD,
        _commands => \@commands,
        _cooking  => $RAW,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}


#
# event: pl.delete( $number, $number, ... )
#
# Remove song $number (starting from 0) from the current playlist.
# No return event.
#
sub _onpub_delete {
    my @numbers  = @_[ARG0 .. $#_];    # args of the poe event
    my @commands = (                   # build the commands
        'command_list_begin',
        map( qq[delete $_], reverse sort {$a<=>$b} @numbers ),
        'command_list_end',
    );
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $DISCARD,
        _commands => \@commands,
        _cooking  => $RAW,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}


#
# event: pl.deleteid( $songid, $songid, ... )
#
# Remove the specified $songid (as assigned by mpd when inserted in playlist)
# from the current playlist.
#
sub _onpub_deleteid {
    my @songids  = @_[ARG0 .. $#_];    # args of the poe event
    my @commands = (                   # build the commands
        'command_list_begin',
        map( qq[deleteid $_], @songids ),
        'command_list_end',
    );
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $DISCARD,
        _commands => \@commands,
        _cooking  => $RAW,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}


#
# event: clear()
#
# Remove all the songs from the current playlist.
#
sub _onpub_clear {
    my $msg = POE::Component::Client::MPD::Message->new( {
        _from     => $_[SENDER]->ID,
        _request  => $_[STATE],
        _answer   => $DISCARD,
        _commands => [ 'clear' ],
        _cooking  => $RAW,
    } );
    $_[KERNEL]->yield( '_send', $msg );
}



# -- Playlist: changing playlist order
# -- Playlist: managing playlists

1;

__END__

=head1 NAME

POE::Component::Client::MPD::Playlist - module handling playlist commands


=head1 DESCRIPTION

C<POCOCM::Playlist> is responsible for handling playlist-related commands.
To achieve those commands, send the corresponding event to the POCOCM
session you created: it will be responsible for dispatching the event
where it is needed.


=head1 PUBLIC EVENTS

The following is a list of general purpose events accepted by POCOCM.


=head2 Retrieving information

=head2 Adding / removing songs

=head2 Changing playlist order

=head2 Managing playlists


=head1 SEE ALSO

For all related information (bug reporting, mailing-list, pointers to
MPD and POE, etc.), refer to C<POE::Component::Client::MPD>'s pod,
section C<SEE ALSO>


=head1 AUTHOR

Jerome Quelin, C<< <jquelin at cpan.org> >>


=head1 COPYRIGHT & LICENSE

Copyright 2007 Jerome Quelin, all rights reserved.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

=cut
