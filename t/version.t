# This is a -*- perl -*- test script for checking wether or not different
# distribution files contain the correct version number.
#

use strict;
use warnings;
use version;
use Test::More;
use Module::Build;

plan skip_all => 'For authors only (set PERL5_AUTHOR_TEST to run.)'
    unless $ENV{PERL5_AUTHOR_TEST};

plan tests => 3;

my $current_version = Module::Build->current->dist_version;

file_has_version_string("lib/Acme/Godot.pm",
    "perldoc VERSION statement"
    => qr/This document describes \S+ version ([\d\.]+)/ );


file_has_version_string("Changes",
    "updated revision history" => qr/^([\d\.]+)/);

file_has_version_string("README",
    "statement of purpose" => qr/^Acme-Godot version ([\d\.]+)/);

#
# Methods
#

sub file_has_version_string {
    my ($filename, %regex) = @_;
    open my $fh, "<", $filename
        or die "couldn't open $filename for reading: $!";

    my %succeeded;
    my %failed;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                my $stated_version = version->new($1)
                  || die "Regex in test needs to extract a valid version number\n";
                if ( $stated_version != $current_version ) {
                    push @{$failed{$desc}||=[]}, $.;
                }
                else {
                    push @{$succeeded{$desc}||=[]}, $.;
                }
            }
        }
    }

    if (%failed and ! %succeeded) {
        fail("$filename does not contain expected version string");
        diag "$_ appears on lines @{$failed{$_}}" for keys %failed;
    } else {
        pass("$filename contains all expected version strings");
    }
}
