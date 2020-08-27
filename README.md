Retrieve internet tickets from Fritzbox and print on a Zebra printer
====================================================================

The [AVM FRITZ!Box](https://avm.de/produkte/fritzbox/) (FB) routers have a feature to allow Internet access to specific devices only for a certain amount of time. If that time is exceeded then the owner can print [Internet Tickets](https://en.avm.de/service/fritzbox/fritzbox-7490/knowledge-base/publication/show/3408_Extending-the-online-time-permitted-in-the-parental-controls-with-tickets/) that allow another 45 minutes of surfing.

The code in this repo helps to automate the retrieval and distribution of such Internet tickets.

There is also a GCP Pub/Sub based service to print tickets from remote. This is not well documented, ask me if you want to use that.

As of Version 22 (2020-08-27) this works with Fritz!OS 7.20 and has not been tested if it still works with older versions. Feedback is welcome.

Retrieving Tickets
------------------

The `fritzbox-get-internet-tickets.py` program will connect to the FB, retrieve the 10 available Internet tickets via web scraping (there is no API for that) and print them as a list to STDOUT.

Set the password via the `FRITZBOX_PASSWORD` environment variable and check the code for more options.

This program is usually not used directly, unless you plan to distribute the tickets yourself.

Printing Tickets
----------------

The `fritzbox-internet-ticket` program is the main program and will first retrieve the tickets from the FB and then send the first ticket to a print queue. This program also has a Desktop starter called "Print Internet Ticket".

Optionally it will upload the remaining 9 Internet tickets to a Google form for further processing. To enable this feature set the `FRITZBOX_GOOGLE_FORM_ID` and `FRITZBOX_GOOGLE_FORM_ENTRY_ID` variables to suitable values (get the values from a prefilled link to your form. The form should simply contain one text entry field).

Configuration
-------------

All configuration parameters are stored in `/etc/fritzbox-internet-ticket.conf` like this:
```bash
FRITZBOX_PASSWORD=mySuperSecretPasswort
FRITZBOX_PRINT_QUEUE=Zebra
FRITZBOX_GOOGLE_FORM_ID=1FAIpQLSfhbfiefhb437ghffsUW-WULIAkPL_J-RtJN_Kiu4Fhjdwshgw
FRITZBOX_GOOGLE_FORM_ENTRY_ID=1598434206
```

Take care to protect this file with file system permissions if you are on a multi user system.

Installation
------------

`make install` is for manual installs. `make deb` will create a Debian package which is also available from https://launchpad.net/~sschapiro/+archive/ubuntu/ppa which you can add to your system.
