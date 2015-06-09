#!/usr/bin/env perl

# ==============================================================================
# PROGRAM : compound_interest.pl
# CREATOR : Kevin Olson <kolson@rent.com>
# DESCRIPTION : <short description>
# ==============================================================================
=head1 NAME

F<compound_interest.pl>

=head1 SYNOPSIS

    compound_interest.pl [opts]

=head1 OPTIONS

    --apr           the annual percentage return, defaults at 5.00%
    --apr_year      the rate, in years, the apr will accrue. Defaults to every
                    month if not used.
    --start_amount  the base dollar amount that earns the APR, default at $10,000
    --addon_monthly the amount that is added per month to the start_amount,
                    default at 0
    --years         the amount in years to run the calculations, defaults at
                    10 years
    --help          Print out the help man page for the tool, and exits

=head1 DESCRIPTION

This is a simple compound interest calculator that hows the interests earn and
the growth of money through time.

=head1 EXAMPLES

    compound_interest.pl
    compound_interest.pl --addon_monthly 1000
    compound_interest.pl --addon_monthly 1000 --years 25
    compound_interest.pl --apr 3.5 --addon_monthly 100 
    compound_interest.pl --start 10 -apr 25 --years 50 --apr_year 4

=head1 AUTHOR

Kevin Olson <kolson@rent.com>

=cut

# ==============================================================================

use strict;
use warnings;

use feature qw(say);

use Getopt::Long;
use Log::Log4perl qw(:easy);
use Pod::Usage;
use POSIX qw(strftime);

# ==============================================================================

# ------------------------------------------------------------------------------
# Name: _makepretty()
# Input: $year, $start, $int, $add
# Return: $year, $start, $int, $add
# Description: changes numeric to two point decimals and if currency adds
# commas
# ------------------------------------------------------------------------------
sub _makepretty {
    my ( $year, $start, $int, $add ) = @_;

    if ( $start ) {
        my ($char, $num) = $start =~ m/^(.)(\d+([.]\d{1,2})?)$/;
        $num = sprintf '%.2f', $num;
        if ( $char eq '$' ) {
            while ( $num =~ s/(.*\d)(\d\d\d)/$1,$2/ ) {};
        }
        $start = "$char$num";
    }

    if ( $int ) {
        my ($char, $num) = $int =~ m/^(.)(\d+([.]\d{1,2})?)$/;
        if ( $num ) {
            $num = sprintf '%.2f', $num;
            if ( $char eq '$' ) {
                while ( $num =~ s/(.*\d)(\d\d\d)/$1,$2/ ) {};
            }
            $int = "$char$num";
        }
    }

    if ( $add ) {
        my ($char, $num) = $add =~ m/^(.)(\d+([.]\d{1,2})?)$/;
        $num = sprintf '%.2f', $num;
        if ( $char eq '$' ) {
            while ( $num =~ s/(.*\d)(\d\d\d)/$1,$2/ ) {};
        }
        $add = "$char$num";
    }


    return $year, $start, $int, $add;
}

# ------------------------------------------------------------------------------
# Name: _parseArgs()
# Input: none
# Return: $args - a hash of the arguments parsed
# Description: The method for parsing all of the users arguments and ensuring
#              that they are usuable.
# ------------------------------------------------------------------------------
sub _parseArgs {

    my $help;
    my $shorthelp;

    my $apr = 5;
    my $add = 0;
    my $year = strftime( '%Y', localtime);
    my $start = 10000;
    my $years = 10;
    my $apr_year;

    if (
        !GetOptions(
            ''                => \$shorthelp,
            'help'            => \$help,
            'apr=s'           => \$apr,
            'years=s'         => \$years,
            'apr_year=s'      => \$apr_year,
            'start_amount=s'  => \$start,
            'addon_monthly=s' => \$add,
        )
      )
    {
        pod2usage(
            -exitval => 2,
            -verbose => 1,
        );
    }

    # Print out the POD information
    pod2usage(-verbose => 2) if ($help);
    pod2usage(-verbose => 1) if ($shorthelp);

    return {
        year     => $year,
        add      => $add,
        apr      => $apr,
        start    => $start,
        years    => $years,
        apr_year => $apr_year,
    };
}

# ==============================================================================

# ------------------------------------------------------------------------------
# Name: main()
# Input: none
# Return: none
# Description: The main function of <compound_interest.pl>
# ------------------------------------------------------------------------------
sub main {

    my $args = _parseArgs();

    my $apr      = $args->{apr};
    my $add      = $args->{add};
    my $year     = $args->{year};
    my $start    = $args->{start};
    my $years    = $args->{years};
    my $apr_year = $args->{apr_year};

    my $line = "------------------------------------------------------------------\n";
    # Print the headers for our compound report
    print $line;
    say   'Year |   Balance          |   Interest     |   New Balance';
    print $line;
    printf  "%-8s %-20s \@ %-14s %-5s per month\n", _makepretty($year, '$'.$start, '%'.$apr, '$'.$add);
    print $line;

    for my $i ( 1..$years ) {
        my $orig = $start;
    
        # Try using this instead to see why this line looks so complex:
        # $interest = ($apr / 100) * $nest_egg
        my $interest = 0;

        if ( $apr_year ) {
            if ( $i % $apr_year == 0 ) {
                $interest = int (($apr/100) * $start * 100) / 100;
                $start += $interest+$add;
            }
        }
        else {
            my $monthly_apr = $apr > 0 ? (($apr/100)/12) : 0;
            for my $y ( 1..12 ) {
                my $mon_interest = int ($monthly_apr * $start * 100) / 100;
                $start += $mon_interest+$add;
                $interest += $mon_interest;
            }
        }

        $start = sprintf '%.2f', $start;
        $year++;

        printf "%-8s %-20s %-16s %-20s\n", _makepretty($year, '$'.$orig, '$'.$interest, '$'.$start);
    }

    print $line;
    printf  "%-46s %-20s\n", _makepretty($year, '$'.$start);
    print $line;

    return;
}

# ==============================================================================

main();
