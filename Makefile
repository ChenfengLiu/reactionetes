MINIKUBE_WANTUPDATENOTIFICATION=false
MINIKUBE_WANTREPORTERRORPROMPT=false
CHANGE_MINIKUBE_NONE_USER=true
KUBECONFIG=$(HOME)/.kube/config
MY_KUBE_VERSION=v1.8.0

install:
	$(eval TMP := $(shell mktemp -d --suffix=MINIKUBETMP))
	$(eval REACTIONETES_NAME := "raucous-reactionetes")
	$(eval REACTIONETES_REPO := "reactioncommerce/reaction")
	$(eval REACTIONETES_TAG := "latest")
	$(eval REACTIONETES_CLUSTER_DOMAIN := "cluster.local")
	$(eval REPLICAS := 1)
	$(eval MONGO_REPLICAS := 3)
	helm install --name $(REACTIONETES_NAME) \
		--set replicaCount=$(REPLICAS) \
		--set mongoReplicaCount=$(MONGO_REPLICAS) \
		--set image.tag=$(REACTIONETES_TAG) \
		--set image.repository=$(REACTIONETES_REPO) \
		--set reactionetesClusterDomain=$(REACTIONETES_CLUSTER_DOMAIN) \
		./reactionetes

linuxreqs: /usr/local/bin/minikube /usr/local/bin/kubectl /usr/local/bin/helm

osxreqs: macminikube mackubectl machelm

windowsreqs:  windowsminikube windowskubectl

debug:
	$(eval TMP := $(shell mktemp -d --suffix=DDEBUGTMP))
	helm install --dry-run --debug reactionetes > $(TMP)/manifest
	less $(TMP)/manifest
	ls -lh $(TMP)/manifest
	@echo "you can find the manifest here:"
	@echo "   $(TMP)/manifest"

autopilot: reqs
	@echo 'Autopilot engaged'
	$(eval MONGO_REPLICAS := 3)
	$(eval MINIKUBE_MEMORY := 4096)
	$(eval MINIKUBE_CPU := 4)
	$(eval REACTIONETES_CLUSTER_DOMAIN := "cluster.local")
	minikube \
		--kubernetes-version $(MY_KUBE_VERSION) \
		--dns-domain $(REACTIONETES_CLUSTER_DOMAIN) \
		--memory $(MINIKUBE_MEMORY) \
		--cpus $(MINIKUBE_CPU) \
		$(MINIKUBE_OPTS) \
		start
	@sh ./w8s/kubectl.w8
	helm init
	@sh ./w8s/tiller.w8
	@sh ./w8s/kube-dns.w8
	$(MAKE) -e install
	@sh ./w8s/mongo.w8 $(MONGO_REPLICAS)
	@sh ./w8s/reactionetes.w8
	@sh ./w8s/CrashLoopBackOff.w8
	make -e dnstest

/usr/local/bin/helm:
	curl -L https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash

installhelm:
	curl -L https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash

/usr/local/bin/minikube:
	@echo 'Installing minikube'
	$(eval TMP := $(shell mktemp -d --suffix=MINIKUBETMP))
	mkdir $(HOME)/.kube || true
	touch $(HOME)/.kube/config
	cd $(TMP) \
	&& curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/
	rmdir $(TMP)

/usr/local/bin/kubectl:
	@echo 'Installing kubectl'
	$(eval TMP := $(shell mktemp -d --suffix=KUBECTLTMP))
	cd $(TMP) \
	&& curl -LO https://storage.googleapis.com/kubernetes-release/release/$(MY_KUBE_VERSION)/bin/linux/amd64/kubectl \
	&& chmod +x kubectl \
 	&& sudo mv -v kubectl /usr/local/bin/
	rmdir $(TMP)

macminikube:
	@echo 'Installing minikube'
	brew cask install minikube

mackubectl:
	@echo 'Installing kubectl'
	brew install kubectl

machelm:
	@echo 'Installing kubectl'
	brew install kubernetes-helm

windowsminikube:
	@echo 'Installing minikube'
	choco install minikube

windowskubectl:
	@echo 'Installing kubectl'
	choco install kubernetes-cli

clean:
	-minikube stop
	-minikube delete

d: delete

delete:
	$(eval REACTIONETES_NAME := "raucous-reactionetes")
	helm delete --purge $(REACTIONETES_NAME)

timeme:
	/usr/bin/time -v ./bootstrap

test: timeme

reqs:
	bash ./check_reqs

# Install this to verify circleCI throught the CLI before commits
.git/hooks/pre-commit:
	cp .circleci/pre-commit .git/hooks/pre-commit

busybox:
	kubectl apply -f debug/busybox.yaml
	@sh ./w8s/generic.w8 busybox


dnstest: busybox
	$(eval REACTIONETES_NAME := "raucous-reactionetes")
	kubectl exec -ti busybox -- nslookup $(REACTIONETES_NAME)-mongo
	kubectl exec -ti busybox -- nslookup $(REACTIONETES_NAME)-reactionetes

ci: autopilot
	$(eval REACTIONETES_NAME := "raucous-reactionetes")
	./w8s/webpage.w8 $(REACTIONETES_NAME)
	kubectl get all
	kubectl get ep
	-@ echo 'Memory consumption of all that:'
	free -m
	@sh ./w8s/CrashLoopBackOff.w8
