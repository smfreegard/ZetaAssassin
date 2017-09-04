# ZetaAssassin v0.2 (BETA)

### Install Guide 

Installation guide for installing the `ZetaAssassin` plugin for SpamAssassin.

### Pre-requirement

* Spamassassin must be pre-installed
* You must have a developer account at [zetascan.com](http://zetascan.com/)
 
### Step 1:

Copy the configuration file to your spamassassin config directory ( where the Spamassassin local.cf file exists )

`cp zetaAssassin.cf /usr/local/etc/spamassassin/`

If the senders mail-server IP is listed on zetascan, an additional 2 points will be added to the spam score.

You can optionally tweak this value by editing the zetaassassin.cf file and change the score:
 
>score		ZETAASSASSIN			2.0

### Step 2:

Copy the ZetaAssassin.pm file to your SpamAssassin plugin directory. This will vary depending on your OS/installation.

`cp ZetaAssassin.pm /usr/local/spamassassin/share/perl5/Mail/SpamAssassin/Plugin/`

### Step 3:

Your MTA IP address must be authenticated via the zetascan developer dashboard. Login to the [dashboard](https://zetascan.com/manage) and specify your servers IP address.

### Step 4: 

Restart Spamassassin and the plugin will be live.

`# service restart spamassassin`

Each mail received by Spamassassin, will query the zetascan API for the senders IP address, and if found, will apply additional points to the spam-score.

### Congratulations

Your user mailboxes are now protected by Zetascan! 🎉

# Testing

Run spamd in debug mode, send a mail from an outside host. You can trace debuging with the `ZetaAssassin` debug log.

e.g:

`spamd -D -x -q`

```
Jul 26 10:35:42.170 [4851] dbg: ZetaAssassin: Startup up
Jul 26 10:35:42.170 [4851] dbg: ZetaAssassin: Init _get_sender_details
Jul 26 10:35:42.171 [4851] dbg: ZetaAssassin: IP '74.125.83.51'
Jul 26 10:35:42.171 [4851] dbg: ZetaAssassin: HELO is 'mail-pg0-f51.google.com'
Jul 26 10:35:42.171 [4851] dbg: ZetaAssassin: Requesting http://api.metascan.io/v1/check/json/74.125.83.51
Jul 26 10:35:42.252 [4851] dbg: ZetaAssassin: Response received:
Jul 26 10:35:42.252 [4851] dbg: ZetaAssassin: {"results":[{"item":"74.125.83.51","found":false,"wl":true,"wldata":"5;none;google.com;1429","score":-0.1,"lastModified":1500972100}],"executionTime":1,"status":"success"}
Jul 26 10:35:42.253 [4851] dbg: ZetaAssassin: Message 74.125.83.51 is a MISS
```
