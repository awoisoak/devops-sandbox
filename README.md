Repository to play with different devops scenarios found under [projects](https://github.com/awoisoak/devops-sandbox/tree/master/projects).

# Projects

## Bash
This script automatically build an environment with a Flask Python web server which exposes port 9000. In order to build the environment simply execute the script:

    bash photo-shop.sh

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/bash/script.gif)


----------

## CI/CD 
Pipeline created with Github Actions for the [Camera Exposure Calculator]([https://github.com/awoisoak/photo-shop](https://github.com/awoisoak/Camera-Exposure-Calculator)) app. 
 ### ci.yaml
 This workflow will build and upload the corresponding artifacts for [each commit](https://github.com/awoisoak/Camera-Exposure-Calculator/actions/runs/3228411301) pushed to the repository.


 ### google_play_deployment.yml.yaml

 This workflow allows the deployment of the app to [Google Play](https://play.google.com/store/apps/details?id=com.awoisoak.exposure) with a simple interface.

<p align="center">
<img width="317" alt="deploy" src="https://user-images.githubusercontent.com/11469990/195251751-bc819862-ed0f-47bd-bef5-bedb16465bd2.png">
</p>

All sensible data for the deployments is kept within the Github Secrets including the base64 coding of the signing key which will decode during the process to be able to sign the app.
Using [Gradle Play Publisher](https://github.com/Triple-T/gradle-play-publisher) within the app code it will publish the app listing to the Google Play and will deploy a 10% rollout in the passed track.
Lastly will create a [Github Release](https://github.com/awoisoak/Camera-Exposure-Calculator/releases/tag/1.8) with the attached app bundle.

----------

## Docker Compose

This project uses Docker Compose to run the [photo-shop](https://github.com/awoisoak/photo-shop/) web server together to a Mariadb server. Both will run independently in their own Docker container.

The web server will display the images registered in the database and will expose port 9000 in the localhost. In order to run the containers simply execute:

    docker compose up

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/docker-compose/architecture.jpg)


----------


## Kubernetes




This project runs a Kubernetes cluster with two deployments: one for a [photo-shop](https://github.com/awoisoak/photo-shop) web server and another one for a mariadb database.


<p align="center">
<img src="https://github.com/awoisoak/devops-sandbox/blob/master/projects/kubernetes/diagram.png" width="500" />
</p>

 ##### db-deploy.yaml
Database deployment consist of just one replica set.
As explained in [mariadb Docker image](https://hub.docker.com/_/mariadb) the initialization of a fresh database is done via scripts found in /docker-entrypoint-initdb.d. 
The scripts are defined via a Config map (db-configmap.yaml) and are located in the above directory via a mounted volume. 
 ##### db-service.yaml 
Cluster Ip service to expose the database 
 ##### db-configmap.yaml
Config map to contain the sql script used to initialize the database
 ##### web-deploy.yaml
Frontend deployments of [photo-shop](https://github.com/awoisoak/photo-shop) consisting of 2 replica sets.
 ##### web-service.yaml
NodePort service to expose the frontend outside of the cluster


In order to deploy the whole cluster:

```console
kubectl apply -f .
```


You should be able to access the web server running in the pods through the new NodePort ip:port generated:
```console
➜  kubernetes git:(master) ✗ kubectl get service
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
db-service           ClusterIP   10.108.255.121   <none>        3306/TCP         19m
kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP          24m
photo-shop-service   NodePort    10.101.35.13     <none>        9000:30000/TCP   19m
```

However, if you are running K8s on minikube you will have to obtain the ip:port from this command.

```console
➜  kubernetes git:(master) ✗ minikube service photo-shop-service --url
http://127.0.0.1:51781
```

----------


## Terraform

The Terraform files will deploy the next infrastructure

<img width="1380" alt="aws" src="https://user-images.githubusercontent.com/11469990/199507512-b1e9e25c-9d9a-4219-b91c-cc426753750c.png">


- The VPC contains 3 subnets: 1 public and 2 privates.
- The web server is located in the public one to be accessed by users.
- The database is located in one of the private subnets 
- RDS needs a 'DB subnet group' which requires at least 2 subnets in different Availability Zones to create a new standby if needed in the future [(+info)](https://aws.amazon.com/rds/faqs/)
- The web server only accepts http and ssh connections from outside (ssh should be limited to the admin ip in production)
- The database only accepts connections in the port 3306 from the EC2 instance

In order to initialize the DB with some data we will have to do it through a SSH tunnel (SSH port forwarding) through the EC2:

```consoles
sh -i "$PRIVATE_KEY_PATH" -N -L 6666:$DB_ADDRESS:3306 ec2-user@$WEB_ADDRESS
```

With the tunnel above setup, all connections againt our localhost:6666 will be forward to the 3306 port of the RDS allowing us to populate the DB:         

```console
mysql -u $DB_USER -p$DB_PASSWORD -h 127.0.0.1 -P 6666 < scripts/setup_db.sql
```



