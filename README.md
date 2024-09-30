# sample-api-py-app
This app supports deployments to both development and production environments using a Kubernetes cluster. Follow these steps to successfully deploy the app.

## pre-requisites
 - Docker installed and running locally for building images.
 - Kubectl installed for interacting with your Kubernetes cluster.
 - Ensure that your .env file is correctly configured with the following:
 - DOCKER_USERNAME: mathstronauts dockerhub username.
 - DOCKER_PASSWORD: Your Docker Hub password.
 - KUBECONFIG: Place the kubeconfig files for dev and prod environments in the kubeconfigs folder
 - Install yq(a yaml file parser)
     - if you are on a windows Os, you can use `winget install --id MikeFarah.yq`,
     - install the approriate version for your Os from https://github.com/mikefarah/yq

 
## Running the deployment script.
The provided deploy.sh script automates the deployment process. 
It accepts the following arguments:
```bash deployScript.sh <version> <env> <build_image(true | false)>```
* example deploying to development without building a new Docker image:
 ```bash deployScript.sh 1.0.1 dev false``` 
* example deploying to production and building a new Docker image:
 ```bash deployScript.sh 1.0.1 prod true``` 


