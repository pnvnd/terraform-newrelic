# Terraform Examples with New Relic
Rename files to remove the `.example` extension and run the script.
Use `terraform init -upgrade -reconfigure` when you need to get back to a clean state.

## Installing Terraform on Windows
1. Download the [latest version of Terrafrom](https://www.terraform.io/downloads) `Amd64`
1. Extract `terraform.exe` to `C:\Windows`
1. Alternatively, extract `terraform.exe` to some other location and add the location to the User Environment Variable for `Path`  
   i. If your desired location is `C:\temp`, extract `terraform.exe` to `C:\Temp`  
   ii. Go to System Properties > Advanced > Environment Variables  
   iii. Edit User variable for `Path` and append `C:\Temp`
1. Open `cmd` or `PowerShell` terminal and enter `terraform version`
1. If you don't get any errors and see a version number, you should be good to go!

## Using Terraform
1. Clone or Fork this repository
1. `cd` into the repository where the `.tf` files are located
1. Make a copy of the `terraform.tfvars.sample` file and rename it to `terraform.tfvars`
1. Edit `terraform.tfvars`  
   i. Replace `new_relic_license_key` with your New Relic `INGEST - LICENSE` key  
   ii. Replace `new_relic_user_api_key` with your New Relic `User` API key  
   iii. Replace `new_relic_account_id` with your New Relic Account Number  
   iv. Replace `new_relic_region` with your New Relic account region (`US` or `EU`).  
1. Enter `terraform init` to start downloading the terraform providers
1. Enter `terraform plan` to see what the `.tf` files will do
1. Enter `terraform apply` and type `yes` to confirm creating the resources
1. If you don't need the resources any more, remove them with `terraform destroy`

## For Slack Destinations
1. `terraform import newrelic_notification_destination.slack-destination 17ed6b53-c8f9-4d9d-b02a-a25a38e4570d` (Use your own destination id)
2. `terraform state list` to make sure it's there
3. `terraform state show newrelic_notification_destination.slack-destination` to see the configuration
4. Copy the results from step 3 and paste into your terraform file.  Remove: `account_id`, `id`, `status`
5. Replace the following
   ```
   auth_token {
     prefix = "Bearer"
   }
   ```
   with

   ```  
   lifecycle {
     ignore_changes = [
       auth_token
     ]
   }
   ```
6. Use `terraform apply` as usual
7. IMPORTANT: Do `terraform state rm newrelic_notification_destination.slack-destination` first before `terraform destory` otherwise the Slack destination will be malformed.