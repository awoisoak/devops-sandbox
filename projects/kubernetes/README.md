
This project deploys the photo-shop web server in kubernetes.
A service is created to be able to access the pod server from outside the node. 


In order to deploy the environment:

`kubectl apply -f deployment.yaml`

To expose the application outside the node run the corresponding service with:

`kubectl apply -f service.yaml `   

You should be able to access the web server running in the pods through the new NodePort ip:port generated:
```shell
➜  kubernetes git:(master) ✗ kubectl get service
NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
kubernetes           ClusterIP   10.96.0.1       <none>        443/TCP          135m
photo-shop-service   NodePort    10.98.145.171   <none>        9000:30000/TCP   7s
```

However, if you are running K8s on minikube you will have to obtain the ip:port from this command.

```shell
➜  kubernetes git:(master) ✗ minikube service photo-shop-service --url
http://127.0.0.1:51781
```




