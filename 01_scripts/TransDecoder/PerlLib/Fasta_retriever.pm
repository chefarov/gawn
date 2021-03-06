package Fasta_retriever;

use strict;
use warnings;
use Carp;
use threads;
use threads::shared;

sub new {
    my ($packagename) = shift;
    my $filename = shift;
    
    unless ($filename) {
        confess "Error, need filename as param";
    }

    my $self = { filename => $filename,
                 acc_to_pos_index => undef,
                 fh => undef,
    };
    
    my %acc_to_pos_index :shared;

    $self->{acc_to_pos_index} = \%acc_to_pos_index;
        
    bless ($self, $packagename);

    $self->_init();


    return($self);
}


sub _init {
    my $self = shift;
    
    my $filename = $self->{filename};
        
    open (my $fh, $filename) or die $!;
    $self->{fh} = $fh;
    while (<$fh>) {
        if (/>(\S+)/) {
            my $acc = $1;
            my $file_pos = tell($fh);
            $self->{acc_to_pos_index}->{$acc} = $file_pos;
        }
    }
    
    return;
}

sub refresh_fh {
    my $self = shift;
    
    open (my $fh, $self->{filename}) or die "Error, cannot open file : " . $self->{filename};
    $self->{fh} = $fh;
    
    return;
}


sub get_seq {
    my $self = shift;
    my $acc = shift;

    unless ($acc) {
        confess "Error, need acc as param";
    }

    my $file_pos = $self->{acc_to_pos_index}->{$acc} or confess "Error, no seek pos for acc: $acc";
    
    my $fh = $self->{fh};
    seek($fh, $file_pos, 0);
    
    my $seq = "";
    while (<$fh>) {
        if (/^>/) {
            last;
        }
        $seq .= $_;
    }

    $seq =~ s/\s+//g;

    return($seq);
}
    
    
    

1; #EOM
    
