This sample shows how to use workspaces to be able to reuse code in different projects.
In order to generate all resources we need first to create the workspaces:

 terraform workspace new "us-payroll" 
 terraform workspace new "uk-payroll" 
 terraform workspace new "india-payroll"

 and then select them and run tf apply 

  terraform workspace select "us-payroll" && terraform apply

  terraform workspace select "uk-payroll" && terraform apply

   terraform workspace select "india-payroll" && terraform apply