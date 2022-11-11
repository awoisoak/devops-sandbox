Ansible requires that remote hosts have python installed.
Since nginx docker image does not include python this project uses awoisoak/nginx-python.


We could install python when executing 'docker compose up' and, if need, we could let ansible know python path via the inventory (ansible_python_interpreter=/usr/bin/python3)
However this brings issues with nginx and the development process in general takes much longer since we need to update and install dependencies every single time we up/down docker compose. 

Making use of a static inventory like [inventory.txt](https://github.com/awoisoak/devops-sandbox/blob/ansible/projects/ansible/inventory.txt) is not ideal since the number of web servers is hardcoded and the user might want to scale up/down depending on the circunstances.

Because of that, in this scenario we need a dynamic [docker container inventory](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_containers_inventory.html). To install it:

    ansible-galaxy collection install community.docker
    pip install docker
Now we can generate a dynamic docker inventory by adding [inventory.docker.yaml](https://github.com/awoisoak/devops-sandbox/blob/ansible/projects/ansible/inventory.txt)

To get the dynamic list of Docker hosts:

    ansible-inventory -i inventory.docker.yaml --list --yaml

To get all possibles metadata to be used to make groups:

    ansible-inventory -i inventory.docker.yaml --list | grep -i docker_

The Docker Compose will launch a Load balancer, a database and a number of web servers specified by the user.

    docker compose up --scale web=3


We can now create our [playbook.yaml](https://github.com/awoisoak/devops-sandbox/blob/ansible/projects/ansible/inventory.txt) to automate all kinf of tasks in the different servers.     

    docker compose up --scale web=3
    ansible-playbook -i inventory.txt playbook.yaml
