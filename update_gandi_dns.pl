#!/usr/bin/env perl
# Gandi DNS Registrar API script to update IPv4 A records
#
# http://www.gandi.net/
# http://doc.rpc.gandi.net/domain/usage.html

use warnings;
use strict;

# libraries
use XML::RPC;
use Data::Validate::Domain;
use Getopt::Long;
use File::Basename;

# only used to help with debugging
#use Data::Dumper;

#
# PROGRAM MAIN
#
sub main() {

    # grab the directory path
    my $path = dirname($0);

    # safety check
    if (length($path) < 1) {
        print "Error: unable to determine path.\n";
        exit(1);
    }

    # assemble a path to the necessary gandi API key file
    my $key_path = $path . "/gandi_api_key";

    # safety check
    if (length($key_path) < 1) {
        print "Error: unable to assemble path to gandi api key.\n";
        exit(1);
    }

    # Open "./gandi_api_key" control file, validates input and saves to $apikey.
    open(my $fh, "<",  $key_path)
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


    # Setup api object
    my $api = XML::RPC->new('https://rpc.gandi.net/xmlrpc/') or die "Error: $!";

    # Query for the domain info
    my $domain_info = $api->call( 'domain.info', $apikey, $domain) or die "Error: $!";
    # Grab the zone id for the domain
    my $domain_zone_id = $domain_info->{zone_id};

    # Get more information about the zone
    my $domain_zone_info = $api->call( 'domain.zone.info', $apikey, $domain_zone_id);

    # But we really only need the current version
    my $old_zone_version = $domain_zone_info->{version};

    # NOTE: We cannot simply update the current zone. Instead we must clone the existing zone, edit
    # that clone and then set it as the live version. This is a design of Gandi in which they force
    # you to use a simplified version control. You will find that this same process must be followed
    # if editing zones via their management panel.

    # clone the existing zone so we can work on it
    my $zone_version = $api->call( 'domain.zone.version.new', $apikey, $domain_zone_id);

    # Grab the records from the zone
    # returns: arrayref of hashrefs
    my $zone_info = $api->call( 'domain.zone.record.list', $apikey, $domain_zone_id, $zone_version);

    # we now need to go through the $zone_info
    my $zone_type;
    my $old_zone_id;
    foreach my $hash_key (@$zone_info) {
        # we need the record that we want to change
        if ($hash_key->{'name'} eq $hostname) {
            # grab the record id
            $old_zone_id = {
                'id' => $hash_key->{'id'}
            };
            # grab the record type (NS, A, TXT, MX, etc.)
            $zone_type = $hash_key->{'type'};
        }
    }

    # Setup a structure containing the data for the updated record
    my $new_record_data = {
        'name' => "$hostname",
        'type' => "$zone_type",
        'value' => "$ip"
    };

    # update the record
    my $updated_record = $api->call( 'domain.zone.record.update', $apikey, $domain_zone_id, $zone_version, $old_zone_id, $new_record_data) or die "$!";

    # set our new cloned zone to be current
    my $domain_zone_version_set = $api->call( 'domain.zone.version.set', $apikey, $domain_zone_id, $zone_version) or die "error: $!";

    # delete the old zone version because it is not used anymore
    my $domain_zone_version_delete = $api->call( 'domain.zone.version.delete', $apikey, $domain_zone_id, $old_zone_version) or die "error: $!";
}

# @brief    Prints out the usage instructions, with an error code of 1
#
# @param    string    name of script
#
# @return   none
#
sub print_usage() {
    print "\nThis script is used to update a DNS record of a hostname via " .
          "the Gandi API.\n" .
          "Usage: $0 <-h hostname> <-d domain> <-i ipv4_address>\n" .
          "eg: $0 -h www -d yourdomain.com -i 192.0.2.1\n";
    exit(1);
}

#######
main();
