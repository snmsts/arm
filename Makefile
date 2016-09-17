test:
	git clone https://github.com/roswell/roswell
	cd roswell;./bootstrap
	cd roswell;./configure
	cd roswell;make
	cd roswell;make test
	echo test;

.PHONY: test
