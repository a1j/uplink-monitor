#!/bin/sh
###
# How often to test for connectivity
POLLINTERVAL=20
PKTS=2

# Consider we are down only if we cannot reach any of those
HOST1='8.8.8.8'  # Google
HOST2='1.1.1.1'  # Cloudflare
HOST3='208.67.220.220' # OpenDNS
###

M=`which mtr`
if [ ! -x "${M}" ] ; then
  echo "Cannot execute mtr, please install mtr package"
  exit 1
fi
F=`which fping`
if [ ! -x "${F}" ] ; then
  echo "Cannot execute fping, please install fping package"
  exit 1
fi

# Main loop
while : ; do

  POLLTIME=$(date +'%s')
  fping -C"${PKTS}" -q "${HOST1}" > /dev/null 2>&1
  if [ "$?" -ne 0 ] ; then
    fping -C"${PKTS}" -q "${HOST2}" > /dev/null 2>&1
    if [ "$?" -ne 0 ] ; then
      fping -C"${PKTS}" -q "${HOST3}" > /dev/null 2>&1
      if [ "$?" -ne 0 ] ; then
	# we are really down, now spit out mtr stats
        mtr -rn ${HOST1}
      fi
    fi
  fi

  NOW=$(date +'%s')
  LEFT=$(echo "${POLLTIME}+${POLLINTERVAL}-${NOW}" | bc)
  echo "Lst: ${POLLTIME}, Now: ${NOW}, Left: $LEFT"

  if [ "${LEFT}" -gt "0" ] ; then
    sleep $LEFT
  fi
done
