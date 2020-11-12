#!/usr/bin/env bash

figlet -w 160 -f small "Generate GPG2 Public and Private Keys"
figlet -w 160 -f slant "SHOULD BE RUN ONLY ONCE"
rm -rf ~/.gnupg/

#
# if you ever need to start over, rm -rf ~/.gnupg/ will decimate all the keys and your keyring
#
# the system requires a lot of entropy to generate the keys.  use cat /proc/sys/kernel/random/entropy_avail
# to see how much you have.  you'll need thousands to generate a 4096 but key.  try doing a lot of file io to
# gain more entropy or expect things to take quite a while.  for example, sudo find / -name xyzzy > /dev/null may help.
#
# you may also try sudo apt-get install rng-tools & sudo rngd -r /dev/urandom, and kill the /usr/sbin/rngd -r /dev/hwrng when done.
# the best solution for an entropy starved machine may be simply using yur keyboard and mouse a lot
# you can see this with until [ $COUNT -lt 1 ]; do   let COUNT=`cat /proc/sys/kernel/random/entropy_avail`;   echo "`date` COUNTER $COUNT";done
# this one worked the best for me.  before running it, I could not get enough entropy for 4096 generation even sfter an hour.  after starting it,
# the network traffic caused my entropy to rise and then fall as gpg2 consumed it (maybe 256 bits at a time), and was finally done in ten minutes or so
#

#
# Originally, I tried to generate RSA 4096 bit keys.  But this was taking hours and still not complete.
#
# I decided to see what the NSA uses.  https://www.keylength.com/en/6/
#
# 	NSA will initiate a transition to quantum resistant algorithms in the not too distant future.
# 	Until this new suite is developed and products are available implementing the quantum resistant suite,
# 	NSA will rely on current algorithms. For those partners and vendors that have not yet made the
# 	transition to CNSA suite elliptic curve algorithms, the NSA recommend not making a significant
# 	expenditure to do so at this point but instead to prepare for the upcoming quantum resistant
# 	algorithm transition.
#
# From this, I decided to go to RSA 3072 bit length
#
# THEN I FOUND THAT REBOOTING YOUR SYSTEM IS THE BEST ADVICE.  WITH THIS I WAS EASILY ABLE TO GENERATE THE 4096 BIT KEYS IN 5 SECONDS.

bash -c 'cat << "EOF" > foo
     %echo Generating OpenPGP key for our use
     Key-Type: RSA
     Key-Length: 4096
     Subkey-Type: RSA
     Subkey-Length: 4096
     Name-Real: Howard Deiner
     Name-Comment: for secure AWSPOC work - xyzzy passphrase
     Name-Email: howard.deiner@deinersoft.commit
     Expire-Date: 0
     Passphrase: xyzzy
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF'

gpg2 --batch --generate-key foo
rm foo

gpg2 --list-keys