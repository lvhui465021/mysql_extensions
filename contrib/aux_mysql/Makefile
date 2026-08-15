# contrib/aux_mysql/Makefile

# The wire-protocol module itself.  This used to be built by the kernel meson
# build (contrib/aux_mysql/meson.build); after the pluginization it must be
# built here, like mysql_parser and mysm.
MODULE_big = aux_mysql
OBJS = \
	src/aux_mysql_init.o \
	src/mysql_auth.o \
	src/mysql_command.o \
	src/mysql_packet.o \
	src/mysql_protocol.o \
	src/mysql_stmt.o \
	src/mys_utility.o

PG_CFLAGS += -fvisibility=default

EXTENSION = aux_mysql
DATA = aux_mysql--1.1.sql aux_mysql--1.1--1.2.sql aux_mysql--1.2--1.3.sql \
	aux_mysql--1.3--1.4.sql aux_mysql--1.4--1.5.sql \
	aux_mysql--1.5--1.6.sql

REGRESS = versioning

TAP_TESTS = 1

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/aux_mysql
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
