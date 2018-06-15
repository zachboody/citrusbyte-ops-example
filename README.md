# Citrusbyte Ops Project #

## Overview ##
A ruby/Sinatra backend container project.

I don't have a CI/CD setup as part of this for a couple of reasons.
* Raw codecommit/codedeploy is super ugly. Inline lambda code and all, it's incredibly hard to follow unless you already know.
* I don't actually have my Jenkins server handy to pull an example config to import after I built it.

This is pretty heavily based on the ecs-refarch examples, with a few modifications besides the obvious (Service changes):
* Adding a registry to push images to. (infrastructure/ecs-registry), and an IAM role for it.
* Adding an image parameter to the master template to be able to propogate the image ID down.

That said, the "From scratch" deployment here does have a dependency loop of sorts.
You need to deploy ecs-registry, in order to be able to push images *to* the registry, in order to actually get the rest of this to deploy. 


Deployment process, in general:

Run ecs-registry CF template, with name and user to grant push/pull permissions. (This would normally be a jenkins user):
`aws cloudformation deploy --template-file ./ecs-registry.yaml --stack-name example-ecr --parameter-overrides ECRName=example-service ECRRole=$USER_ARN`
Get the URI for the ECR. If you have jq handy, you can do something like:
`aws ecr describe-repositories --repository-names example-service | jq '.repositories[0].repositoryUri'`
Get the login token for docker, then paste it in. (You can use --password-stdin and then paste the password in seperately if desired, on multi-user systems.)
`aws ecr get-login --no-include-email`

Then build and push the docker image:
```
docker build -t example-service ./app
docker tag test-registry:latest $REPO_URI:latest
docker push $REPO_URI:latest
```

Now you can actually do the rest of the stack.
First, upload all the templates here to S3.
(I'm using abyss-citrusbyte-opstest-zach/example-app as $bucket)
```
aws s3 mb s3://$bucket
aws s3 cp master.yaml s3://$bucket/master.yaml
aws s3 cp services s3://$bucket/services --recursive
aws s3 cp infrastructure s3://$bucket/infrastructure --recursive
```

After uploading, go through master.yaml and change the references to your new S3 bucket.
Then run how you will.
The important master parameters are
- Example-ServiceImageID
- Stack-Name

Note being, you'll need to add `--capabilities CAPABILITY_NAMED_IAM` in the CLI (Or check the "I acknowlege AWS is going to create..." in the web frontend.)

To update (Say, with an updated docker image), run the services/example-service/service.yaml CF template
Stuff I'm not happy with:

- No way that I could find to dump out the URI for the ECR from cloud formation.

- The dependency loop that keeps it from being a single-button push or single stack. You probably want your repo off to the side so you don't tear it down when you adjust the application stack... but I still don't like it.

- On a personal level, I don't really like how this is mostly "Slightly extended ecs-refarch-cloudformation", but the base is incredibly solid, to the point that I'd not feel better about doing the same thing, slightly worse, out of "Not invented here"

