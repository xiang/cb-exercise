# cb-exercise

# What this is:

a simple HTTP API, built in Go, that returns a JSON string containing the current time in GMT (and some memory stats), and automation to deploy it

# How to run it:

1. Initial prep

  install terraform: https://www.terraform.io/intro/getting-started/install.html
  set AWS creds as env vars

```
export AWS_ACCESS_KEY_ID="<key_id>"
export AWS_SECRET_ACCESS_KEY="<access_key>"
export AWS_DEFAULT_REGION="us-east-2"
```

  clone this repo
  
`git clone https://github.com/xiang/cb-exercise.git`
  
2. Build infrastructure

```
cd terraform
terraform apply
```

3. Access endpoint

`curl <instance IP>:8080`

# What I did:

I started working on the app locally. For prototyping I would generally choose Python or Ruby but I always treat these exercises as learning opportunities, so I went with Go. This app needs to autoscale, and my first thought was an ELB, but I didn't want to risk rate limiting, so the next idea was to simulate heavy resource utilization, which proved to be more difficult than expected. I started by attempting to hog memory only to find that AWS autoscaling doesn't seem to track memory, so I switched to CPU.

Once I had working code, I had to decide how to deploy it. The two most obvious options were standard EC2 instances and the ECS offering. I've never used ECS, and though it might've been simpler in an automation context, the documentation looked a bit complicated, and it's easier to troubleshoot with direct access to the OS, so I decided to stick with EC2.

I'm fond of the Hashicorp suite and Terraform was the first choice for infrastructure. The provisioning for the OS in this case is as simple as installing Docker and the container, so a config management tool seemed unnecessary. I first explored Packer, though I was disappointed to find that the configs are still JSON and the process is probably too complicated for my needs; these tasks could easily be run as a script via Terraform or cloud-init. I do think the automated image approach is viable and good potential choice for simpler environments, and it's something I would like to explore further.

I thought it would be trivial to push the app container to a docker registry and pull it remotely, but the authentication process requires the AWS CLI. I tried a public Docker Hub repo but that still requires auth and I didn't want to muck with management of secrets, so I opted to just clone the repo on the instance and build and run the binary on bootstrap. This is not optimal but there's no sensitive information in the repo and it's a much easier solution - in order to use the ECR, you would have to build the repo before the autoscale group, or build the group without instances, then update once the repo is available. Deploying the code directly does away with this step.

After some trial and error with the cloud-init script, I was able to get a fresh instance running the container on boot, but I wasn't able to trigger autoscaling reliably. Every time the endpoint is hit, the app will fire a goroutine that consumes some CPU. The idea was that accessing it repeatedly in a short period of time would stress the system enough to force scaling activity, but the usage has to be sustained over time, and I had difficulty accomplishing this even with stress testing tools. My account is also limited to one VM at the moment so the attempts to scale will only fail.


# Takeaways:

Always look at the bigger picture. If I had researched the autoscaling options more thoroughly before working on the app code, I probably wouldn't have spent so much time trying to figure out how to write an intentionally resource hungry app, but it was nonetheless an interesting exercise in OS interaction. I could've just as soon demonstrated the autoscaling behavior by manually running a stress testing tool on a box, which is what I ended up doing for testing anyway. 

I found that using an autoscaling group with a launch template dispenses the need for an aws_instance resource, which I had already written.

I also didn't realize that AWS free tier is limited by default to one instance until I tested autoscaling.

I found it strange that the resource monitoring for my instance didn't reflect the load I was generating on the box, either due to the nature of the resource usage or how the monitoring is done. 

There are a number of things I might've done differently if I'd had more time, among them:

tighter access control
a better app build process with versioning
containers for aws cli and terraform
further investigation into ECS
