# ansible-devstack
Ansible playbook to build a basic DevStack instance inside of an OpenStack public cloud.

Requirements
------------
This presumes I have ansible and python-novaclient installed and I have sourced my openrc file.

Usage
-----
.. code-block:: bash
$ ./boot instance-name flavor
$ ansible-playbook devstack_setup/setup.yml -i instance-name
where ```instance-name``` and ```flavor``` are replaced by my values

This should result in allowing me to ssh into my new host su down to the ubuntu user and start interacting with the DevStack installed in /opt/devstack

Notes
-----
* probably should generate an openrc for the ubuntu user and source it in the ubuntu .profile
* maybe make the local.conf file configurable or customizable because it uses a stock config file from the docs.

See "http://docs.openstack.org/developer/devstack/" for more on DevStack.
