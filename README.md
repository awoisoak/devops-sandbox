Repository to play with different devops scenarios found under [projects](https://github.com/awoisoak/devops-sandbox/tree/master/projects).

# Projects

## Bash
This script automatically build an environment with a Flask Python web server which exposes port 9000. In order to build the environment simply execute the script:

    bash photo-shop.sh

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/bash/script.gif)


----------


## Docker Compose

This project uses Docker Compose to run the [photo-shop](https://github.com/awoisoak/photo-shop/) web server together to a Mariadb server. Both will run independently in their own Docker container.

The web server will display the images registered in the database and will expose port 9000 in the localhost. In order to run the containers simply execute:

    docker compose up

![alt](https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/docker-compose/architecture.jpg)


----------


## Kubernetes



This project runs a Kubernetes cluster with a [photo-shop](https://github.com/awoisoak/photo-shop) server deployment and a mariadb database one


 ### db-deploy.yaml
Database deployment consist of just one replica set.
As explained in [mariadb Docker image](https://hub.docker.com/_/mariadb) the initialization of a fresh database is done via scripts found in /docker-entrypoint-initdb.d. 
The scripts are defined via a Config map (db-configmap.yaml) and are located in the above directory via a mounted volume. 
 ### db-service.yaml 
Cluster Ip service to expose the database 
 ### db-configmap.yaml
Config map to contain the sql script used to initialize the database
 ### web-deploy.yaml
Frontend deployments of [photo-shop](https://github.com/awoisoak/photo-shop) consisting of 2 replica sets.
 ### web-service.yaml
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




