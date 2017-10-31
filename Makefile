# contrib/slapd-modules/check_password/Makefile
# Copyright 2007 Michael Steinmann, Calivia. All Rights Reserved.
# Updated by Pierre-Yves Bonnetain, B&A Consultants, 2008
# Updated by Trevor Vaughan, Onyx Point Inc., 2011
#

CC=gcc

# Where to look for the CrackLib dictionaries
#
CRACKLIB=/var/cache/cracklib/cracklib_dict

# Path to the configuration file
#
# Make sure this is a writable location to use the cpass tests.
CONFIG=/etc/ldap/check_password.conf
#CONFIG=check_password.conf

# Turn on local debugging.
#OPT=-g -O2 -Wall -fpic 						\
# -DHAVE_CRACKLIB -DCRACKLIB_DICTPATH="\"$(CRACKLIB)\""	\
# -DCONFIG_FILE="\"$(CONFIG)\"" \
# -DLDEBUG

OPT=-g -O2 -Wall -fpic 						\
	-DHAVE_CRACKLIB -DCRACKLIB_DICTPATH="\"$(CRACKLIB)\""	\
	-DCONFIG_FILE="\"$(CONFIG)\""

# Where to find the OpenLDAP headers.
#
LDAP_SRC = ../../..
LDAP_BUILD = $(LDAP_SRC)
LDAP_INC = -I$(LDAP_BUILD)/debian/build/include -I$(LDAP_BUILD)/debian/build/servers/slapd -I$(LDAP_BUILD)/include -I$(LDAP_SRC)/include -I$(LDAP_SRC)/servers/slapd

# Where to find the CrackLib headers.
#
#CRACK_INC=

INCS=$(LDAP_INC) $(CRACK_INC)

LDAP_LIB=-lldap_r -llber

# Comment out this line if you do NOT want to use the cracklib.
# You may have to add an -Ldirectory if the libcrak is not in a standard
# location
#
CRACKLIB_LIB=-lcrack

LIBS=$(LDAP_LIB) $(CRACKLIB_LIB)

LIBDIR=$(DESTDIR)/usr/lib/ldap/


all: 	check_password

check_password.o:
	$(CC) $(OPT) -c $(INCS) check_password.c

check_password: clean check_password.o
	$(CC) -shared -o check_password.so check_password.o $(CRACKLIB_LIB)
	ln -sf check_password.so libcheck_password.so

check_password_test: check_password
	$(CC) -g -O2 -DCONFIG_FILE="\"$(CONFIG)\"" -fpic $(INCS) -Wall check_password_test.c -o cpass -L. -llber -lcheck_password

install: check_password
	cp -f check_password.so $(LIBDIR)/

clean:
	$(RM) check_password.o check_password.so check_password.lo libcheck_password.so cpass
	$(RM) -r .libs

distclean: clean
	$(RM) -rf openldap-*
