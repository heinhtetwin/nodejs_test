# NodeApp-Testing



## Steps I took without Terraform

### Creating Ansible 

- Create ansible roles to provide automating things like installing docker, docker compose and other necessary services.
- My ansible folder contains three roles named apt, docker and deploy.
    - The `apt` role performs tasks related to the apt package manager, such as updating and upgrading packages currently installed in our system.
    - The `docker` role performs tasks such as installing docker and docker-compose package in our system and automatically starts docker service after rebooting. 
    - The `deploy` role performs tasks such as cloning our source git repo into application server, and run our nodejs-application container with docker-compose file inside a systemd service. So, our application will restart automatically even after reboot.

### Manual Provisioning

- Initially, I tested with manually provisiong from AWS Management console. I created a custom VPC which contains two subnets: 2 public and 1 private subnet. 
- Within that VPC, I provisioned an ec2 instance in public subnet for the purpose of jump_host and one ec2 instance in private subnet for the purpose of our node application server.
- I provisioned 2 Elastic IP addresses: one for our jump_host and another one for NAT Gateway to be able to access internet from my app server in the private subnet.
- I also created 3 Security Groups, respective each for my jump_host, my app_server and ALB. 
- Finally, I created a Target Group which associates with my node application server ( the one in private subnet ). Then, I implemented a ALB ( Application Load Balancer ) in the same VPC and points the HTTP traffic to the Target Group I created.
- I modified the security group of my application server so that it receives HTTP traffic incoming only from our Application Load Balancer.

### Creating a Web ACL for our application

- Last but not at least, I also provisioned a Web ACL rule for URL restriction task. 
- I created a Rule Group which includes two rules: one for denying all traffic incoming into /admin path, another one for allowing access to /admin path if a request originates from a specific source IP address.
- You can view my WebACL json file [here](./webACL.json).


## Steps I took with TerraForm

### Creating Terraform scripts
- For above manual provisioned infrastructure, I developed a terraform script to automatically create all necessary ec2 instances, security groups and ALB for our Node Application.
- So, You can just run one `terraform apply` command and all necessary infrastructure will be provisioned. I will demonstrate usage of my repository in below. 


# How to use
- Clone the git repo into your machine where you will run terraform scripts.
```
git clone https://github.com/heinhtetwin/nodejs_test_AYA.git
cd terraform 
```
- Install Terraform in your system and push terraform codes.
```
terraform init
terraform validate
terraform plan -var-file=values/node/test.tfvars -out <file-name>
terraform apply <file-name>
```
- Test ssh connections into your hosts. 
```sh
For bastion_host -> ssh ubuntu@<jump-host> -i </path/to/your/key>
For application server host -> ssh -J ubuntu@<jump_host> ubuntu@<node-app-host> -i </path/to/your/key>
```
- SSH into jump_box host and clone the git repo.
```
git clone https://github.com/heinhtetwin/nodejs_test_AYA.git
```
- You may need to do a few manaual steps in order to run ansible playbooks from your bastion host into node-app host.
- As ubuntu user from your bastion host,
```sh
ssh-keygen
```
- And copy your public key of ubuntu user into root user home directory of node-app host.
- To test your ssh connection:
```
ansible -m ping nodejs-test -e "ansible_ssh_host=<app_server_ip> host_vars
=nodejs-test"
```
- Then actually run the playbook:
```
ansible-playbook -v main.yaml -e "ansible_ssh_host=<app_server_ip> host_vars
=nodejs-test"
```
- **Change <app_server_ip> with your IP of ec2 instance in private subnet.**

# Testing
- Now, you can access NodeJS application through ALB from this [URL](http://node-lb-521744530.ap-south-1.elb.amazonaws.com/).
- You can access '/' path from all IP addressed but you can only access '/admin' path from only provided IP address that is **116.206.137.18/32**.

# Reference

I referenced Ko Pyae Phyoe Shein's [Blog Post](https://awstip.com/to-set-up-docker-container-inside-ec2-instance-with-terraform-3af5d53e54ba) here, this [public repo](https://github.com/ppshein/terraform-sample-ec2) and other blog posts in internet to create this Repository.
