#!/usr/bin/perl

use LWP::UserAgent;
use JSON::PP;

# For SSL
#$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my $url = "http://api.metascan.io/v1/check/json";

$query = $url . "/74.125.83.53";

print "LWP::UserAgent query ...\n";

my $ua = LWP::UserAgent->new;
$ua->env_proxy;

my $response = $ua->get($query);

print "HTTP response code was: ", $response->status_line, "\n";

print "Content was:\n", $response->content, "\n";

print "LWP::Simple query ...\n";

use LWP::Simple qw( get );
use JSON::PP qw( decode_json );

$json = get($query);

print $json;

my $decoded_json = JSON::PP::decode_json( $json );

print $decoded_json;

print "\nResult:";

if($decoded_json->{'results'}[0]->{'found'} eq "true")	{
	print "HIT\n";
} else {
	print "MISS\n";
}

print "\n";


##
