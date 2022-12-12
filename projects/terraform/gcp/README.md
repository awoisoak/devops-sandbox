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

