export PATH := ~/.roswell/bin:$(PATH)

test:
	git clone https://github.com/roswell/roswell
	cd roswell;./bootstrap
	cd roswell;./configure
	cd roswell;make
	cd roswell;sudo make install
	ros setup
	ros install prove
	cd roswell;make test
	echo test;

.PHONY: test
