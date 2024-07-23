prepare-front:
	npm run build
	./generate_cpp.sh --base-url /gui dist