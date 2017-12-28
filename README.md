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



