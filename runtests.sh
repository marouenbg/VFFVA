# runtests.sh
LOGFILE=log.txt

cd lib
make
CODE=$?

cat "$LOGFILE"

exit $CODE
