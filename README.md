# Hello, Parsec!

This repository contains the sources to build a very simple demo client application for Parsec and
make it ready for publication as a Docker container image.

The aim of this demo application is to show, in a simple and visually-obvious way, that a Parsec
service instance is running and responding on the host platform. The application will "ping" the
service and, if this succeeds, will display a Parsec-themed banner message and run a small number of
additional basic tests. The published container will be a small image that can easily be downloaded
and used by developers or systems integrators who wish to validate that Parsec is running and
responsive on a system. It can also be used in live demo contexts to show a watching audience that
Parsec is available and running correctly. Additionally, it will provide options to run more
comprehensive sets of tests, although these will not execute by default.

# What's Here?

An important use case for Parsec is to allow containerised, cloud-native applications to access the
hardware-backed security facilities of a host platform, using straightforward interfaces in a
variety of popular programming languages. This repository contains the resources needed to build a
simple example of such a containerised application. It uses just a small number of Parsec's basic
functions, but does so in a way that showcases the ability of Parsec to be consumed in different
languages, such as Go, Rust or shell scripts.

The `hello-parsec.sh` file is the primary script that runs as the container's entry point. This
script will use the command-line [`parsec-tool`](https://github.com/parallaxsecond/parsec-tool) to
ping the service and display some simple details about its configuration. The script then uses the
same `parsec-tool` to create an RSA key pair with a well-known name, which is then used to encrypt
some small string messages. The ciphertext of these messages is piped in base-64 format into some
simple decryption programs that are written in some of the programming languages that Parsec
supports with client libraries. These programs recover the plaintext messages using the private key
held by Parsec. The plaintext messages are then echoed out to the console, bringing the demo to a
close.

The `parsec_banner.txt` file contains the banner message that is displayed to the console when the
script discovers that Parsec is available and running.

The `go` folder contains a very small Go program to decrypt the base-64 ciphertext that it receives
on its standard input. It uses the [Parsec Go
Client](https://github.com/parallaxsecond/parsec-client-go) to decrypt the ciphertext with the
well-known demo key. It writes the recovered plaintext message to its console output. It is a very
simple demonstration of a single Parsec API call in Go, requiring just a few lines of code.

The `rust` folder contains a Rust implementation of the identical decryption program, using the
[Parsec Rust Client](https://github.com/parallaxsecond/parsec-client-rust).

Finally, the `Dockerfile` resource is used to build the entire application into a Docker container
so that it can easily be executed an published. Only a single `docker build` command is needed. The
Dockerfile uses a [multi-stage build
process](https://docs.docker.com/develop/develop-images/multistage-build/). The Rust and Go
applications are built inside staging containers that provide the required tool chains and build
environments. But the final compiled applications are then copied into a slimmer runtime container
image for execution.

# How to Build

The build process uses Docker, so you must first have Docker
[installed](https://docs.docker.com/get-docker/). However, all other build tools are provided by the
multi-stage container images, so there is nothing else that you need to install.

To build and tag the Docker image locally, simply clone this repo and execute the following command
from within its top-level folder:

```
docker build -t hello-parsec .
```

This command should download the required dependencies and construct the `hello-parsec` container
image.

You may wish to use the image locally, or push it to a suitable private container repository. Please
note that the Parsec maintenance team will ensure that the `hello-parsec` container images are
available in a suitable public location.

# How to Run

This container is designed to check a system where the Parsec service is running. If you do not have
Parsec running yet, you might want to view the [quickstart
guide](https://parallaxsecond.github.io/parsec-book/getting_started/index.html) to get started with
the service.

Parsec clients talk to the service using a Unix domain socket. When the client application is
running in a container, as is the case here, the container needs to be able to see the domain socket
on the host. This can be achieved by running the Docker image with a [bind
mount](https://docs.docker.com/storage/bind-mounts/). By default, Parsec expects to find the domain
socket file in the folder `/run/parsec`. If this is the folder that your service is using (which,
again, will be the case unless you have explicitly configured it to do otherwise), then the bind
mount is very simple:

```
docker run -v /run/parsec:/run/parsec hello-parsec
```

This command will execute the demo client application.

# What Should I See?

If the `hello-parsec` demo container application successfully connects with the service, you should
see the banner message, followed by some details of the service configuration, and finally the
results of the RSA encryption round-trips using the example programs in their different languages.

The output should be similar to what is shown below. It may vary slightly depending on your service
configuration. If you do not see the Parsec banner, then something has gone wrong, and you will need
to ensure that Parsec is running correctly on your system, and that you have supplied the correct
bind mount. Make sure, for example, that the file `/run/parsec/parsec.sock` exists, or that you have
adjusted the above command with the correct path where `parsec.sock` can be found.

```
Checking for availability of the Parsec service on your system... 

                             o   o----------------
                             |  --------o     o  |
                             |  |  ---------  |  |
                             |  |  |       |  |  |
                             |  |  |       |  |  |
                             |  |  |       |  |  |
                             |  |   \      o  |  |
                             \  o    \        /  /
                              \   o   \      /  /
                               \   \   o    /  o
                                \   \      /  o
                                 \   \    /  /
                                  \   \  /  /
                                   ---------
                                    -------


+++++++          +          +++++++         ++++++       ++++++++        +++++   
+       +       + +         +      +       +      +      +              +      +
+       +      +   +        +       +      +             +             +
+++++++       +     +       +++++++          ++++        +++++++      +
+            ++++++  +      +    +                +      +             +
+           +         +     +     +       +       +      +              +      +
+          +           +    +      +       +++++++       ++++++++         +++++

          ---- Congratulations! Parsec Is Enabled On This System! -----
          
                            https://parsec.community
                     https://github.com/parallaxsecond/parsec


Parsec back-end providers enabled (the topmost entry is the default):-
ID: 0x01 (Mbed Crypto provider)
Running RSA encryption demo. Three 'Hello Parsec' messages should appear below...

Hello Parsec from Rust!
Hello Parsec from Go!
Hello Parsec from the Parsec CLI Tool!

Finished!
```
