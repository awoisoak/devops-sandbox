This project uses Docker Compose to run a load balancer, a database and a given number of [photo-shop](https://github.com/awoisoak/photo-shop/) web servers. All of them running on their own docker container.

In order to run the infrastructure specify how many web servers instances you want to launch:

    docker compose up --scale web=3 &

Repeating the command with a different number will scale up/down the web servers with no down time.

The load balancer will be accesible at:

    localhost:8080

The page returned will display the pictures registered in the database along with the specific web server instance that processed the request. 

<p align="center">
<img src="https://user-images.githubusercontent.com/11469990/201255145-ec5471f9-1b5a-41f9-beeb-943e3b6bb0e4.png" width="500" />
</p>
