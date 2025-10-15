<!-- pyml disable-num-lines 4 md033-->
<h1><a href="https://atsign.com#gh-light-mode-only">
<img width=250px src="https://atsign.com/wp-content/uploads/2022/05/atsign-logo-horizontal-color2022.svg#gh-light-mode-only"
alt="The Atsign Foundation"></a><a href="https://atsign.com#gh-dark-mode-only">
<img width=250px src="https://atsign.com/wp-content/uploads/2023/08/atsign-logo-horizontal-reverse2022-Color.svg#gh-dark-mode-only"
alt="The Atsign Foundation"></a></h1>

[![SLSA 3](https://slsa.dev/images/gh-badge-level3.svg)](https://slsa.dev)

# at_Split_Horizon_Root aka shrd

TLDR;
Some times you might want to run your own atDirectory (root server), perhaps
your network is not connected to the Internet or maybe Internet access is not
always available.

If that is the case, shrd is the solution. Your atPlatform code can point at
the shrd and it will answer with your atServers locations on your network. If
the atSign being looked up is not in your config then it will be forwarded to
the Internet and resolved, if the Internet is not available then the lookup
will fail sending back a 'null'.

## Why is this called Split Horizon Root ?

DNS has for years had the same functionality for DNS lookups and this has
been called split horizon DNS. In fact you may want to run a DNS sever in
split horizon mode in conjuction with shrd!

## Quick tour

There is just one binary:-

`shrd` : The atSplitHorizonRoot daemon.

## Usage

### shrd (daemon)

Run the daemon binary file or the dart file:

```sh
./shrd <args|flags>
```

```sh
dart run bin/at_split_horizon_root.dart <args|flags>
```

<!-- pyml disable-num-lines 10 md013-->
| Argument        | Abbreviation | Mandatory | Description                                                                         |    Default    |
|-----------------|--------------|-----------|-------------------------------------------------------------------------------------|---------------|
| --port          | -p           | false     | TCP port number shrd listens on                                                     |      64       |
| --config        | -c           | false     | Configuration file for local atServers                                              |   atServers   |
| --ssl-fullchain | -f           | false     | SSL fullchain in PEM format                                                         | fullchain.pem |
| --ssl-privkey   | -k           | false     | SSL private key in PEM format                                                       |  privkey.pem  |

| Flags               | Abbreviation | Description                                                                     |
|---------------------|--------------|---------------------------------------------------------------------------------|
| --[no-]verbose      | -v           | More logging                                                                    |

### shrd in Docker

The latest version of the docker image can be found at
`atsigncompany/shrd:latest` on dockerhub.com. Usage is simple enough as well.
For example:

```sh
docker run -it  -v <directory conatiuning files>:/atsign/shrd \
-p 64:64  atsigncompany/shrd -v
```

This will run shrd and use the .pem files and the atServers file in the
specified directory and expose port 64 and then finally log
connections/lookups made by clients.

### Configuration file atServers

The 'atServers' file should contain the atSigns and your networks resolver
name of the atServer for the atSign. Use of local DNS or host files is very
important as TLS will need to verify the atServers and shrd certificates match
the resolved network name.

For example the atServers file might contain:

```txt
colin cally.lan:6464
kevin cally.lan:6465
```

This would allow shrd to give the answer `cally.lan:6464` to a lookup of
`colin` note the leading @ in the atSign is not needed in the configuration
file. Also note comments can be put in this file with a `#` at the start of a
line.

### Updating the atServers file whilst shrd is running

The shrd daemon will respond to a 'kill -SIGHUP' by re-reading the
configuration file, this allows new atSigns to be added or removed without
taking down the server. Note however that the whole database is first cleared
before updating so for a brief period of time 'null' maybe returned for a
valid lookup. This may be addressed in updates, please raise an issue if this
causes you concern or problems.

## Who is this tool for?

System Admins  
Network Admins  
Network Manufacturers

## SLSA

The Docker images created from this repo have SLSA Build Level 3 attestations.

These can be verified using the
[slsa-verifier](https://github.com/slsa-framework/slsa-verifier) tool e.g.:

```sh
IMAGE="atsigncompany/shrd:latest"
SHA=$(docker buildx imagetools inspect ${IMAGE} \
  --format "{{json .Manifest}}" | jq -r .digest)
slsa-verifier verify-image ${IMAGE}@${SHA} \
  --source-uri github.com/atsign-foundation/at_split_horizon_root
```

## Docker image signing

This images from this repo are signed during the build process so that you
can verify their authenticity using
[cosign](https://github.com/sigstore/cosign):

```sh
cosign verify atsigncompany/shrd:latest \
--certificate-oidc-issuer=https://token.actions.githubusercontent.com \
--certificate-identity-regexp='^https://github.com/atsign-foundation/at_split_horizon_root/.+'
```

## Maintainers

Created by Atsign

Original code by [@cconstab](https://github.com/cconstab)
