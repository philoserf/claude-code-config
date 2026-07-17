---
description: Runs Linux containers on macOS with Apple's `container` CLI (the open-source Docker alternative, Apple Silicon). Use when running/building/managing OCI containers and images, starting its system services, or translating Docker commands to it.
allowed-tools: Bash
---

Use Apple's `container` CLI (`/opt/homebrew/bin/container`) to run Linux containers on macOS. Each container runs in its own lightweight VM (stronger isolation than Docker's shared kernel); it's **Apple Silicon only** and defaults to `arm64`. The command surface deliberately mirrors Docker, so most `docker <cmd>` habits translate directly to `container <cmd>`.

## Start the services first

Unlike Docker Desktop, `container` runs as on-demand system services you must start:

```bash
container system start            # start the services (needed after boot / install)
container system status           # check they're running
container system stop             # stop all services
container system logs             # service logs (for diagnosing the daemon itself)
```

If any command hangs or errors with a connection problem, `container system status` first — the services are the usual culprit.

## Everyday use (Docker-parallel)

```bash
container run <image> [cmd]            # run a container (foreground)
container run -d --name web -p 8080:80 nginx    # detached, named, publish host:container port
container run -it --rm ubuntu bash     # interactive TTY, auto-remove on exit
container run -v $PWD:/work -w /work <image> ...  # bind-mount a host dir
container ls                           # RUNNING containers only
container ls -a                        # include stopped ones
container exec -it <id> sh             # shell into a running container
container logs <id>                    # container logs (-f to follow)
container stop <id> / kill <id>        # stop / signal
container rm <id> / prune              # delete one / all stopped
container cp <id>:/path ./local        # copy files in/out
container inspect <id>                 # full JSON details
container stats                        # live resource usage
```

After a detached run, confirm it came up with `container ls` (running?) and `container logs <id>` (why not, if it exited).

Key `run` flags: `-d/--detach`, `--rm`, `--name`, `-p/--publish [host-ip:]host:container[/proto]`, `-v/--volume`, `--mount`, `-e/--env` & `--env-file`, `-w/--workdir`, `-i` + `-t`, `-c/--cpus`, `-m/--memory`, `--entrypoint`, `--network`, `--read-only`, `-a/--arch`, `--os`, `--platform`.

## Images and registries

```bash
container image ls | i ls              # list local images
container image pull <image>           # pull (Docker Hub and other OCI registries)
container image push <image>
container image rm <image> / prune
container image tag <src> <new-ref>
container image load  -i archive.tar   # import an OCI tar
container image save  <image> -o out.tar
container registry login <registry>    # auth (registry logout / ls too)
```

## Building

`build` uses a BuildKit-style builder that runs as its own container — it auto-starts, or manage it explicitly:

```bash
container build -t myapp:latest .              # build using ./Containerfile or ./Dockerfile as context
container build -f build/Containerfile -t x .  # explicit build file, context dir "."
container build --build-arg VER=1.2 --target prod --no-cache -t x .
container build --platform linux/amd64 -t x .  # cross-build an x86 image
container builder start | status | stop | delete
```

**Containerfile = Dockerfile.** A `Containerfile` is a vendor-neutral rename of a Dockerfile — **identical syntax and instruction set** (`FROM`, `RUN`, `COPY`, `ADD`, `ENV`, `ARG`, `WORKDIR`, `EXPOSE`, `CMD`, `ENTRYPOINT`, `USER`, `VOLUME`, multi-stage `FROM ... AS <stage>`, `HEALTHCHECK`, etc.). The name comes from the OCI/Podman world; `container build` accepts either filename with no behavioral difference. If both exist in the context, prefer being explicit with `-f`. Any Dockerfile you already have works unchanged — copy it to `Containerfile` or point `-f` at it. Key build flags: `-f/--file`, `-t/--tag`, `--build-arg key=val`, `--target <stage>` (stop at a stage in a multi-stage build), `--no-cache`, `-a/--arch` / `--platform`; the trailing arg is the build context dir (default `.`).

## Networks, volumes, DNS

```bash
container network ls | create | inspect | rm | prune
container volume  ls | create | inspect | rm | prune     # managed volumes (vs -v bind mounts)
container system dns ...                # manage local DNS domains — containers are reachable by name
```

Containers get their own IP addresses; the DNS integration lets you address them by name from the host. (Full host↔container reachability depends on the macOS version — newer releases lift earlier networking limits.)

## Differences from Docker to keep in mind

- **Services aren't always up** — `container system start` is the equivalent of "is Docker running?".
- **Default arch is `arm64`.** For x86 images pass `--arch amd64` or `--platform linux/amd64` (runs emulated). Multi-arch images otherwise resolve to arm64.
- **`--rm` is not implied** — stopped containers linger in `ls -a` until removed; `container prune` clears them.
- **Per-container VM** means slightly higher startup cost than Docker's shared-kernel containers, in exchange for isolation.
- **`machine`** (`container machine ...`) manages the underlying container VMs/kernel; most work never needs it, but it's there for custom kernels or resource tuning.

## Discovering the current surface

`container --help` lists all subcommand groups; `container <group> --help` and `container <cmd> --help` document each. Prefer those over anything hardcoded here for the installed version. Global `--debug` (or `CONTAINER_DEBUG=1`) surfaces internal detail when a command misbehaves.

## Do not use when

- The project targets Docker/Podman specifically (a `docker compose` stack, `docker buildx`, Docker-only tooling) — `container` has no Compose equivalent, so use Docker there rather than hand-translating multi-service stacks.
- On an Intel Mac — `container` requires Apple Silicon.
