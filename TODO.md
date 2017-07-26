# MetaAssassin

### ALPHA - Plugin for Spamassassin to prevent abuse

## Goals

* Query Metascan for sender IP address
* v1 Use the simple HTTP check
* v2 Use the metascan DNS query end-point
* Check sender address / domain, optionally HELO domain
* Check message relay hops
* Check users IP address if using a freemail-service ( if X-Remote-IP or the like, defined in mail headers )
* Optionally, check message URI's for spam IPs.

## Todo

* Write a CLI tool to query from the CLI
* Easy to config via a spamassassin.cf rule
* Add API key to .cf file
* Add ability to skip IPs
* Add ability to skip trusted IPs
* Add timeout for LWP query, prevent long HTTP timeout
* Use DNS queries vs JSON for speed
* Add benchmarking app for each of the API end-points to metascan
