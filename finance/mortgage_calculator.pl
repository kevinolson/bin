#!/usr/bin/env perl

# ==============================================================================
# PROGRAM : mortgage_calculator.pl
# CREATOR : Kevin Olson <kolson@rent.com>
# DESCRIPTION : command line mortgage calculater
# ==============================================================================
=head1 NAME

F<mortgage_calculator.pl>

=head1 SYNOPSIS

    mortgage_calculator.pl [opts]

=head1 OPTIONS

    --apr           The annual percent rate of the loan. Defaults to 6.5%
    --years         The total time, in years, of the loan. Defaults to 30
                    years.
    --amount        The total amount of the loan. Defaults to 200000.
    --payment       With this option you will find out how much of a loan you
                    can get give a payment, years, and apr. Defaults to 0.
    --help          Print out the help man page for the tool and exits.
    -               Print out the short help for the tool and exits.

=head1 DESCRIPTION

A mortgage calculator to display monthly payment, does not include taxes or
insurance. Also can be used to figure out how much you can afford based on a
payment. Once again, this excludes taxes or insurance.

=head1 EXAMPLES

    mortgage_calculator.pl
    mortgage_calculator.pl --amount 100000 --years 15 --apr 4.25
    mortgage_calculator.pl --payment 2500  --apr 4

=head1 AUTHOR

Kevin Olson <kolson@rent.com>

=cut

# ==============================================================================

use strict;
use warnings;

use feature qw(say);

use Getopt::Long;
use Pod::Usage;

# ==============================================================================

# ------------------------------------------------------------------------------
# Name: _findPayment
# Input: $apr, $amount, $rate, $n
# Return: $payment
# Description: Take the inputed values and will use an algorhythm to find the
# mortgage monthly payment
# ------------------------------------------------------------------------------
sub _findPayment {
    my ( $apr, $amount, $rate, $n ) = @_;

    # Math to find the monthly payment of a loan
    # PMT = ((rate)*PV)/(1-((1+(rate))^(-n)))
    my $payment = ( ( $rate ) * $amount )/
                  ( 1 - ( ( 1 + ( $rate ) ) ** ( -$n ) ) );

    $payment = sprintf '%.0f', $payment;

    return $payment;
}

# ------------------------------------------------------------------------------
# Name: _findMortgage
# Input: $apr, $payment, $rate, $n
# Return: $payment
# Description: Take the inputed values and will use an algorhythm to find the
# total mortgage amount
# ------------------------------------------------------------------------------
sub _findMortgage {
    my ( $apr, $payment, $rate, $n ) = @_;

    # Find how much I can borrow based off the payment and rate amount
    # Use the PV function. For your example it would be
    # Rate: 5%  Years: 5  Payment: $500
    # PV = PMT*(1-(1/(1+(RATE^n))))/RATE
    # and you could borrow $26,495.35
    my $amount = $apr > 0
               ? $payment*(1-(1/(1+($rate))**$n))/$rate
               : $payment*$n;

    $amount = sprintf '%.0f', $amount;

    return $amount;
}

# ------------------------------------------------------------------------------
# Name: _makepretty()
# Input: $money
# Return: $money
# Description: changes numeric to two point decimals and if currency adds
# commas
# ------------------------------------------------------------------------------
sub _makepretty {
    my ( $money ) = @_;

    return unless $money;

    while ( $money =~ s/(.*\d)(\d\d\d)/$1,$2/ ) {};
    
    return '$'.$money;
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

    my $amount  = 200000;
    my $years   = 30;
    my $apr     = 6.5;
    my $payment = 0;

    if (
        !GetOptions(
            ''          => \$shorthelp,
            'help'      => \$help,
            'amount=s'  => \$amount,
            'years=s'   => \$years,
            'apr=s'     => \$apr,
            'payment=s' => \$payment,
        )
      )
    {
        pod2usage(
            -exitval => 2,
            -verbose => 1,
        );
    }

    # Print out the POD information
    pod2usage(-verbose => 1) if ($shorthelp);
    pod2usage(-verbose => 2) if ($help);

    # Clean up potential problems
    $amount =~ s/,//g;
    $amount =~ s/\$//g;
    $payment =~ s/,//g;
    $payment =~ s/\$//g;
    $apr =~ s/%//;

    return {
        payment => $payment,
        amount  => $amount,
        years   => $years,
        apr     => $apr,
    };
}

# ==============================================================================

# ------------------------------------------------------------------------------
# Name: main()
# Input: none
# Return: none
# Description: The main function of <mortgage_calculator.pl>
# ------------------------------------------------------------------------------
sub main {

    my $args = _parseArgs();

    my $apr     = $args->{apr};
    my $years   = $args->{years};
    my $amount  = $args->{amount};
    my $payment = $args->{payment}; 

    # This assumes that we are given the number in years
    my $n = $years * 12;
    # This assumes that the apr needs to be turned into decimal and get the
    # rate per month
    my $rate = $apr > 0 ? $apr/100/12 : 0;

    if ( $payment ) {
        $amount = _findMortgage($apr,$payment,$rate,$n);
    }
    else {
        $payment = _findPayment($apr,$amount,$rate,$n);
    }

    my $down_20 = sprintf '%.0f', $amount * .20;
    my $down_03 = sprintf '%.0f', $amount * .035;

    say '-'x72;
    say '| LOAN AMOUNT   | % DOWN | AMOUNT DOWN   | PAYMENT    | APR %  | YEARS |';
    say '-'x72;
    printf "| %-13s | %-6s | %-13s | %-10s | %-6s | %-5s |\n",  _makepretty($amount),
        '0 %', '$0.00', _makepretty($payment), "$apr %", $years;
    say '-'x72;
    printf "| %-13s | %-6s | %-13s | %-10s | %-6s | %-5s |\n",  _makepretty($amount-$down_03),
       '3.5 %',  _makepretty($down_03), _makepretty(_findPayment($apr,($amount-$down_03),$rate,$n)),
        "$apr %", $years;
    say '-'x72;
    printf "| %-13s | %-6s | %-13s | %-10s | %-6s | %-5s |\n",  _makepretty($amount-$down_20),
        '20 %', _makepretty($down_20),  _makepretty(_findPayment($apr,($amount-$down_20),$rate,$n)),
        "$apr %", $years;
    say '-'x72;

    return;
}

# ==============================================================================

main();
