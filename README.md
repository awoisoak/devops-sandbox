Repository to play with different devops scenarios found under [projects]([https://](https://github.com/awoisoak/devops-sandbox/tree/master/projects)).

# Projects

## Bash
This script automatically build an environment with a Flask Python web server which exposes port 9000. In order to build the environment simply execute the script:

    bash photo-shop.sh

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/bash/script.gif)


----------


## Docker Compose

This application has a Flask Python web and a Mariadb server. Both are running independently in their own Docker container.

The web server will display the images registered in the database and will expose port 9000 in the localhost. In order to run the containers simply execute:

    docker compose up

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/photo-shop/architecture.jpg)
