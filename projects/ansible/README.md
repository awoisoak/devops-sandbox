Ansible requires remote hosts to have python installed so this project uses its own docker images.

Note: We could install python when executing 'docker compose up' and, if need, we could let ansible know python path via the inventory (ex. ansible_python_interpreter=/usr/bin/python3)
However this brings issues with nginx and the development process in general takes much longer since we need to update and install dependencies every single time we up/down docker compose. 

Making use of a static inventory like [inventory.txt](https://github.com/awoisoak/devops-sandbox/blob/master/projects/ansible/inventory.txt) is not ideal since the number of web servers is hardcoded and the user might want to scale up/down depending on the circunstances.

Because of that, in this scenario having a dynamic [docker container inventory](https://docs.ansible.com/ansible/latest/collections/community/docker/docker_containers_inventory.html) is a better approach. To install it:

    ansible-galaxy collection install community.docker
    pip install docker
Now we can generate a dynamic docker inventory by adding a [inventory.docker.yaml](https://github.com/awoisoak/devops-sandbox/blob/master/projects/ansible/inventory.docker.yaml)

To get the dynamic list of Docker hosts:

    ansible-inventory -i inventory.docker.yaml --list --yaml

To get all possibles metadata to be used to make groups:

    ansible-inventory -i inventory.docker.yaml --list | grep -i docker_

Once evertyhing is setup we can trigger Docker Compose which will launch a Load balancer, a database and the number of web servers we specify.

    docker compose up --scale web=3


We can now create our [playbook.yaml](https://github.com/awoisoak/devops-sandbox/blob/master/projects/ansible/playbook.yaml) to automate all kind of tasks in the different servers.     

    docker compose up --scale web=3
    ansible-playbook -i inventory.txt playbook.yaml
