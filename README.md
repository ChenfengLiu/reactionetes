# Reactionetes

Spin up a Kubernetes stack dedicated to Reaction Commerce PDQ

## Oneliner Autopilot

The oneliner:
```
curl -L https://git.io/reactionetes | bash
```

That merely performs the
[autopilot](#autopilot)
recipe using the [bootstrap](./bootstrap) file.

This script automagically attempts to determine your OS and tries to
install the minikube and kubectl appropriate for your OS.

At the end of which you will get some notes if everything went
successfully.  Here is some example output:

```
NOTES:
1. Get the ReactionCommerce URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l
"app=reactionetes,release=EXAMPLE_RELEASE" -o
jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:3001 to use your application"
  kubectl port-forward $POD_NAME 3001:3000
```

It should be noted that you can then paste the last three lines from
your output (not the above example lines, `EXAMPLE_RELEASE` will have your
release name that is generated by kubernetes instead)
directly into your terminal and you will be able to access the reaction
commerce site once all the pods spin up at:

[127.0.0.1:3001](http://127.0.0.1:3001)

it may take some time depending mainly on your internet connection and
how fast you can download all the necessary images.  The first time
being the worst as you have to download kubectl and minikube, AND all
the docker images to spin up kubernetes.

## Manual Installation

### Requirements

[Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to access your cluster

A running kubernetes stack, perhap using
[minikube](https://github.com/kubernetes/minikube)

with tiller initialized by
[helm](https://helm.sh/)

helm should be able to talk to your k8s cluster
and install freely

#### Windows

On
Windows
[Chocolatey](https://chocolatey.org/)
can simplify installation

#### Mac OS X

On
Macintosh
[homebrew](https://brew.sh/)
can simplify installation

### Install

```
helm install ./reactionetes
```

## Autopilot

This will install
minikube kubectl,
startup a cluster,
initialize helm,
and finally spin up the reaction cluster

```
make autopilot
```

or it can be done in a one-off sort of manner using the oneliner:

```
curl -L https://git.io/reactionetes | bash
```

or specify your own minikube opts:

```
export MINIKUBE_OPTS=--vm-driver=kvm
curl -L https://git.io/reactionetes | bash
```

or on a VM that has docker installed you can run without the
virtualization driver

```
export MINIKUBE_OPTS=--vm-driver=none
curl -L https://git.io/reactionetes | bash
```

## [values.yaml](./reactionetes/values.yaml) Config

You can easily swap out your image by altering these lines:
[image settings](./reactionetes/values.yaml#L5-L7)

And the external host using these lines:
[host setting](./reactionetes/values.yaml#L17-L18)

These values can be overridden on the command line usingi the `--set` and
`--values` flags for helm, more info
[here](https://docs.helm.sh/helm/#helm-install)
and [here](https://docs.helm.sh/using_helm/#using-helm)


## Debug

```
helm install --dry-run --debug ./reactionetes > /tmp/manifest
```


## Makefile

#### install minikube

minikube and kubctl are updated often, it can't hurt to run this accordingly

```
make reqs
```


#### helm install .

this is the default for this makefile

```
make
```

#### Linux Reqs

```
make linuxreqs
```

#### Windows Reqs

```
make windowsreqs
```

#### OSX Reqs

```
make osxreqs
```

#### Debug

you can also save a debug copy of what manifest file will be generated
using:

```
make debug
```

This will produce output pointing you to the saved manifest file in your
temp directory:

```
make debug
helm install --dry-run --debug . > /tmp/tmp.zZGCOwCCoqDOCKERTMP/manifest
ls -lh /tmp/tmp.zZGCOwCCoqDOCKERTMP/manifest
-rw-r--r-- 1 thoth thoth 5.0K Nov 22 15:44
/tmp/tmp.zZGCOwCCoqDOCKERTMP/manifest
```


#### Perftest

```
make timeme
```

How long to spin up the cluster?  Or at least for the bootstrap to
run?  After running this a few times (caching a few things)
my machine can spin up a cluster with helm and make the initial
request for reactioncommerce to assembled in just over 3 minutes:

```
        Command being timed: "./bootstrap"
        User time (seconds): 7.10
        System time (seconds): 6.64
        Percent of CPU this job got: 7%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 3:04.60
        Average shared text size (kbytes): 0
        Average unshared data size (kbytes): 0
        Average stack size (kbytes): 0
        Average total size (kbytes): 0
        Maximum resident set size (kbytes): 35476
        Average resident set size (kbytes): 0
        Major (requiring I/O) page faults: 4
        Minor (reclaiming a frame) page faults: 125388
        Voluntary context switches: 293968
        Involuntary context switches: 710
        Swaps: 0
        File system inputs: 744
        File system outputs: 287216
        Socket messages sent: 0
        Socket messages received: 0
        Signals delivered: 0
        Page size (bytes): 4096
        Exit status: 0
```

After that it took another 5 minutes for the mongo cluster to assemble
and reaction to spin up:

```
$ kubectl get po
NAME                                                READY     STATUS
RESTARTS   AGE
solitary-hummingbird-mongo-0                        2/2       Running  0          5m
solitary-hummingbird-mongo-1                        2/2       Running  0          1m
solitary-hummingbird-mongo-2                        2/2       Running  0          1m
solitary-hummingbird-reactionetes-d5c7c7b79-7df4q   1/1       Running  2          5m
```


## branches

#### deprecated
These are stale and should only be looked at as an example

The master branch should work fine to test out Reaction on a local
minikube setup.  There will be other branches for other setups
and cloud providers.

#### [gce-ssd](https://github.com/joshuacox/reactionetes/tree/gce-ssd)

This branch will use a SSD GCE persistent disk on the google cloud platform

#### [gce-hdd](https://github.com/joshuacox/reactionetes/tree/gce-hdd)

This branch will use a HDD GCE persistent disk on the google cloud platform


## Notes:

Kubernetes blog [post](http://blog.kubernetes.io/2017/01/running-mongodb-on-kubernetes-with-statefulsets.html) from  January 2017

Mongodb blog [post](https://www.mongodb.com/blog/post/running-mongodb-as-a-microservice-with-docker-and-kubernetes)

KubernetesUpAndRunning examples [repo](https://github.com/kubernetes-up-and-running/examples)


### todo

add aws support

add openebs support

add a production setup that utilizes a pre-existing mongo stack and has
many different reaction deployments

add kadira

add snowplow

add benchmarking

combine all branches using go templating conditionals
