# EXCERCISE

# Before we begin
BUILDEAR Y PUSHEAR BACKEND

## What we are starting off with
We are starting off with a Redis database and a backend. Everytime the backend recieves a request it gets the value of "count" from the Redis db and returns it to the user. Before returning it, it adds +1 to "count".

Once all pods in "my-app" namespace are runnign, you can test it like this:
```bash
kubectl get pods -n my-app -l app=my-app-backend -o name | xargs -I {} kubectl exec -n my-app {} -- curl -s localhost:3000
```

You should get:
```bash
{"count":1}%
```

If you run it again, you'll get:
```bash
{"count":2}%
```

And so on... If this works fine, we can continue.

<!-- You can test it on the other environments too:
```bash
kubectl get pods -n my-app-stage -l app=my-app-backend-stage -o name | xargs -I {} kubectl exec -n my-app-stage {} -- curl -s localhost:3000
kubectl get pods -n my-app-prod -l app=my-app-backend-prod -o name | xargs -I {} kubectl exec -n my-app-prod {} -- curl -s localhost:3000
``` -->

## What we are doing
We are going to create the missing piece of this puzzle with the help of backstage, the frontend.

Let's analyze the backend. With this setup we have, there's a number of things that need to exist in order for the backend service to be deployed. These are:
<!-- RELOADED -->
<!-- Let's analyze the backend. With this Gitops setup we have, there's a number of things that need to exist in order for the backend service to be deployed. These are: -->
1. The [my-app/backend directory](/my-app/backend/): In a real world scenario, the backend service would have its own repo where we would store all the application code. In this small lab we'll just save it in its own directory.
2. The [helm/my-app/backend directory](/helm/my-app/backend/): Here we save the Helm chart for our backend service. This of course would also be in its own repo on a real world scenario.
<!-- RELAODED -->
<!-- 3. The [backend service argocd application manifests](/argo-cd/applications/my-app/backend/): These are read by the App of Apps to  -->
4. The [backend build and push pipeline](/.github/workflows/build-push-my-app-backend.yml): In a real world scenario, the build and push workflow would probably exist within the .github/workflows of the backend applciation code repo. In this case, since we are using one repo for everything, we'll put it in the .github/workflows of this repo.

All of these files and directories we need to create for any new service we want to deploy. Luckily, we have Backstage Software Templates.

## How we are doing it
Let's go into our Backstage console. In the Create tab on the left, we'll find the "New NGNIX in Existing Repo" Software Template. Click "Choose" on that card and complete with this info:
- System: my-app
- Service: frontend
- Description: Frontend for the my-app system
- Owner: my-app-frontend-subteam

On the next, under Owner complete with your GitHub username and under Repository complete with "backstage-minikube-lab". Click Review and then Create.

If all goes well, you should see a few green ticks and a "Go to PR" button. Click on the button. This should send you to the Pull Request page on your repo. Merge the branch.

### Next steps to deploy the new frontend service
Ok, we now have all necessary files and directories to deploy the frontend. We just need the actual code.

Run `git pull` on your machine to pull the new files.

Now, in the [example files directory](/example-files/) you will find necessary code for the frontend to work. Copy the contents of [index.html](/example-files/my-app-frontend/index.html), [index.js](/example-files/my-app-frontend/index.js) and [styles.css](/example-files/my-app-frontend/styles.css) into their respective files inside [my-app/frontend](/my-app/frontend/).

When done, commit and push the changes. This should trigger the frontend GitHub workflow, which will build the container image for the frontend and push it to DockerHub.

When the workflow is done, go check your DockerHub account for the tag of the my-app-frontend image. 
<!-- RELOADED -->
<!-- Take the tag number and paste it in the [values.yaml of the frontend](/helm/my-app/frontend/values.yaml) -->
Take the tag number and update the image tag in the [frontend deployment manifest](/k8s-manifests/my-app-frontend/deployment.yaml). 

Run:
```bash
kubectl apply -f k8s-manifests/my-app-frontend
```
