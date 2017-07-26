# <@LICENSE>
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to you under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at:
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# </@LICENSE>

=head1 NAME

Mail::SpamAssassin::Plugin::MetaAssassin - perform metascan tests for spam, bots and abuse.

=head1 SYNOPSIS

  loadplugin     Mail::SpamAssassin::Plugin::MetaAssassin

=head1 DESCRIPTION

This plugin checks an email against the metascan.io API, to prevent
spam, abuse and bots from abusing your mail-server and end user
mailboxes.

=cut

package Mail::SpamAssassin::Plugin::MetaAssassin;

use Net::DNS;
use Mail::SpamAssassin::Plugin;
use Socket;
use strict;
use warnings;
use vars qw(@ISA);
use LWP::Simple qw( get );	# v1, use the HTTP/web. v2 add DNS support, and allow the user to toggle which to use.
use JSON::PP qw( decode_json );	# Required to parse JSON, another dep, may need to be installed via CPAN on the SA machine
use Data::Dumper; 

@ISA = qw(Mail::SpamAssassin::Plugin);
my $VERSION = 0.1;

sub new {
	my ($class, $mailsa) = @_;

	$class = ref($class) || $class;
	my $self = $class->SUPER::new($mailsa);
	bless ($self, $class);

	$self->register_eval_rule("metaassassin");

	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: version " . $VERSION);

	$self->{main}->{conf}->{metaassassin_api_key}		= 0;

	return $self;
}

sub metaassassin {
	my ($self, $pms) = @_;
	my ($status, $ip, $helo);

	my $url = "http://api.metascan.io/v1/check/json";

	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Startup up");

	# Load details on the sender (IP, HELO tag)
	# TODO: Add further checks, and check local IP and trusted senders to ignore
	($status, $ip, $helo) = $self->_get_sender_details($pms);

	unless ($status) {
		Mail::SpamAssassin::Plugin::dbg("MetaAssassin: skipping");
		return 0;
	}

	# Alright, time to query metascan
	my $query = $url . "/$ip";	# TODO: Add API key via config file
	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Requesting $query");

	# TODO: Time the query and log request in ms
	my $json = get( $query );

	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Response received:");
	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: $json");

	# Decode the response
	my $decoded_json = JSON::PP::decode_json( $json );

	# Dump
	#$dump = Dumper $decoded_json

	if($decoded_json->{'results'}['0']->{'found'} eq "true")	{
		# We have a hit
		Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Message $ip is a HIT");
		return 1;
	} else {
		Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Message $ip is a MISS");
		return 0;
	}

}


sub _get_sender_details {
	my ($self, $pms) = @_;
	my ($ip, $helo, $relay);

	Mail::SpamAssassin::Plugin::dbg("MetaAssassin: Init _get_sender_details");

	# Fetch the mail in question and extract the details
	my $msg = $pms->get_message();

	# Grab the untrusted IPs from the message sender.
	my @untrusted = @{$msg->{metadata}->{relays_untrusted}};

	while (1) {
		$relay = shift(@untrusted);

		if (! defined ($relay)) {
			Mail::SpamAssassin::Plugin::dbg("MetaAssassin: No untrusted IP's");
			return (0, $ip, $helo);
		}

		# Fetch IP
		$ip = $relay->{ip};

		# Fetch reverse DNS?

		# Fetch the EHLO tag
		$helo = $relay->{helo};

		Mail::SpamAssassin::Plugin::dbg("MetaAssassin: IP '$ip'");
		Mail::SpamAssassin::Plugin::dbg("MetaAssassin: HELO is '$helo'");

		return (1, $ip, $helo);
	}

}


