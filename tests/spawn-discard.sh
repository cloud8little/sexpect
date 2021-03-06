#!/bin/bash
#
# `ps -p <pid> -o stat' also works on macOS.
#

source $SRCDIR/tests/common.sh || exit 1

assert_run sexpect sp -t 10 -discard -ttl 20 bash -c 'echo aaa; sleep 5; echo bbb; sleep 2'
run sleep 1

# `aaa' can still be expect'ed.
assert_run sexpect ex -t 2 aaa

# `bbb' shows up when we're actively waiting, so make us happy.
assert_run sexpect ex -t 5 bbb

assert_run sexpect ex -t 10 -eof
assert_run sexpect ex -t 0 -eof
assert_run sexpect w

#----------------------------------------------------------------------------#

assert_run sexpect sp -ttl 5 od -v /dev/zero
run sleep 1
pid=$( sexpect get -pid )
info "pid=$pid"
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == S* ]]'

assert_run sexpect set -discard 1
run sleep .5
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == R* ]]'

assert_run sexpect set -discard 0
run sleep 1
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == S* ]]'

assert_run sexpect set -nowait 1
assert_run sexpect c

#----------------------------------------------------------------------------#

assert_run sexpect sp -discard -ttl 5 od -v /dev/zero
run sleep 1
pid=$( sexpect get -pid )
info "pid=$pid"
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == R* ]]'

assert_run sexpect set -discard 0
run sleep 1
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == S* ]]'

assert_run sexpect set -discard 1
run sleep 1
st=$( ps -p $pid -o stat | sed -n 2p )
info "st=$st"
assert '[[ $st == R* ]]'

assert_run sexpect set -nowait 1
assert_run sexpect c
