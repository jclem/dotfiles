# fish completion for r

 complete --command r \
	 --condition "test (count (commandline -opc)) -eq 1" \
	 --arguments "(ls -L $CODE)" \
	 --no-files

 complete --command r \
	 --condition "test (count (commandline -opc)) -eq 2" \
	 --arguments "(ls -L $CODE/(commandline -opc)[2])" \
	 --no-files