all:

run: image imagerun


### CONTAINER CREATION

install: image imageexport push

export IMAGE=$(shell basename $(PWD))
export BUILDTAG:=$(shell date +%Y%m%d.%H%M%S)
export NAME=$(IMAGE)
export DOCKER_CONTEXT?=default
export DOCKER_IMAGES?=.

image-nocache:
	make image DOCKERBUILDEXTRAARGS=--no-cache

image:
	docker build $(DOCKERBUILDEXTRAARGS) --build-arg BUILDTAG=$(BUILDTAG) --progress=plain \
	 -t $(IMAGE) . 2>&1 | tee tmp-build.log

imagerun:
	-docker stop $(IMAGE)
	docker run -it --name $(IMAGE) --rm $(IMAGE)

imagetgz: image
	docker tag $(IMAGE) $(IMAGE):latest
	docker save $(IMAGE):latest | gzip > $(DOCKER_IMAGES)/$(IMAGE).tar.gz

push:
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker push $(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)
	docker tag $(IMAGE) $(DOCKER_REGISTRY)/$(IMAGE):latest
	docker push $(DOCKER_REGISTRY)/$(IMAGE):latest
	@echo -n "LATEST IMAGE: "
	@echo "$(DOCKER_REGISTRY)/$(IMAGE):$(BUILDTAG)" | tee tmp-build.tag
