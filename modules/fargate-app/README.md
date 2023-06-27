# Fargate Task Troubleshooting

The base repository includes the file `/iam_policies/Task-DockerExec-Policy.json` which can be used to facilitate `docker exec` access to running Fargate containers for troubleshooting.

## Prerequisites

1. Add the following parameters within the `stack_defs` block for an application stack:

```
task_role = true
task_role_policy = "/iam_policies/Task-DockerExec-Policy.json"
```

2. Install the AWS CLI locally
3. Install the Session Manager Plugin with the following (for Linux):

`sudo yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm`

For other operating sytems, instructions are here: [Install Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html#install-plugin-linux)

## Connect to Running Container

- Retrieve name of cluster with target container

_Command:_
```
aws ecs list-clusters
```

_Output:_
```
{
    "clusterArns": [
        "arn:aws:ecs:ap-southeast-2:339285943866:cluster/nrl-cicd-demo-jdev-ecs"
    ]
}
```

- Retrieve Task ID (Docker Container ID) for desired container:

_Command:_
```
aws ecs list-tasks --cluster nrl-cicd-demo-jdev-ecs
```

_Output:_
```
{
    "taskArns": [
        "arn:aws:ecs:ap-southeast-2:339285943866:task/nrl-cicd-demo-jdev-ecs/793d4e18b036495ab2a6ea23b6c2f7b4"
    ]
}
```

- Describe task to verify the name and image.  Also ensure `"enableExecuteCommand": true` is in the output:

_Command:_
```
aws ecs describe-tasks \
--cluster nrl-cicd-demo-jdev-ecs \
--region ap-southeast-2 \
--tasks 793d4e18b036495ab2a6ea23b6c2f7b4
```

_Output:_
```
{
    "tasks": [
...
            "containers": [
                {
                    "containerArn": "arn:aws:ecs:ap-southeast-2:339285943866:container/nrl-cicd-demo-jdev-ecs/382b64fd4852484994065a9774e34a54/1a82bfab-1f40-4e6a-8f96-f0fa6eeafc28",
                    "taskArn": "arn:aws:ecs:ap-southeast-2:339285943866:task/nrl-cicd-demo-jdev-ecs/382b64fd4852484994065a9774e34a54",
                    "name": "jdev",
                    "image": "jenkins/jenkins:2.410-jdk11",
...
            "createdAt": "2023-06-27T10:58:01.963000+00:00",
            "desiredStatus": "STOPPED",
            "enableExecuteCommand": true,
            "executionStoppedAt": "2023-06-27T11:47:11.930000+00:00",
            "group": "service:nrl-cicd-demo-jdev-svc",
...
```

- Execute command against desired container:

_Command:_
```
aws ecs execute-command \
--region ap-southeast-2 \
--cluster nrl-cicd-demo-jdev-ecs \
--task 793d4e18b036495ab2a6ea23b6c2f7b4 \
--container jdev \
--command "/bin/bash" \
--interactive
```
