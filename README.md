<img width=250px src="https://atsign.dev/assets/img/atPlatform_logo_gray.svg?sanitize=true">

# atSplitHorizonRoot aka shrd

TLDR;
Some times you might want to runn your own atDirectory (root server), perhaps your network is not connected to the Internet or maybe Internet access is not always available.
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
dart run bin/sshnpd.dart <args|flags>
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


## Who is this tool for?

System Admins  
Network Admins  
Network Manufacturers


## Maintainers

Created by Atsign 

Original code by [@cconstab](https://github.com/cconstab)

