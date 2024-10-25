build:
	v fmt -w flist.v
	v -o flist .
	sudo ./flist install

rebuild:
	sudo flist uninstall
	v fmt -w flist.v
	v -o flist .
	sudo ./flist install
	
delete:
	sudo flist uninstall

build-win:
	v fmt -w flist.v
	v -o flist .
	./flist.exe install

rebuild-win:
	./flist.exe uninstall
	v fmt -w flist.v
	v -o flist .
	./flist.exe install

delete-win:
	./flist.exe uninstall