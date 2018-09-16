# Lace Is Upgraded!
Lace is now [Lace2](https://github.com/brobertson/Lace2), an eXist-db application. This simplifies building and running 
the project, so for now at least, Vagrant is not necessary. If testing and evaluation requires a new Vagrant provisioning,
it will be stored on GitHub as Lace2-Vagrant.

# Lace-Vagrant
Vagrant provisioning for a [Lace](https://github.com/brobertson/Lace)  editing environment

## Quick Start
- `cd Lace-Vagrant`
- `vagrant box add bento/ubuntu-16.04`(If this doesn't work, check vagrant -v: is it => 1.9?)
- `vagrant up`
- Reach your Lace editor at [http://localhost:8135](http://localhost:8135)

## Security
- Default username: admin; password: secret
- `vagrant ssh`
- Change username and password:
`vim Lace/authentication.py`
- Change line reading `return username == 'admin' and password == 'secret'`



