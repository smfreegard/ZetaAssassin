# MetaAssassin v0.1 (ALPHA)

### Install Guide 

Installation guide for installing the `MetaAssassin` plugin for SpamAssassin.

### Pre-requirement

* Spamassassin must be pre-installed
* You must have a developer account at [metascan.io](http://metascan.io/)
 
### Step 1:

Copy the configuration file to your spamassassin config directory ( where the Spamassassin local.cf file exists )

`cp metaassassin.cf /usr/local/etc/spamassassin/`

If the senders mail-server IP is listed on metascan, an additional 2 points will be added to the spam score.

You can optionally tweak this value by editing the metaassassin.cf file and change the score:
 
>score		METAASSASSIN			2.0

### Step 2:

Copy the MetaAssassin.pm file to your SpamAssassin plugin directory. This will vary depending on your OS/installation.

`cp MetaAssassin.pm /usr/local/spamassassin/share/perl5/Mail/SpamAssassin/Plugin/`

### Step 3:

Your MTA IP address must be authenticated via the metascan developer dashboard. Login to the [dashboard](https://metascan.io/manage) and specify your servers IP address.

### Step 4: 

Restart Spamassassin and the plugin will be live.

`# service restart spamassassin`

Each mail received by Spamassassin, will query the metascan API for the senders IP address, and if found, will apply additional points to the spam-score.

### Congratulations

Your user mailboxes are now protected by MetaScan! 🎉

# Testing

Run spamd in debug mode, send a mail from an outside host. You can trace debuging with the `MetaAssassin` debug log.

e.g:

`spamd -D -x -q`

```
Jul 26 10:35:42.170 [4851] dbg: MetaAssassin: Startup up
Jul 26 10:35:42.170 [4851] dbg: MetaAssassin: Init _get_sender_details
Jul 26 10:35:42.171 [4851] dbg: MetaAssassin: IP '74.125.83.51'
Jul 26 10:35:42.171 [4851] dbg: MetaAssassin: HELO is 'mail-pg0-f51.google.com'
Jul 26 10:35:42.171 [4851] dbg: MetaAssassin: Requesting http://api.metascan.io/v1/check/json/74.125.83.51
Jul 26 10:35:42.252 [4851] dbg: MetaAssassin: Response received:
Jul 26 10:35:42.252 [4851] dbg: MetaAssassin: {"results":[{"item":"74.125.83.51","found":false,"wl":true,"wldata":"5;none;google.com;1429","score":-0.1,"lastModified":1500972100}],"executionTime":1,"status":"success"}
Jul 26 10:35:42.253 [4851] dbg: MetaAssassin: Message 74.125.83.51 is a MISS
```
