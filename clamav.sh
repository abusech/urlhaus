#!/bin/bash

# This script updates Clamav definitions with data from URLhaus (https://urlhaus.abuse.ch/api/#clamav)
#
# !!! To receive best protection, you should setup a cronjob that executes this script every minute !!!
#
# Please set up the following variables to fit your system

CLAMDIR="/var/lib/clamav"
CLAMUSER="clamav"
CLAMGROUP="clamav"

# Don't change anything below this line

RELOAD=0

lockfile -r 0 /tmp/local.the.lock || exit 1

rm -f /tmp/urlhaus.ndb

curl -s https://urlhaus.abuse.ch/downloads/urlhaus.ndb -o /tmp/urlhaus.ndb

if [ $? -eq 0 ]; then
  if [ -f "$CLAMDIR"/urlhaus.ndb ]; then
    MD5old=`md5sum "$CLAMDIR"/urlhaus.ndb`
    MD5new=`md5sum /tmp/urlhaus.ndb`
    if ! [ "$MD5old" = "$MD5new" ]; then
      # Updated file
      cp /tmp/urlhaus.ndb $CLAMDIR
      chown $CLAMUSER.$CLAMGROUP "$CLAMDIR"/urlhaus.ndb
      RELOAD=1
    fi
    else
      # Looks like it's the first run
      cp /tmp/urlhaus.ndb $CLAMDIR
      chown $CLAMUSER.$CLAMGROUP "$CLAMDIR"/urlhaus.ndb
      RELOAD=1
    fi
fi

if [ $RELOAD -eq 1 ]; then
  clamdscan --reload
fi

rm -f /tmp/local.the.lock
