Repository to play with different devops [projects](https://github.com/awoisoak/devops-sandbox/tree/master/projects).

## Project Bash
This script automatically build an environment with a Flask Python web server which exposes port 9000. In order to build the environment simply execute the script:

    bash photo-shop.sh

<p align="center">
<img width="500" alt="deploy" src="https://raw.githubusercontent.com/awoisoak/devops-sandbox/master/projects/bash/script.gif">
</p>

----------

## Project CI/CD (Github Actions)
Pipeline created with Github Actions for the [Camera Exposure Calculator]([https://github.com/awoisoak/photo-shop](https://github.com/awoisoak/Camera-Exposure-Calculator)) app. 
 #### ci.yaml
 This workflow will build and upload the corresponding artifacts for [each commit](https://github.com/awoisoak/Camera-Exposure-Calculator/actions/runs/3228411301) pushed to the repository.


 #### google_play_deployment.yml.yaml

 This workflow allows the deployment of the app to [Google Play](https://play.google.com/store/apps/details?id=com.awoisoak.exposure) with a simple interface.

<p align="center">
<img width="317" alt="deploy" src="https://user-images.githubusercontent.com/11469990/195251751-bc819862-ed0f-47bd-bef5-bedb16465bd2.png">
</p>

All sensible data for the deployments is kept within the Github Secrets including the base64 coding of the signing key which will decode during the process to be able to sign the app.
Using [Gradle Play Publisher](https://github.com/Triple-T/gradle-play-publisher) within the app code it will publish the app listing to the Google Play and will deploy a 10% rollout in the passed track.
Lastly will create a [Github Release](https://github.com/awoisoak/Camera-Exposure-Calculator/releases/tag/1.8) with the attached app bundle.

----------

## Project Docker Compose

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



----------


## Project Kubernetes




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


## Project AWS Terraform

The Terraform files will deploy the next infrastructure

<img width="1380" alt="aws" src="https://user-images.githubusercontent.com/11469990/199511219-b2c25415-cd76-46a9-9346-a7868a51f17f.png">



- The VPC contains 3 subnets: 1 public and 2 privates.
- The web server is located in the public one to be accessed by users.
- The database is located in one of the private subnets 
- RDS needs a 'DB subnet group' which requires at least 2 subnets in different Availability Zones to create a new standby if needed in the future [(+info)](https://aws.amazon.com/rds/faqs/)
- The web server only accepts http and ssh connections from outside (ssh should be limited to the admin ip in production)
- The database only accepts connections in the port 3306 from the EC2 instance




This project assumes that Terraform was setup with the corresponding AWS account.


To see the exact changes that Terraform will apply: 
```console
terraform plan -var-file="secrets.tfvars"
```
To trigger the infraestructure setup:
```console
terraform apply -var-file="secrets.tfvars"
```
All components are using Free Tier components but make sure you destroy them once you stop working with them to avoid being charged:

```console
terraform destroy -var-file="secrets.tfvars"
```

In order to initialize the DB with some data we will have to do it through a SSH tunnel (SSH port forwarding) through the EC2:

```console
sh -i "$PRIVATE_KEY_PATH" -N -L 6666:$DB_ADDRESS:3306 ec2-user@$WEB_ADDRESS
```

With the tunnel above setup, all connections againt our localhost:6666 will be forward to the 3306 port of the RDS allowing us to populate the DB:         

```console
mysql -u $DB_USER -p$DB_PASSWORD -h 127.0.0.1 -P 6666 < scripts/setup_db.sql
```




----------


## Project GCP Terraform

<img width="1380" src="https://user-images.githubusercontent.com/11469990/206996661-560a55f0-5dff-4ff1-8dad-db8a91e65292.png">

Similar infraestructure than the one from the [AWS project](https://github.com/awoisoak/devops-sandbox/tree/master/projects/terraform/aws) with some GCP peculiarities,
In order to configure a Cloud SQL instance with a private IP it is required to have [private services access](https://cloud.google.com/vpc/docs/private-services-access) which allow us to create private connections between our VPC networks and the underlying Google service producer's VPC network
### Setup Infraestructure.

This project assumes that Terraform was setup with the corresponding GCP account.


To see the exact changes that Terraform will apply: 
```console
terraform plan -var-file="secrets.tfvars"
```
To trigger the infraestructure setup:
```console
terraform apply -var-file="secrets.tfvars"
```
Make sure you destroy all resources once you stop working with them to avoid being charged:
(If a storage bucket was created to initialize the DB make sure you remove it manually too)

```console
terraform destroy -var-file="secrets.tfvars"
```




### Database Initialization

We can initialize the db with a sql script uploaded via GCP web interface.
For that we need to create a bucket where the sql script is uploaded
[Cloud SQL](https://console.cloud.google.com/sql/instances/database/) > IMPORT > BUCKET > setup-db.sql


Since the Photoshop web server is using a db user called 'user', we need to create it via [gcloud](https://cloud.google.com/sdk/docs/install)

        gcloud sql users create user \
        --host=% \
        --instance=database \
        --password=password

### Troubleshooting

- Cloud SQL comes by default with a root user. To set a default password to it:

        gcloud sql users set-password root \
        --host=% \
        --instance=database \
        --prompt-for-password
(*root:%* does not have almost any privileges by default but the users created via gcloud will)

- Confirm DB connection from Compute Engine 
        
        mysql --user=root -p -h DB_PRIVATE_IP

- To connect to Compute Engine from our local terminal (instead of using cloud shell). Add our public key to ~/.ssh/authorized_keys file in Compute Engine and make sure it has the corresponding permissions
            
        chmod 600 ~/.ssh/authorized_keys

- Confirm SSH connection to Compute Engine
  
        ssh -i $HOME/.ssh/google_compute_engine  awoisoak_devops@COMPUTE_ENGINE_PUBLIC_IP        

Since we manually created a bucket storage to upload the scripts/setup_db.sql file, make sure you [delete it](https://console.cloud.google.com/storage/browser) to avoid being charged (It won't be deleted by Terraform!)



----------


## Project Ansible

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


----------


## Project Prometheus

A Prometheus server is setup together with an instance of AlertManager, Grafana, and a bunch of servers and Exporters.
[AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) is configured to send alert notifications via email.

How metrics are generated:
 - The host metrics are exposed through a [Node exporter](https://github.com/prometheus/node_exporter)
 - Containers metrics are exposed by a [Cadvisor exporter](https://github.com/google/cadvisor)
 - The stand alone [Photo-shop](https://github.com/awoisoak/photo-shop) web server internally exposes app metrics 
  
  TODO: The Photo-shop running behind the load balancer can't be scrapped by Prometheus. The web server instances should probably be [pushing metrics](https://prometheus.io/docs/instrumenting/pushing/) instead. 

<img width="1355" alt="grafana" src="https://user-images.githubusercontent.com/11469990/203922046-ad55f9f0-43a2-40dc-afb0-fa995c5648d1.png">


----------


## Project Python

Different handy Python projects for DevOps

### Spreadsheet
    Run operations given a spreadsheet and add new fields to it

### AWS
    Run several operations against an AWS account

    - Create VPCs
    - Create EC2 instances
    - Monitoring EC2 instances
    - Create Snapshots
    - Create volumes and restore backup snapshots in it
    - Clean resources

### Web monitoring
    Monitor websites 

    - Handle different environments:
        - Running web server in a local container
        - Running web server in a EC2 instance 
    - Send alerts via email when applications are not available
    - Connecting to remote EC2 instance via SSH
    - Try to recover the application from different scenarios
        - Restarting local containers
        - Restart remote host and/or its services
