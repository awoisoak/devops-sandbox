Ansible requires that remote hosts have python installed.
Since nginx docker image does not include python this project uses awoisoak/nginx-python.


We could install python when executing 'docker compose up' and, if need, we could let ansible know python path via the inventory (ansible_python_interpreter=/usr/bin/python3)
However this brings issues with nginx and the development process in general takes much longer since we need to update and install dependencies every single time we up/down docker compose. 

We can not made use of a static inventory like [inventory.txt](https://github.com/awoisoak/devops-sandbox/blob/ansible/projects/ansible/inventory.txt) since it would only work when 3 webs servers were instantiated.

    docker compose up --scale web=3

Because of that, in this scenario we need a dynamic [docker container inventory](https://). On this case 
ansible-galaxy collection install community.docker