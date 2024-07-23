prepare-front:
	npm run build -- --base=/gui/
	./generate_cpp.sh --base-url /gui dist