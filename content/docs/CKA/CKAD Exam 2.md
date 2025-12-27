---
title: CKAD2
type: docs
prev: docs/CKA/CKAD1
next: docs/CKA/CKAD3
---

## Q. 1 Task SECTION: APPLICATION DESIGN AND BUILD

For this question, please set the context to cluster1 by running:

``` kubectl config use-context cluster1

In the ckad-multi-containers namespaces, create a ckad-neighbor-pod pod that matches the following requirements.

Pod has an emptyDir volume named my-vol.

The first container named main-container, runs nginx:1.16 image. This container mounts the my-vol volume at /usr/share/nginx/html path.

The second container is a co-located container named neighbor-container, and runs the busybox:1.28 image. This container mounts the volume my-vol at /var/log path.

Every 5 seconds, this container should write the current date along with greeting message Hi I am from neighbor container to index.html in the my-vol volume.

## Solution
Use below YAML to create the desired pod:

``` ```  apiVersion: v1
kind: Pod
metadata:
  namespace: ckad-multi-containers
  name: ckad-neighbor-pod
spec:
  containers:
    - image: nginx:1.16
      name: main-container
      resources: {}
      ports:
        - containerPort: 80
      volumeMounts:
        - name: my-vol
          mountPath: /usr/share/nginx/html
    - image: busybox:1.28
      command:
        - /bin/sh
        - -c
        - while true; do echo $(date -u) Hi I am from neighbor container >> /var/log/index.html; sleep 5;done
      name: neighbor-container
      resources: {}
      volumeMounts:
        - name: my-vol
          mountPath: /var/log
  dnsPolicy: Default
  volumes:
    - name: my-vol
      emptyDir: {}

You can verify the logs with below command:

``` kubectl exec -n ckad-multi-containers ckad-neighbor-pod --container  main-container -- cat /usr/share/nginx/html/index.html

Similar logs should be displayed as below:

Mon Mar 20 06:02:07 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:12 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:17 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:22 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:27 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:32 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:37 UTC 2023 Hi I am from neighbor container
Mon Mar 20 06:02:42 UTC 2023 Hi I am from neighbor container

## Details

## Q. 2

Task
SECTION: APPLICATION DESIGN AND BUILD
For this question, please set the context to cluster1 by running:

``` kubectl config use-context cluster1

In the ckad-multi-containers namespace, create pod named dos-containers-pod which has 2 containers matching the below requirements:

The first container named alpha runs the nginx:1.17 image and has the ROLE=SERVER ENV variable configured.

The second container named beta, runs busybox:1.28 image. This container will print message Hello multi-containers (command needs to be run in shell).

NOTE: all containers should be in a running state to pass the validation.

## Solution

## Details

Is the first pod's container running?

Is the first container named alpha?

Is the first container run nginx:1.17 image?

Does the first container ENV configured correctly?

Is the second pod's container running?

Is the second container named beta?

Does beta container run busybox:1.28 image?

Does beta container run the required command?

## Q. 3

Task

## Solution

## Details

Is the job alpine-job created?

Is the container image is alpine?

Does the job run the top command?

## Q. 4

Task
SECTION: APPLICATION DESIGN AND BUILD

For this question, please set the context to cluster2 by running:

``` kubectl config use-context cluster2

In the ckad-pod-design namespace, start a ckad-redis-wiipwlznjy pod running the redis image; the container should be named redis-custom-annotation.

Configure a custom annotation to that pod as below:

KKE: https://engineer.kodekloud.com/

## Solution
Create a YAML file with the content as below:

```  apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: ckad-redis-wiipwlznjy
  name: ckad-redis-wiipwlznjy
  namespace: ckad-pod-design
  annotations: 
    KKE: https://engineer.kodekloud.com/
spec:
  containers:
  - image: redis
    name: redis-custom-annotation
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

Then use ``` kubectl apply -f file_name.yaml to create the required object.

Alternatively, you can use this command for similar outcome:

``` kubectl run ckad-redis-wiipwlznjy -n ckad-pod-design --image=redis --annotations KKE=https://kodekloud.com

## Details

Is pod ckad-redis-wiipwlznjy running?

Is the pod's container named redis-custom-annotation?

Is the pod's annotation configured correctly?

## Q. 5

Task
SECTION: APPLICATION DEPLOYMENT

For this question, please set the context to cluster2 by running:

``` kubectl config use-context cluster2

On cluster2, we are getting alerts for the resource consumption for the ultra-apd namespace. A limit is set for the ultra-apd namespace; if the limit is crossed, we will get the alerts.

After inspecting the namespace, the team found that the deployment scaled to 8, which is wrong.

The team wants you to decrease the deployment to 4.

## Solution
Run the following command to change the context: -

``` kubectl config use-context cluster2

In this task, we will use the ``` kubectl command. Here are the steps: -

Use the ``` kubectl get command to list the pods and deployment on the ultra-apd namespace.

``` kubectl get pods,deployment -n ultra-apd

Here -n option stands for namespace, which is used to specify the namespace.

Inspect the deployed resources and count the number of pods.

Now, scaled down the deployment to 4 as follows:

``` kubectl scale deployment ultra-deploy-apd -n ultra-apd --replicas=4

The above command will scale down the number of replicas in a deployment.

## Details

Is deployment scaled down?

## Q. 6

Task
SECTION: APPLICATION DEPLOYMENT

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

Create a new deployment called ocean-apd in the default namespace using the image kodekloud/webapp-color:v1.
Use the following specs for the deployment:

1. Replica count should be 2.

2. Set the Max Unavailable to 45% and Max Surge to 55%.

3. Create the deployment and ensure all the pods are ready.

4. After successful deployment, upgrade the deployment image to kodekloud/webapp-color:v2 and inspect the deployment rollout status.

5. Check the rolling history of the deployment and on the student-node, save the current revision count number to the /opt/ocean-revision-count.txt file.

6. Finally, perform a rollback and revert the deployment image to the older version.

## Solution
Run the following command to change the context: -

``` kubectl config use-context cluster3

Use the following template to create a deployment called ocean-apd: -

---
```  apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ocean-apd
  name: ocean-apd
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ocean-apd
  strategy: 
   type: RollingUpdate
   rollingUpdate:
     maxUnavailable: 45%
     maxSurge: 55%
  template:
    metadata:
      labels:
        app: ocean-apd
    spec:
      containers:
      - image: kodekloud/webapp-color:v1
        name: webapp-color

Now, create the deployment by using the ``` kubectl create -f command in the default namespace: -

``` kubectl create -f <FILE-NAME>.yaml

After sometime, upgrade the deployment image to kodekloud/webapp-color:v2: -

``` kubectl set image deploy ocean-apd webapp-color=kodekloud/webapp-color:v2

And check out the rollout history of the deployment ocean-apd: -

``` kubectl rollout history deploy ocean-apd
deployment.apps/ocean-apd 
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

NOTE: - Revision count is 2. In your lab, it could be different.

On the student-node, store the revision count to the given file: -

echo "2" > /opt/ocean-revision-count.txt

In final task, rollback the deployment image to an old version: -

``` kubectl rollout undo deployment ocean-apd

Verify the image name by using the following command: -

``` kubectl describe deploy ocean-apd | grep -i image

It should be kodekloud/webapp-color:v1 image.

## Details

Is deployment running?

Is replica set to 2?

Is maxSurge set to 55%?

Is maxUnavailable set to 45%?

Is revision count stored in the file?

Is rolling back successful?

## Q. 7

Task
SECTION: APPLICATION DEPLOYMENT

For this question, please set the context to cluster1 by running:

``` kubectl config use-context cluster1

In the initial phase, our team lead wants to deploy Kubernetes Dashboard using the popular Helm tool. Kubernetes Dashboard is a powerful and versatile web-based management interface for Kubernetes clusters. It allows users to manage and monitor cluster resources, deploy applications, troubleshoot issues, and more.
This deployment will be facilitated through the kubernetes Helm chart on the cluster1-controlplane node to fulfill the requirements of our new client

The chart URL and other specifications are as follows: -

1. The chart URL link - https://kubernetes.github.io/dashboard/

2. The chart repository name should be kubernetes-dashboard.

3. The release name should be kubernetes-dashboard-server.

4. All the resources should be deployed on the cd-tool-apd namespace.

NOTE: - You have to perform this task from the student-node.

## Solution
Run the following command to change the context: -

``` kubectl config use-context cluster1

In this task, we will use the helm commands. Here are the steps: -

Add the repostiory to Helm with the following command: -

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/

The helm repo add command is used to add a new chart repository to Helm and this allows us to browse and install charts from the new repository using the Helm package manager.

Use the helm repo ls command which is used to list all the currently configured Helm chart repositories on Kubernetes cluster.

helm repo ls 

Before installing the chart, we have to create a namespace as given in the task description. Then we can install the kubernetes-dashboard chart on a Kubernetes cluster.

``` kubectl create ns cd-tool-apd

helm upgrade --install kubernetes-dashboard-server kubernetes-dashboard/kubernetes-dashboard -n cd-tool-apd

## Details

Is Helm repository created?

Is Helm chart installed?

Are resources deployed on ns?

## Q. 8

Task
SECTION: APPLICATION DEPLOYMENT

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

Create a deployment called space-20 using the redis image to the aerospace namespace.

## Solution
Run the following command to change the context: -

``` kubectl config use-context cluster3

Run the following command: -

``` kubectl create deployment space-20 --image=redis -n aerospace

To cross-verify the deployed resources, run the ``` kubectl get command as follows: -

``` kubectl get pods,deployments -n aerospace

## Details

Is the deployment created?

## Q. 9

Task
SECTION: SERVICES AND NETWORKING

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

Create a pod with name pod21-ckad-svcn using the nginx:alpine image in the default namespace and also expose the pod using service pod21-ckad-svcn on port 80.

Note: Use the imperative command for above scenario.

## Solution

## Details

Is the pod pod21-ckad-svcn created?

Is service pod21-ckad-svcn created?

## Q. 10

Task
SECTION: SERVICES AND NETWORKING

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

We have already deployed an application that consists of frontend, backend, and database pods in the app-ckad namespace. Inspect them.

Your task is to create:

A service frontend-ckad-svcn to expose the frontend pods outside the cluster on port 31100.

A service backend-ckad-svcn to make backend pods to be accessible within the cluster.

A policy database-ckad-netpol to limit access to database pods only to backend pods.
## Solution
A service frontend-ckad-svcn to expose the frontend pods outside the cluster on port 31100.
```  apiVersion: v1
kind: Service
metadata:
  name: frontend-ckad-svcn
  namespace: app-ckad
spec:
  selector:
    app: frontend
  type: NodePort
  ports:
  - name: http
    port: 80
    targetPort: 80
    nodePort: 31100

A service backend-ckad-svcn to make backend pods to be accessible within the cluster.
```  apiVersion: v1
kind: Service
metadata:
  name: backend-ckad-svcn
  namespace: app-ckad
spec:
  selector:
    app: backend
  ports:
  - name: http
    port: 80
    targetPort: 80

A policy database-ckad-netpol to limit access of database pods only to backend pods.
```  apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: database-ckad-netpol
  namespace: app-ckad
spec:
  podSelector:
    matchLabels:
      app: database
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend

## Details

Is service frontend-ckad-svcn created?

Is service backend-ckad-svcn created?

Is policy database-ckad-netpol created?

Are frontend pods accessible at port 31100?

Is service configured for backend accessible inside cluster?

Does policy database-ckad-netpol allow traffic from backend?

## Q. 11

Task
SECTION: SERVICES AND NETWORKING

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

For this scenario, create a deployment named hr-web-app-ckad05-svcn using the image kodekloud/webapp-color with 2 replicas.

Expose the hr-web-app-ckad05-svcn with service named hr-web-app-service-ckad05-svcn on port 30082 on the nodes of the cluster.

Note: The web application listens on port 8080.

## Solution
Switch to cluster3 :

``` kubectl config use-context cluster3

On student-node, use the command: ``` kubectl create deployment  hr-web-app-ckad05-svcn --image=kodekloud/webapp-color --replicas=2

Now we can run the command: ``` kubectl expose deployment hr-web-app-ckad05-svcn --type=NodePort --port=8080 --name=hr-web-app-service-ckad05-svcn --dry-run=client -o yaml > hr-web-app-service-ckad05-svcn.yaml to generate a service definition file.

Now, in generated service definition file add the nodePort field with the given port number under the ports section and create a service.

## Details

Is deployment name hr-web-app-ckad05-svcn?

Is the Image kodekloud/webapp-color used?

Does deployment has 2 replicas?

Is service hr-web-app-service-ckad05-svcn created?

Is service is of type "NodePort"?

Does service has 2 Endpoints?

Is service configured for port 8080?

Does service use NodePort 30082?

## Q. 12

Task
SECTION: SERVICES AND NETWORKING

For this question, please set the context to cluster1 by running:

``` kubectl config use-context cluster1

Please use the namespace nginx-deployment for the following scenario.

Create a deployment with name nginx-ckad11 using nginx image with 2 replicas. Also expose the deployment via ClusterIP service .i.e. nginx-ckad11-service on port 80. Use the label app=nginx-ckad for both resources.

Now, create a NetworkPolicy .i.e. ckad-allow so that only pods with label criteria: allow can access the deployment on port 80 and apply it.

## Solution
Use the following to create the deployment and the service.

``` kubectl apply -f - <<eof
```  apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-ckad11
  namespace: nginx-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-ckad
  template:
    metadata:
      labels:
        app: nginx-ckad
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
```  apiVersion: v1
kind: Service
metadata:
  name: nginx-ckad11-service
  namespace: nginx-deployment
spec:
  selector:
    app: nginx-ckad
  ports:
    - name: http
      port: 80
      targetPort: 80
  type: ClusterIP
eof

To create a NetworkPolicy that only allows pods with labels criteria: allow to access the deployment, you can use the following YAML definition:

``` kubectl apply -f - <<eof
```  apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: ckad-allow
  namespace: nginx-deployment
spec:
  podSelector:
    matchLabels:
      app: nginx-ckad
  ingress:
    - from:
        - podSelector:
            matchLabels:
              criteria: allow
      ports:
        - protocol: TCP
          port: 80
eof

## Details

## Q. 13

Task

## Solution
student-node ~ ➜  ``` kubectl config use-context cluster1
Switched to context "cluster1".

student-node ~ ➜  k get -n ckad05-securityctx-aecs pod ckad06-cap-aecs -o yaml | egrep -i -A3 capabilities:
      capabilities:
        add:
        - SYS_TIME
    terminationMessagePath: /dev/termination-log

student-node ~ ➜  k get -n ckad05-securityctx-aecs pod ckad06-cap-aecs -o yaml > pod-capabilities.yaml

student-node ~ ➜  vim pod-capabilities.yaml

student-node ~ ➜  cat pod-capabilities.yaml
```  apiVersion: v1
kind: Pod
metadata:
  name: ckad06-cap-aecs
  namespace: ckad05-securityctx-aecs
spec:
  containers:
  - command:
    - sleep
    - "4800"
    image: ubuntu
    name: ubuntu-sleeper
    securityContext:
      capabilities:
        add: ["SYS_TIME", "NET_ADMIN"]

student-node ~ ➜  k replace -f pod-capabilities.yaml --force 
pod "ckad06-cap-aecs" deleted
pod/ckad06-cap-aecs replaced

student-node ~ ➜  k get -n ckad05-securityctx-aecs pod ckad06-cap-aecs -o yaml | egrep -i -A3 capabilities:
      capabilities:
        add:
        - SYS_TIME
        - NET_ADMIN

## Details

Are required capabilities added ?

## Q. 14

Task
SECTION: APPLICATION ENVIRONMENT, CONFIGURATION and SECURITY

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

Define a Kubernetes custom resource definition (CRD) for a new resource kind called Foo (plural form - foos) in the samplecontroller.example.com group.

This CRD should have a version of v1alpha1 with a schema that includes two properties as given below:

deploymentName (a string type) and replicas (an integer type with minimum value of 1 and maximum value of 5).

It should also include a status subresource which enables retrieving and updating the status of Foo object, including the availableReplicas property, which is an integer type.
The Foo resource should be namespace scoped.

Note: We have provided a template /root/foo-crd-aecs.yaml for your ease. There are few issues with it so please make sure to incorporate the above requirements before deploying on cluster.

## Solution
student-node ~ ➜  ``` kubectl config use-context cluster3
Switched to context "cluster3".

student-node ~ ➜  vim foo-crd-aecs.yaml

student-node ~ ➜  cat foo-crd-aecs.yaml 
```  apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: foos.samplecontroller.example.com
spec:
  group: samplecontroller.example.com
  scope: Namespaced
  names:
    kind: Foo
    plural: foos
  versions:
  - name: v1alpha1
    served: true
    storage: true
    schema:
      # schema used for validation
      openAPIV3Schema:
        type: object
        properties:
          spec:
            # Spec for schema goes here !
            type: object
            properties:
              deploymentName:
                type: string
              replicas:
                type: integer
                minimum: 1
                maximum: 5
          status:
            type: object
            properties:
              availableReplicas:
                type: integer
    # subresources for the custom resource
    subresources:
      # enables the status subresource
      status: {}

student-node ~ ➜  ``` kubectl apply -f foo-crd-aecs.yaml
customresourcedefinition.apiextensions.k8s.io/foos.samplecontroller.example.com created

## Details

Are correct values used for: 'group', 'kind', 'plural' and 'scope' ?

Is the correct version specified?

Are correct keys defined of type "string"?

Are correct keys defined of type "integer"?

Is the correct range defined for key 'replicas'?

Is the "status" for foo object correctly configured?

Are "status" Subresources enabled?

## Q. 15

Task

## Solution
student-node ~ ➜  ``` kubectl config use-context cluster1
Switched to context "cluster1".

student-node ~ ➜  k get pods -n ckad02-mult-cm-cfg-aecs 
NAME                   READY   STATUS    RESTARTS   AGE
ckad02-test-pod-aecs   1/1     Running   0          7m57s

student-node ~ ➜  k get pods -n ckad02-mult-cm-cfg-aecs ckad02-test-pod-aecs -o yaml  > 1-pod-cm.yaml

# Using editor to modify the fields as per the requirements:
student-node ~ ➜  vim 1-pod-cm.yaml 

student-node ~ ➜  cat 1-pod-cm.yaml 
```  apiVersion: v1
kind: Pod
metadata:
  name: ckad02-test-pod-aecs
  namespace: ckad02-mult-cm-cfg-aecs
spec:
  containers:
    - name: test-container
      image: registry.k8s.io/busybox
      command: ["/bin/sh", "-c", "while true; do env | egrep \"GREETINGS|WHO\"; sleep 10; done"]
      env:
        - name: GREETINGS
          valueFrom:
            configMapKeyRef:
              name: ckad02-config1-aecs
              key: greetings.how
        - name: WHO
          valueFrom:
            configMapKeyRef:
              name: ckad02-config2-aecs
              key: man
  restartPolicy: Always

student-node ~ ➜  k replace -f 1-pod-cm.yaml --force
pod "ckad02-test-pod-aecs" deleted
pod/ckad02-test-pod-aecs replaced

student-node ~ ➜  k get -f 1-pod-cm.yaml
NAME                   READY   STATUS    RESTARTS   AGE
ckad02-test-pod-aecs   1/1     Running   0          10s

student-node ~ ➜  k logs -n ckad02-mult-cm-cfg-aecs ckad02-test-pod-aecs | head -2
GREETINGS=HI
WHO=HANDSOME

## Details

Is env var for "GREETINGS" configured ?

Is env var for "WHO" configured ?

## Q. 16

Task
SECTION: APPLICATION ENVIRONMENT, CONFIGURATION and SECURITY

For this question, please set the context to cluster2 by running:

``` kubectl config use-context cluster2

Create a Kubernetes Pod named ckad15-memory, with a container named ckad15-memory running the polinux/stress image, and configure it to use the following specifications:

Command: stress
Arguments: ["--vm", "1", "--vm-bytes", "10M", "--vm-hang", "1"]
Requested memory: 10Mi
Memory limit: 10Mi
## Solution
student-node ~ ➜  ``` kubectl config use-context cluster2
Switched to context "cluster2".

student-node ~ ➜  cat << EOF | ``` kubectl apply -f -
```  apiVersion: v1
kind: Pod
metadata:
  name: ckad15-memory
spec:
  containers:
  - name: ckad15-memory
    image: polinux/stress
    resources:
      requests:
        memory: "10Mi"
      limits:
        memory: "10Mi"
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "10M", "--vm-hang", "1"]
EOF

pod/ckad15-memory created

## Details

Is correct container name and image used?

Is correct command used ?

Is correct argument used ?

Is "request" and "limit" for memory configured ?

## Q. 17

Task
SECTION: APPLICATION ENVIRONMENT, CONFIGURATION and SECURITY

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

Create a role configmap-updater in the ckad17-auth1 namespace granting the update and get permissions on configmaps resources but restricted to only the ckad17-config-map instance of the resource.

## Solution
student-node ~ ➜  ``` kubectl config use-context cluster3
Switched to context "cluster3".

student-node ~ ➜  k get cm -n ckad17-auth1 
NAME               DATA   AGE
kube-root-ca.crt   1      3m35s
ckad17-config-map    2      3m35s

student-node ~ ➜  ``` kubectl create role configmap-updater --namespace=ckad17-auth1 --resource=configmaps --resource-name=ckad17-config-map --verb=update,get 
role.rbac.authorization.k8s.io/configmap-updater created

student-node ~ ➜  k get role -n ckad17-auth1 configmap-updater -o yaml
```  apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2023-03-22T09:01:04Z"
  name: configmap-updater
  namespace: ckad17-auth1
  resourceVersion: "2799"
  uid: c152750a-198e-438e-9993-64b3e872c3e0
rules:
- apiGroups:
  - ""
  resourceNames:
  - ckad17-config-map
  resources:
  - configmaps
  verbs:
  - update
  - get

## Details

Are correct verbs defined?

Are correct resource and resource instance defined ?

## Q. 18

Task
SECTION: APPLICATION OBSERVABILITY AND MAINTENANCE

For this question, please set the context to cluster1 by running:

``` kubectl config use-context cluster1

A pod named ckad-simplepod-aom is deployed, but it is not running state. Inspect the reason and make required changes.

## Solution
Lets debug the issue first

``` kubectl describe pod ckad-simplepod-aom

This will show image pull issue as there is an image typo and we are pulling incorrect image.

Use the below command for the fixes.

``` kubectl edit pod ckad-simplepod-aom

And make changes according to yaml ## Solution provided.

---
```  apiVersion: v1
kind: Pod
metadata:
  name: ckad-simplepod-aom
spec:
  containers:
    - command:
        - sleep
        - "3600"
      image: busybox
      name: pods-simple-container

## Details

Status: Running

Is the image issue fixed?

## Q. 19

Task
SECTION: APPLICATION OBSERVABILITY AND MAINTENANCE

Identify the kube api-resources that use api_version=storage.k8s.io/v1 using ``` kubectl command line interface and store them in /root/api-version.txt on student-node.

## Solution
Use the following command to get ## Details:

``` kubectl api-resources --sort-by=kind | grep -i storage.k8s.io/v1  > /root/api-version.txt

## Details

```  apiVersion: storage.k8s.io/v1

Resources identified

## Q. 20

Task
SECTION: APPLICATION OBSERVABILITY AND MAINTENANCE

For this question, please set the context to cluster3 by running:

``` kubectl config use-context cluster3

A manifest file located at root/ckad-aom.yaml on cluster3-controlplane. Which can be used to create a multi-containers pod. There are issues with the manifest file, preventing resource creation. Identify the errors, fix them and create resource.

You can access controlplane by ssh cluster3-controlplane if required.

## Solution
Set context to cluster3 and SSH to cluster3-controlplane.
use the ``` kubectl create command we will see following error.

``` kubectl create -f ckad-aom.yaml
error: resource mapping not found for name: "ckad-aom" namespace: "" from "ckad-aom.yaml": no matches for kind "Pod" in version "V1"
ensure CRDs are installed first

about error shows us there is something wrong with ```  apiVersion. So change it v1 and try again. and check status.

``` kubectl get pods
NAME            READY   STATUS             RESTARTS      AGE
ckad-aom   1/2     CrashLoopBackOff   3 (39s ago)   93s

Now check for reason using

``` kubectl describe pod ckad-aom

we will see that there is problem with nginx container

open yaml file and check in spec -> nginx container you can see error with mountPath --> mountPath: "/var/log" change it to mountPath: /var/log/nginx and apply changes.

## Details

Pod status

Used correct ```  apiVersion

Configured correct mount path

## Q. 21

Task
SECTION: APPLICATION OBSERVABILITY AND MAINTENANCE

For this question, please set the context to cluster2 by running:

``` kubectl config use-context cluster2

Use the manifest file /root/resourcedefinition.yaml and extend kubernetes API for mongodb service.

But there is an error with the file content. Find the error and fix the issue.

## Solution
Following error will be shown for creation of CRD

error: unable to recognize "resourcedefinition.yaml": no matches for kind "CustomResourceDefinition" in version "k8s.io/v1"

Check for ```  apiVersion

``` kubectl api-resources | grep -i crd
customresourcedefinitions         crd,crds     apiextensions.k8s.io/v1

Replace the correct ```  apiVersion

```  apiVersion: apiextensions.k8s.io/v1

and extend api with ``` kubectl create -f resourcedefinition.yaml

## Details

CRD created
