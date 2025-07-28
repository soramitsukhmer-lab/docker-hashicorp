target ?= default
it:
	docker buildx bake $(target) --set=*.platform="" --print
build:
	docker buildx bake $(target) --set=*.platform="" --load
