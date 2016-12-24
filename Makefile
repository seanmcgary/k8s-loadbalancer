all: push

# 0.0 shouldn't clobber any released builds
TAG:=$(shell git rev-parse --verify HEAD)
PREFIX ?= gcr.io/seanmcgary-com/k8s-loadbalancer
GCLOUD ?= gcloud
HAPROXY_IMAGE = contrib-haproxy
SRC = service_loadbalancer.go loadbalancer_log.go

service_loadbalancer: $(SRC)
	CGO_ENABLED=0 GOOS=linux godep go build -a -installsuffix cgo -ldflags '-w' -o $@ $(SRC)

container: service_loadbalancer
	docker build -t $(PREFIX):$(TAG) .

container-only:
	docker build -t $(PREFIX):$(TAG) .
	docker tag $(PREFIX):$(TAG) $(PREFIX):latest

push: container-only
	docker push $(PREFIX):$(TAG)
	docker push $(PREFIX):latest

clean-go:
	rm -rf service_loadbalancer || true
	rm -rf loadbalancer_log || true

clean:
	# remove servicelb and contrib-haproxy images
	docker rmi -f $(HAPROXY_IMAGE):$(TAG) || true
	docker rmi -f $(HAPROXY_IMAGE):latest || true
	docker rmi -f $(PREFIX):$(TAG) || true
	rm -f service_loadbalancer

.PHONY: container push
