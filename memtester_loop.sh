# Run `sudo -s` first to set up a root shell.
# This script will run 12 `memtester` processes in parallel.
# Each `memtester` process will test 10 GBytes of RAM.
# Each `memtester` process will run just one iteration, and then this script
# will trigger another `memtester` process. This is to ensure that we
# grab a different region of physical RAM for each iteration.
for i in {0..11}
do
    for j in {0..5}
    do
        memtester 10G 1 >> memtester_$i.stdout 2>> memtester_$i.stderr
    done &
done
