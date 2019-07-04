IMAGE_NAME = apex-service:19.1


.PHONY: test image enter

image: Dockerfile
	docker build --no-cache --tag=$(IMAGE_NAME) .


enter: image
	docker run  -it --rm  $(IMAGE_NAME) /bin/bash  

test: 
	$(MAKE) -C test/ test
