procs=`screen -ls pidp11 | egrep '[0-9]+\.pidp11' | wc -l`
if [ $procs -eq 0 ]; then
	echo No PDP-11 emulator detected as running - check with pdp11control.
	exit 1
fi

if [ $procs -gt 1 ]; then
	echo More than one screen session found; results may be unpredictable.
fi

if [ $procs -ne 0 ]; then
	screen -d -r
fi
