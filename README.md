# Lace-Vagrant
Vagrant provisioning for a Lace editing environment
##Quick Start
- `cd Lace-Vagrant`
- `vagrant box add ubuntu/trusty64`
- `vagrant up`
- Reach your Lace editor at [http://localhost:8135](http://localhost:8135)

##Security
- Default username: admin; password: secret
- `vagrant ssh`
- Change username and password:
`vim Lace/authentication.py`
- Change line reading `return username == 'admin' and password == 'secret'`


