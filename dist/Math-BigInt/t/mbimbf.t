#!/usr/bin/perl -w

# test rounding, accuracy, precicion and fallback, round_mode and mixing
# of classes

use strict;
use Test;

BEGIN
  {
  plan tests => 684 
    + 26;		# own tests
  }

use Math::BigInt 1.70;
use Math::BigFloat 1.43;

use vars qw/$mbi $mbf/;

$mbi = 'Math::BigInt';
$mbf = 'Math::BigFloat';

require 't/mbimbf.inc';

# some tests that won't work with subclasses, since the things are only
# garantied in the Math::BigInt/BigFloat (unless subclass chooses to support
# this)

Math::BigInt->round_mode('even');	# reset for tests
Math::BigFloat->round_mode('even');	# reset for tests

ok ($Math::BigInt::rnd_mode,'even');
ok ($Math::BigFloat::rnd_mode,'even');

my $x = eval '$mbi->round_mode("huhmbi");';
print "# Got '$@'\n" unless
 ok ($@ =~ /^Unknown round mode 'huhmbi' at/);

$x = eval '$mbf->round_mode("huhmbf");';
print "# Got '$@'\n" unless
 ok ($@ =~ /^Unknown round mode 'huhmbf' at/);

# old way (now with test for validity)
$x = eval '$Math::BigInt::rnd_mode = "huhmbi";';
print "# Got '$@'\n" unless
 ok ($@ =~ /^Unknown round mode 'huhmbi' at/);
$x = eval '$Math::BigFloat::rnd_mode = "huhmbf";';
print "# Got '$@'\n" unless
 ok ($@ =~ /^Unknown round mode 'huhmbf' at/);
# see if accessor also changes old variable
$mbi->round_mode('odd'); ok ($Math::BigInt::rnd_mode,'odd');
$mbf->round_mode('odd'); ok ($Math::BigInt::rnd_mode,'odd');

foreach my $class (qw/Math::BigInt Math::BigFloat/)
  {
  ok ($class->accuracy(5),5);		# set A
  ok_undef ($class->precision());	# and now P must be cleared
  ok ($class->precision(5),5);		# set P
  ok_undef ($class->accuracy());	# and now A must be cleared
  }

foreach my $class (qw/Math::BigInt Math::BigFloat/)
  {
  $class->accuracy(42);
  my $x = $class->new(123);	# $x gets A of 42, too!
  ok ($x->accuracy(),42);	# really?
  ok ($x->accuracy(undef),42);	# $x has no A, but the
				# global is still in effect for $x
				# so the return value of that operation should
				# be 42, not undef
  ok ($x->accuracy(),42);	# so $x should still have A = 42
  $class->accuracy(undef);	# reset for further tests
  $class->precision(undef);
  }
# bug with flog(Math::BigFloat,Math::BigInt)
$x = Math::BigFloat->new(100);
$x = $x->blog(Math::BigInt->new(10));

ok ($x,2);

# bug until v1.88 for sqrt() with enough digits
for my $i (80,88,100)
  {
  $x = Math::BigFloat->new("1." . ("0" x $i) . "1");
  $x = $x->bsqrt;
  ok ($x, 1);
  }
