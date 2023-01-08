There are two Terraform projects 
- 'infrastructure'
- 'pre-infrastructure'

The infrastructure tf project defines a [Cloud Run](https://cloud.google.com/run/) service with a prepopulated image of photo-shop web server within the Artifact Registry.
When the 'infrastructure' projects is setup the Artifact Registry must be already created and must contain the required Docker image. Because of that it is not created within this Terraform project.

The 'pre-infrastructure' Terraform project is in charge of two main tasks:
- Setting up the [Artifact Registry](https://cloud.google.com/artifact-registry/) where the photo-shop Docker image used by 'infraestructre' will be uploaded.
  
- Create the Bucket where 'infrastructure' will push its state files.

The idea is to keep the main 'infrastructure' tf state saved privately in a protected storage which furthermore allows [state locking](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).

The state of 'pre-infrastructure' does not include any sensible information so can be pushed to the repo itself in plain text.

In order to setup the whole thing follow this steps:

Setup pre-infrastructure tf project
```
cd pre-infrastructure
terraform init
terraform apply
```

Pull photo-shop image from Docker Hub
```
docker pull awoisoak/photo-shop
```

Tag image aiming to the Artifact Registry repository created
```
docker tag awoisoak/photo-shop us-west1-docker.pkg.dev/cloud-run-photoshop/my-repository/photo-shop
```

Upload the imagee to the Artifact Registry repository
```
docker push us-west1-docker.pkg.dev/cloud-run-photoshop/my-repository/photo-shop
```
Setup infrastructure tf project
```
cd ../infrastructure
terraform init
terraform apply
```

The `output` of the last command should display the URL of the photoshop web server running as a service within Google Cloud Run.

Once you are finished don't forget to settle down both infrastructures
```
tf destroy && cd ../pre-infrastructure && tf destroy
```