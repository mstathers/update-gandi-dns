#!/usr/bin/env perl
# Gandi DNS Registrar API script to update IPv4 A records
#
# http://www.gandi.net/
# http://doc.rpc.gandi.net/domain/usage.html

use warnings;
use strict;
use XML::RPC;
use Data::Validate::Domain;
use Getopt::Long;
use Data::Dumper;

sub print_usage() {
    print "\nThis script is used to update a DNS record of a hostname via the Gandi API.
Usage: $0 <-h hostname> <-d domain> <-i ipv4_address>
eg: $0 -h www -d yourdomain.com -i 192.0.2.1\n";
    exit;
}

# Open "./gandi_api_key" control file, validates input and saves to $apikey.
open(my $fh, "<",  "gandi_api_key")
    or die "Error: $!\n";
my $apikey;
while (<$fh>) {
    chomp($_);
    if ($_ !~ m/^[0-9A-Za-z]{24}$/) {
       die "Error: Not a valid Gandi API Key, check for whitespace.\n"
    }
    $apikey = $_;
}
close($fh);

# Get arguments
my $hostname;
my $domain;
my $ip;
GetOptions (
    "hostname=s"    =>  \$hostname,
    "domain=s"      =>  \$domain,
    "ip-address=s"  =>  \$ip
) or print_usage();

# Did we get arguments?
if (! defined($hostname)) {
    print "ERROR: Which hostname?\n";
    print_usage()
}
if (! defined($domain)) {
    print "ERROR: Which domain?\n";
    print_usage()
}
if (! defined($ip)) {
    print "ERROR: Which IP?\n";
    print_usage()
}

# create domain validator
my $domain_validator = Data::Validate::Domain->new();
# validate the hostname
if (! $domain_validator->is_hostname($hostname)) {
    print "ERROR: $hostname is not a valid domain, please retry.\n";
    print_usage();
}
# validate the domain
if (! $domain_validator->is_domain($domain)) {
    print "ERROR: $domain is not a valid domain, please retry.\n";
    print_usage();
}
# validate the IP address
if ($ip !~ m/([0-9]{1,3}\.){3}[0-9]{1,3}/) {
    print "ERROR: $ip is not a valid IPv4 address, please retry.\n";
    print_usage();
}


# TODO Setup API
# LIVE API
#my $api = XML::RPC->new('https://rpc.gandi.net/xmlrpc/') or die "Error: $!";
# TESTING API
#my $api = XML::RPC->new('https://rpc.ote.gandi.net/xmlrpc/') or die "Error: $!";

# Retrieve zoneid given $domain
#if (!$api->call( 'domain.info', $apikey, $domain)) {
#    die "API CALL ERROR: $!";
#} 
#my $zoneid = $domain_info->{zoneid};
