This 'state-infrastructure' Terraform project is just in charge of creating the bucket that will later be used by the main Terraform project (under infrastructure folder) to upload its own tf state.
The idea is to keep the main infrastructure tf state saved privately in a protected storage which furthermore allows [state locking](https://developer.hashicorp.com/terraform/language/settings/backends/gcs).

The state of this 'state-infrastructure' does not include any sensible information so can be pushed to the repo itself in plan text.