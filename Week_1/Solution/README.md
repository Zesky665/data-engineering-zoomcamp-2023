# Solution for Week_1 of DE ZoomCamp 

To set up, make sure you have the following installed. 

Terraform
Python
AWS CLI

The follwoing enviourmental variables set. 

AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY

In order to set up the enviourment, run the following commands. 

Generate the keypair that your going to use to ssh into the EC2 instance. 

`ssh-keygen -t rsa -b 4096 -m pem -f prefect_kp && openssl rsa -in prefect_kp -outform pem && mv prefect_kp prefect_kp.pem && chmod 400 prefect_kp.pem`

You also need to create a `secrets.tfvars` file to hold all your sensitive information. Put the following information into this file. 

```
db_username = "YOUR_DB_USERNAME"
db_password = "YOUR_DB_PASSWORD"
my_ip = "YOUR IP ADDRESS" // use 'curl https://checkip.amazonaws.com' to find it

```

Initiate the terraform script. You might be asked to login to terraform cloud. 
`terraform init`

Check if you have all the values needed to apply the script. 
`terraform plan`

Apply the script, this will build the infrasctructure, it will take a couple of minutes to execute. 
`terraform apply -var-file="secrets.tfvars"`

After everything has been built, use the `web_public_ip = "THE_EC2_IP_ADDRESS"` to ssh into the EC2 instance. 

`ssh -i "prefect_kp.pem" ubuntu@$(terraform output -raw web_public_dns)`

If you're planing to use VS Code to log in, press "Open Remote Window" in the bottom left corner, then press "Open SSH Configuration File". Pick the first option and add the following into that file. 

```
Host tutorial
  HostName EC2_IP_ADDRESS
  User ubuntu
  IdentityFile ~/.ssh/prefect_kp.pem // You have to copy this manually
```

Now you can open a remote window by, pressing "Open Remote Window" and selecting "Connect to Host" and picking the 'tutorial' option. 

Once you have connected you can check if the postgres db is accessible from the ec2 instance. 

First install the necessary packages. 

`sudo apt-get update && sudo apt-get install postgresql`

After that finishes, run the following to login to the db. 

`psql -h database.endpoint --port=5432 -U username --dbname=db_name`

You will be prompted to enter the password that you set in the `secret.tfvars` file.
