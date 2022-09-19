This project uses Docker Compose to run the [photo-shop](https://github.com/awoisoak/photo-shop/) together to a Mariadb server. Both will run independently in their own Docker container.

The web server will display the images registered in the database and will expose port 9000 in the localhost. In order to run the containers simply execute:

    docker compose up

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/docker-compose/architecture.jpg)