#!/bin/bash
#

if [ -z "$1" ]; then
    echo "Usage: $0 <00xx-...test> [modes..]"
    echo ""
    echo "  Modes: bare valgrind helgrind drd"
    exit 1
fi

TEST=$1
if [ ! -z "$2" ]; then
    MODES=$2
else
    MODES="bare valgrind"
fi

FAILED=0

# Enable valgrind suppressions for false positives
SUPP="--suppressions=librdkafka.suppressions"

# Uncomment to generate valgrind suppressions
#GEN_SUPP="--gen-suppressions=yes"

# Common valgrind arguments
VALGRIND_ARGS="--error-exitcode=3"

# Enable vgdb on valgrind errors.
#VALGRIND_ARGS="$VALGRIND_ARGS --vgdb-error=1"

echo "############## $TEST ################"

for mode in $MODES; do
    echo "### Running test $TEST in $mode mode ###"
    case "$mode" in
	valgrind)
	    valgrind $VALGRIND_ARGS --leak-check=full $SUPP $GEN_SUPP \
		./$TEST
	    RET=$?
	    ;;
	helgrind)
	    valgrind $VALGRIND_ARGS --tool=helgrind $SUPP $GEN_SUPP \
		./$TEST	
	    RET=$?
	    ;;
	drd)
	    valgrind $VALGRIND_ARGS --tool=drd $SUPP $GEN_SUPP \
		./$TEST	
	    RET=$?
	    ;;	    
	bare)
	    ./$TEST
	    RET=$?
	    ;;
	*)
	    echo "### Unknown mode $mode for $TEST ###"
	    RET=1
	    ;;
    esac

    if [ $RET -gt 0 ]; then
	echo "###"
	echo "### Test $TEST in $mode mode FAILED! ###"
	echo "###"
	FAILED=1
    else
	echo "###"
	echo "### $Test $TEST in $mode mode PASSED! ###"
	echo "###"
    fi
done

exit $FAILED

