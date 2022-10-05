
This project deploys the photo-shop web server in kubernetes.
A service is created to be able to access the pod server from outside the node. 


In order to deploy the whole cluster:

```console
kubectl apply -f .
```

Cluster components:

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




