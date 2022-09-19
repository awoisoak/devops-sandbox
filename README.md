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


This project deploys the photo-shop web server in kubernetes.
A service is created to be able to access the pod server from outside the node. 


In order to deploy the environment:

```console
kubectl apply -f deployment.yaml
```

To expose the application outside the node run the corresponding service with:

```console
kubectl apply -f service.yaml
```

You should be able to access the web server running in the pods through the new NodePort ip:port generated:
```console




➜  kubernetes git:(master) ✗ kubectl get service
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes           ClusterIP   10.96.0.1       <none>        443/TCP          135m
photo-shop-service   NodePort    10.98.145.171   <none>        9000:30000/TCP   7s
```

However, if you are running K8s on minikube you will have to obtain the ip:port from this command.

```console
➜  kubernetes git:(master) ✗ minikube service photo-shop-service --url
http://127.0.0.1:51781
```




