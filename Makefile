generate-cpp:
	npm run build -- --base=/gui/
	./generate_cpp.sh --base-url /gui dist

prepare-firmware: generate-cpp
	-rm ../smart-led-firmware/frontend.cpp
	cp dist/frontend.cpp ../smart-led-firmware/frontend.cpp