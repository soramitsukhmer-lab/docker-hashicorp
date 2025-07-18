it:
	docker buildx bake --print --set=*.platform=""
build:
	docker --context=default buildx bake --load --set=*.platform=""
