<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

# at_Split_Horizon_Root aka shrd

TLDR;
Some times you might want to run your own atDirectory (root server), perhaps your network is not connected to the Internet or maybe Internet access is not always available.
If that is the case, shrd is the solution. Your atPlatform code can point at the shrd and it will answer with your atServers locations on your network. If the atSign being looked up is not in your config then it will be forwarded to the Internet and resolved, if the Internet is not available then the lookup will fail sending back a 'null'.

## Why is this called Split Horizon Root ?
DNS has for years had the same functionality for DNS lookups and this has been called split horizon DNS. In fact you may want to run a DNS sever in split horizon mode in conjuction with shrd!


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

| Argument        | Abbreviation | Mandatory | Description                                                                         |    Default    |
|-----------------|--------------|-----------|-------------------------------------------------------------------------------------|---------------|
| --port          | -p           | false     | TCP port number shrd listens on                                                     |      64       |
| --config        | -c           | false     | Configuration file for local atServers                                              |   atServers   |
| --ssl-fullchain | -f           | false     | SSL fullchain in PEM format                                                         | fullchain.pem |
| --ssl-privkey   | -k           | false     | SSL private key in PEM format                                                       |  privkey.pem  |

| Flags               | Abbreviation | Description                                                                     |
|---------------------|--------------|---------------------------------------------------------------------------------|
| --[no-]verbose      | -v           | More logging                                                                    |

### Configuration file atServers

The 'atServers' file should contain the atSigns and your networks resolver name of the atServer for the atSign. Use of local DNS or host files is very important as TLS will need to verify the atServers and shrd certificates match the resolved network name. 

For example the atServers file might contain 

```
colin cally.lan:6464
kevin cally.lan:6465
```

This would allow shrd to give the answer 'cally.lan:6464' to a lookup of 'colin' note the leading @ in the atSign is not needed in the configuration file. Also note comments can be put in this file with a '#` at the start of a line.

### Updating the atServers file whilst shrd is running

The shrd daemon will respond to a 'kill -SIGHUP' by re-reading the configuration file, this allows new atSigns to be added or removed without taking down the server. Note however that the whole database is first cleared before updating so for a brief period of time 'null' maybe returned for a valid lookup. This may be addressed in updates, please raise an issue if this causes you concern or problems.

## Who is this tool for?

System Admins  
Network Admins  
Network Manufacturers


## Maintainers

Created by Atsign 

Original code by [@cconstab](https://github.com/cconstab)

