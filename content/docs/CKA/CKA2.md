---
title: CKA2
type: docs
prev: docs/CKA/CKA1
next: docs/CKA/CKA3
---

## Task SECTION: WORKLOADS & SCHEDULING

One of our Junior DevOps engineers has deployed a pod nginx-wl06 on the cluster3-controlplane node. However, while specifying the resource limits, instead of using Mebibyte as the unit, Gebibyte was used.

As a result, the node doesn't have sufficient resources to deploy this pod, and it is stuck in a pending state

Fix the units and re-deploy the pod with about 100Mi (Delete and recreate the pod if needed).

Solution

SSH into the cluster3-controlplane Host
To begin, SSH into the cluster3-controlplane host by executing the following command:

ssh cluster3-controlplane

Check for Pending Pods Across All Namespaces
Run the following command to check for any pending pods across all namespaces:

kubectl get pods -A

Inspect the Pod's Events
Next, inspect the events related to the pending pods using the following commands:

kubectl get pods -A | grep -i pending

kubectl describe pod nginx-wl06

Retrieve the Current Pod Definition
Retrieve the current definition of the pod by executing:

kubectl get pod nginx-wl06 -o yaml > nginx-fixed.yaml

This command will save the pod's YAML definition for future modifications.

Edit the YAML File
Open the YAML file for editing with the following command:

vi nginx-fixed.yaml

Modify the value of memory from 290Gi to 100Mi under the resources.requests section.

Delete the Stuck Pod
Delete the stuck pod by executing:

kubectl delete pod nginx-wl06

Recreate the Pod
Recreate the pod using the corrected YAML file with this command:

kubectl apply -f nginx-fixed.yaml

Validate Pod Status
Finally, validate that the pod is running by executing the following command:

kubectl get pods

The expected output should be similar to:

NAME         READY   STATUS    RESTARTS   AGE
nginx-wl06   1/1     Running   0          2m39s

Details

Is the Pod running?


Is the memory fixed?

### SECTION: CLUSTER ARCHITECTURE, INSTALLATION & CONFIGURATION

On the cluster1, the team has installed multiple helm charts on a different namespace. By mistake, those deployed resources include one of the vulnerable images called kodekloud/click-counter:latest. Find out the release name and uninstall it.


Solution
SSH into the cluster1-controlplane Host
ssh cluster1-controlplane

In this task, you will utilize the helm commands along with the jq tool. Please follow the steps outlined below:

Execute the helm ls command with the -A option to list all releases deployed across all namespaces.

helm ls -A

Utilize the jq tool to extract the image name from the deployments.

kubectl get deploy -n <NAMESPACE> <DEPLOYMENT-NAME> -o json | jq -r '.spec.template.spec.containers[].image'

Ensure you replace <NAMESPACE> with the relevant namespace and <DEPLOYMENT-NAME> with the name of the deployment obtained from the previous command.

After identifying the kodekloud/click-counter:latest image in the security-alpha-apd deployment:

cluster1-controlplane ~ ➜  kubectl get deploy -n security-alpha-01 security-alpha-apd -o json | jq -r '.spec.template.spec.containers[].image'
kodekloud/click-counter:latest

Use the helm uninstall command to remove the deployed chart that is utilizing this vulnerable image.

helm uninstall <RELEASE-NAME> -n <NAMESPACE> 

cluster1-controlplane ~ ➜  helm uninstall security-alpha-apd -n security-alpha-01
release "security-alpha-apd" uninstalled

Details

Is helm release uninstalled?

### Task SECTION: SERVICES AND NETWORKING

Part I:

Create a ClusterIP service with name of service-3421-svcn in the spectra-1267 namespace, which should expose the pods, namely, pod-23 and pod-21, with port set to 8080 and targetport to 80.

Part II:

Store the pod names and their IP addresses from the spectra-1267 namespace at /root/pod_ips_cka05_svcn where the output is sorted by their IPs.

Please ensure the format as shown below:

POD_NAME        IP_ADDR
pod-1           ip-1
pod-3           ip-2
pod-2           ip-3
...

Solution
SSH into the cluster3-controlplane host
ssh cluster3-controlplane

The easiest way to route traffic to a specific pod is by the use of labels and selectors. List the pods along with their labels:

cluster3-controlplane ~ ➜  kubectl get pods --show-labels -n spectra-1267
NAME     READY   STATUS    RESTARTS   AGE     LABELS
pod-12   1/1     Running   0          5m21s   env=dev,mode=standard,type=external
pod-34   1/1     Running   0          5m20s   env=dev,mode=standard,type=internal
pod-43   1/1     Running   0          5m20s   env=prod,mode=exam,type=internal
pod-23   1/1     Running   0          5m21s   env=dev,mode=exam,type=external
pod-32   1/1     Running   0          5m20s   env=prod,mode=standard,type=internal
pod-21   1/1     Running   0          5m20s   env=prod,mode=exam,type=external

Looks like there are a lot of pods created to confuse us. But we are only concerned with the labels of pod-23 and pod-21.

As we can see both the required pods have labels mode=exam,type=external in common. Let's confirm that using kubectl too:

cluster3-controlplane ~ ➜  kubectl get pod -l mode=exam,type=external -n spectra-1267                                    
NAME     READY   STATUS    RESTARTS   AGE
pod-23   1/1     Running   0          9m18s
pod-21   1/1     Running   0          9m17s

Now as we have figured out the labels, we can proceed further with the creation of the service:

kubectl create service clusterip service-3421-svcn -n spectra-1267 --tcp=8080:80 --dry-run=client -o yaml > service-3421-svcn.yaml

Now modify the service definition with selectors as required before applying to k8s cluster:

cluster3-controlplane ~ ➜  cat service-3421-svcn.yaml 
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: null
  labels:
    app: service-3421-svcn
  name: service-3421-svcn
  namespace: spectra-1267
spec:
  ports:
  - name: 8080-80
    port: 8080
    protocol: TCP
    targetPort: 80
  selector:
    app: service-3421-svcn  # delete 
    mode: exam    # add
    type: external  # add
  type: ClusterIP
status:
  loadBalancer: {}

Finally let's apply the service definition:

kubectl apply -f service-3421-svcn.yaml

You can now validate there are two endpoints to the service

cluster3-controlplane ~ ➜  k get ep service-3421-svcn -n spectra-1267
NAME           ENDPOINTS                     AGE
service-3421   10.42.0.15:80,10.42.0.17:80   52s

To list all the pod name along with their IP's, we could use imperative command as shown below:

kubectl get pods -n spectra-1267 -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP

POD_NAME   IP_ADDR
pod-12     10.42.0.18
pod-23     10.42.0.19
pod-34     10.42.0.20
pod-21     10.42.0.21
...

# store the output to /root/pod_ips

kubectl get pods -n spectra-1267 -o=custom-columns='POD_NAME:metadata.name,IP_ADDR:status.podIP' --sort-by=.status.podIP > /root/pod_ips_cka05_svcn

Details

Does "service-3421-svcn" exist?


Is service-3421-svcn of "type: ClusterIP"?
Is port: 8080?
Is targetPort: 80?
Does service only expose pod "pod-23" and "pod-21"?
Is the correct and sorted output stored in "/root/pod_ips_cka05_svcn"?

### Task SECTION: CLUSTER ARCHITECTURE, INSTALLATION & CONFIGURATION

List all CRD names associated with VerticalPodAutoscaler and save the results in the file located at /root/vpa-crds.txt on cluster2-controlplane.

NOTE: List the CustomResourceDefinition (CRD) names associated with the VerticalPodAutoscaler, ensuring that each CRD is presented on a new line.

Solution
SSH into the cluster2-controlplane host
ssh cluster2-controlplane

1. Check CRDs Present in the Cluster
1. 
Run kubectl get crd to check the cluster status:

cluster2-controlplane ~ ➜  kubectl get crd

NAME                                                  CREATED AT
adminnetworkpolicies.policy.networking.k8s.io         2025-03-18T14:04:04Z
bgpconfigurations.crd.projectcalico.org               2025-03-18T14:04:04Z
bgpfilters.crd.projectcalico.org                      2025-03-18T14:04:04Z
bgppeers.crd.projectcalico.org                        2025-03-18T14:04:04Z
blockaffinities.crd.projectcalico.org                 2025-03-18T14:04:04Z
caliconodestatuses.crd.projectcalico.org              2025-03-18T14:04:04Z
clientsettingspolicies.gateway.nginx.org              2025-03-19T04:03:21Z
clusterinformations.crd.projectcalico.org             2025-03-18T14:04:04Z
felixconfigurations.crd.projectcalico.org             2025-03-18T14:04:04Z
gatewayclasses.gateway.networking.k8s.io              2025-03-19T04:03:19Z
gateways.gateway.networking.k8s.io                    2025-03-19T04:03:19Z
globalnetworkpolicies.crd.projectcalico.org           2025-03-18T14:04:04Z
globalnetworksets.crd.projectcalico.org               2025-03-18T14:04:04Z
grpcroutes.gateway.networking.k8s.io                  2025-03-19T04:03:19Z
hostendpoints.crd.projectcalico.org                   2025-03-18T14:04:04Z
httproutes.gateway.networking.k8s.io                  2025-03-19T04:03:20Z
ipamblocks.crd.projectcalico.org                      2025-03-18T14:04:04Z
ipamconfigs.crd.projectcalico.org                     2025-03-18T14:04:04Z
ipamhandles.crd.projectcalico.org                     2025-03-18T14:04:04Z
ippools.crd.projectcalico.org                         2025-03-18T14:04:04Z
ipreservations.crd.projectcalico.org                  2025-03-18T14:04:04Z
kubecontrollersconfigurations.crd.projectcalico.org   2025-03-18T14:04:04Z
networkpolicies.crd.projectcalico.org                 2025-03-18T14:04:04Z
networksets.crd.projectcalico.org                     2025-03-18T14:04:04Z
nginxgateways.gateway.nginx.org                       2025-03-19T04:03:21Z
nginxproxies.gateway.nginx.org                        2025-03-19T04:03:21Z
observabilitypolicies.gateway.nginx.org               2025-03-19T04:03:21Z
referencegrants.gateway.networking.k8s.io             2025-03-19T04:03:20Z
snippetsfilters.gateway.nginx.org                     2025-03-19T04:03:21Z
tiers.crd.projectcalico.org                           2025-03-18T14:04:04Z
upstreamsettingspolicies.gateway.nginx.org            2025-03-19T04:03:21Z
verticalpodautoscalercheckpoints.autoscaling.k8s.io   2025-03-19T04:03:25Z
verticalpodautoscalers.autoscaling.k8s.io             2025-03-19T04:03:25Z

There are two CRDs related to VPA (Vertical Pod Autoscaler):

verticalpodautoscalercheckpoints.autoscaling.k8s.io
verticalpodautoscalers.autoscaling.k8s.io

2. Store the CRD in /root/vpa-crds.txt
1. 
Run the following commands to store the CRDs:

echo "verticalpodautoscalercheckpoints.autoscaling.k8s.io" > /root/vpa-crds.txt
echo "verticalpodautoscalers.autoscaling.k8s.io" >> /root/vpa-crds.txt

Details

Are the CRD names captured?

###  Task SECTION: WORKLOADS & SCHEDULING

Develop an HPA named web-ui-hpa for a deployment named web-ui-deployment in ck1967 namespace that adjusts based on CPU usage. The HPA should maintain an average CPU utilization of 65%, with a minimum of 2 replicas and a maximum of 12. Configure the scale-up behavior to increase the number of pods by 20% every 45 seconds and the scale-down behavior to decrease by 10% every 60 seconds.

Solution
SSH into the cluster1-controlplane host
ssh cluster1-controlplane

Next, create a Horizontal Pod Autoscaler (HPA) named web-ui-hpa to manage the scaling of the web-ui-deployment. This HPA should be configured to respond to CPU utilization, increasing the number of pods by 20% when CPU utilization exceeds 65%. Additionally, set the scale-up behavior to apply every 45 seconds, and configure the scale-down behavior to reduce the number of pods by 10% every 60 seconds. Use the following configuration:

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-ui-hpa
  namespace: ck1967
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-ui-deployment
  minReplicas: 2
  maxReplicas: 12
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 65
  behavior:
    scaleUp:
      policies:
        - type: Percent
          value: 20
          periodSeconds: 45
    scaleDown:
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60

Details

Is the minimum number of replicas set to 2?
Is the maximum number of replicas set to 12?
Is the HPA configured to target the correct deployment?
Is the CPU utilization configured to 65%?
Is the scale-up behavior configured?
Is the scale-down behavior configured?

### Task SECTION: TROUBLESHOOTING

The green-deployment-cka15-trb deployment is having some issues since the corresponding POD is crashing and restarting multiple times continuously.

Investigate the issue and fix it. Make sure the POD is in a running state and is stable (i.e, NO RESTARTS!).

Solution
SSH into the cluster1-controlplane host
ssh cluster1-controlplane

List the pods to check its status
kubectl get pod

its must have crashed already so lets look into the logs.

kubectl logs -f green-deployment-cka15-trb-xxxx

You will see some logs like these

2022-09-18 17:13:25 98 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
2022-09-18 17:13:25 98 [Note] InnoDB: Memory barrier is not used
2022-09-18 17:13:25 98 [Note] InnoDB: Compressed tables use zlib 1.2.11
2022-09-18 17:13:25 98 [Note] InnoDB: Using Linux native AIO
2022-09-18 17:13:25 98 [Note] InnoDB: Using CPU crc32 instructions
2022-09-18 17:13:25 98 [Note] InnoDB: Initializing buffer pool, size = 128.0M
Killed

This might be due to the resources issue, especially the memory, so let's try to recreate the POD to see if it helps.

kubectl delete pod green-deployment-cka15-trb-xxxx

Now watch closely the POD status

kubectl get pod

Pretty soon you will see the POD status has been changed to OOMKilled.

To confirm if the pod’s memory limits are causing the crash, follow these diagnostic steps:
Check Pod Events and Status:

kubectl describe pod green-deployment-cka15-trb-xxxx

Look under the Events section and in the container’s Last State for entries like:

Reason: OOMKilled

This confirms the pod was terminated because it exceeded its memory limit.

So let's look into the resources that are assigned to this deployment.

kubectl get deploy
kubectl edit deploy green-deployment-cka15-trb

Under resources: -> limits: change memory from 256Mi to 512Mi and save the changes.
Now watch closely the POD status again

kubectl get pod

It should be stable now.

Note: If OOMKilled still happens, increase the memory limit in increments of 256Mi(256Mi -> 512Mi -> 768Mi -> 1Gi) until stable.

Details

Is POD stable now?

### SECTION: WORKLOADS & SCHEDULING

Create a VPA named cache-vpa for a stateful application named cache-statefulset in the caching namespace. The VPA should set optimal CPU and memory requests for newly created pods but must not evict existing pods. Configure the VPA to operate in Initial mode to achieve this behavior.

Solution
SSH into the cluster2-controlplane host
ssh cluster2-controlplane

Next, to create a Vertical Pod Autoscaler (VPA) for scaling the cache-statefulset in Initial mode, utilize the following configuration:
```
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: cache-vpa
  namespace: caching
spec:
  targetRef:
    apiVersion: apps/v1
    kind: StatefulSet
    name: cache-statefulset
  updatePolicy:
    updateMode: "Initial"
```
Details

Is the cache-vpa configured to scale the cache-statefulset?
Is the cache-vpa set to Initial mode?
Is the cache-vpa recommending the resource changes?

### SECTION: STORAGE

A pod definition file is created at /root/peach-pod-cka05-str.yaml on the cluster1-controlplane. Update this manifest file to create a persistent volume claim called peach-pvc-cka05-str to claim a 100Mi of storage from peach-pv-cka05-str PV (this is already created). Use the access mode ReadWriteOnce.


Further, add peach-pvc-cka05-str PVC to peach-pod-cka05-str POD and mount the volume at /var/www/html location. Ensure that the pod is running and the PV is bound.


Solution
SSH into the cluster1-controlplane host
ssh cluster1-controlplane

Update /root/peach-pod-cka05-str.yaml template file to create a PVC to utilise the same in POD template.
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: peach-pvc-cka05-str
spec:
  volumeName: peach-pv-cka05-str
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: peach-pod-cka05-str
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
      - mountPath: "/var/www/html"
        name: nginx-volume
  volumes:
    - name: nginx-volume
      persistentVolumeClaim:
        claimName: peach-pvc-cka05-str
```
Apply the template:
kubectl apply -f /root/peach-pod-cka05-str.yaml

Details

Is PVC created?
Is the peach-pvc-cka05-str PVC consumed by peach-pod-cka05-str pod?

### Task SECTION: SERVICES AND NETWORKING

Configure a web-portal-httproute within the cka3658 namespace to facilitate traffic distribution. Route 80% of the traffic to web-portal-service-v1 and 20% to the new version, web-portal-service-v2.

Note: Gateway has already been created in the nginx-gateway namespace.
To test the gateway, execute the following command:

curl http://cluster2-controlplane:30080

Solution
SSH into the cluster2-controlplane host
ssh cluster2-controlplane

Next, check all the deployments and services in the cka3658 namespace with the command:

kubectl get deploy,svc -n cka3658

Review the gateway that has been created in the nginx-gateway namespace using the command:

kubectl get gateway -n nginx-gateway 

You should see output similar to:

NAME            CLASS   ADDRESS   PROGRAMMED   AGE
nginx-gateway   nginx             True         36m

Now, create an HTTPRoute in the cka3658 namespace with the name web-portal-httproute to distribute traffic based on specified weights. Use the following YAML configuration:
```
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web-portal-httproute
  namespace: cka3658
spec:
  parentRefs:
    - name: nginx-gateway
      namespace: nginx-gateway
  rules:
    - matches:
        - path:
            type: PathPrefix
            value: /
      backendRefs:
        - name: web-portal-service-v1
          port: 80
          weight: 80
        - name: web-portal-service-v2
          port: 80
          weight: 20
```
Details
Is the HttpRoute referring to the NGINX gateway?
Is the web-portal-httproute routing 80% traffic to web-portal-service-v1?
Is the web-portal-httproute routing 20% traffic to web-portal-service-v2?
Is the web-portal-httproute distributing traffic?

###  Task SECTION: TROUBLESHOOTING

The demo-pod-cka29-trb pod is stuck in a Pending state. Look into the issue to fix it. Make sure the pod is in the Running state and stable.

Solution

SSH into the cluster1-controlplane host
ssh cluster1-controlplane

Look into the POD events
kubectl get event --field-selector involvedObject.name=demo-pod-cka29-trb

You will see some Warnings like:

Warning   FailedScheduling   pod/demo-pod-cka29-trb   0/3 nodes are available: 3 pod has unbound immediate PersistentVolumeClaims. preemption: 0/3 nodes are available: 3 Preemption is not helpful for scheduling.

This seems to be something related to PersistentVolumeClaims, Let's check that:

kubectl get pvc

You will notice that demo-pvc-cka29-trb is stuck in Pending state. Let's dig into it

kubectl get event --field-selector involvedObject.name=demo-pvc-cka29-trb

You will notice this error:

Warning   VolumeMismatch   persistentvolumeclaim/demo-pvc-cka29-trb   Cannot bind to requested volume "demo-pv-cka29-trb": incompatible accessMode

Which means the PVC is using incompatible accessMode, let's check the it out

kubectl get pvc demo-pvc-cka29-trb -o yaml
kubectl get pv demo-pv-cka29-trb -o yaml

Let's re-create the PVC with correct access mode i.e ReadWriteMany

kubectl get pvc demo-pvc-cka29-trb -o yaml > /tmp/pvc.yaml
vi /tmp/pvc.yaml

Under spec: change accessModes: from ReadWriteOnce to ReadWriteMany
Delete the old PVC and create new

kubectl delete pvc demo-pvc-cka29-trb
kubectl apply -f /tmp/pvc.yaml 

Check the POD now

kubectl get pod demo-pod-cka29-trb

It should be good now.

Details

Are the issues fixed?
Is the demo-pod-cka29-trb pod in the Running state?


### Task SECTION: STORAGE


We want to deploy a Python-based application on the cluster using a template located at /root/olive-app-cka10-str.yaml on cluster1-controlplane. However, before you proceed, we need to make some modifications to the YAML file as per the following details:

The YAML should also contain a persistent volume claim with name olive-pvc-cka10-str to claim a 100Mi of storage from olive-pv-cka10-str PV.

Update the deployment to add a co-located container named busybox, which can use busybox image (you might need to add a sleep command for this container to keep it running.)

Share the python-data volume with this container and mount the same at path /usr/src. Make sure this container only has read permissions on this volume.

Finally, create a pod using this YAML and make sure the POD is in Running state.

Note: Additionally, you can expose a NodePort service for the application. The service should be named olive-svc-cka10-str and expose port 5000 with a nodePort value of 32006.
However, inclusion/exclusion of this service won't affect the validation for this task.

Solution
SSH into the cluster1-controlplane host
ssh cluster1-controlplane

Update olive-app-cka10-str.yaml template so that it looks like as below:

---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: olive-pvc-cka10-str
spec:
  accessModes:
  - ReadWriteMany
  storageClassName: olive-stc-cka10-str
  volumeName: olive-pv-cka10-str
  resources:
    requests:
      storage: 100Mi

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: olive-app-cka10-str
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: olive-app-cka10-str
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                  - cluster1-node01
      containers:
      - name: python
        image: poroko/flask-demo-app
        ports:
        - containerPort: 5000
        volumeMounts:
        - name: python-data
          mountPath: /usr/share/
      - name: busybox
        image: busybox
        command:
          - "bin/sh"
          - "-c"
          - "sleep 10000"
        volumeMounts:
          - name: python-data
            mountPath: "/usr/src"
            readOnly: true
      volumes:
      - name: python-data
        persistentVolumeClaim:
          claimName: olive-pvc-cka10-str
  selector:
    matchLabels:
      app: olive-app-cka10-str

---
apiVersion: v1
kind: Service
metadata:
  name: olive-svc-cka10-str
spec:
  type: NodePort
  ports:
    - port: 5000
      nodePort: 32006
  selector:
    app: olive-app-cka10-str

Apply the template:

kubectl apply -f olive-app-cka10-str.yaml

Details

Is the olive-pvc-cka10-str PVC created?
Is the main container created as per the requirements?
Is the co-located container created as per the requirements?
Is the pod in the running state?

###  Task SECTION: WORKLOADS & SCHEDULING



Temporarily stop the kube-scheduler and create a pod named onyx-pod using the redis image. The pod should be scheduled on cluster2-controlplane.

Once the onyx-pod is running, start the kube-scheduler. Then, create a second pod named ember-pod using the redis image, and verify that it is running on cluster2-node01.

Note: You must not use tolerations or remove the taints on cluster2-controlplane.

Solution
SSH into the Control Plane
Run the following command to access cluster2-controlplane:

ssh cluster2-controlplane

1. Temporarily Stop the kube-scheduler
Move the kube-scheduler.yaml file to /tmp to disable the scheduler:

mv /etc/kubernetes/manifests/kube-scheduler.yaml /tmp/

Verify that the kube-scheduler is no longer running:

kubectl get pods -n kube-system | grep kube-scheduler

Ensure that the kube-scheduler-cluster2-controlplane pod does not exist before proceeding.

2. Deploy onyx-pod on cluster2-controlplane
Use the following manifest to deploy the pod on cluster2-controlplane:

apiVersion: v1
kind: Pod
metadata:
  labels:
    run: onyx-pod
  name: onyx-pod
spec:
  nodeName: cluster2-controlplane
  containers:
  - image: redis
    name: onyx-pod

Apply the manifest:

kubectl apply -f onyx-pod.yaml

Verify if the pod is running on cluster2-controlplane:

kubectl get pods -o wide | grep onyx-pod

3. Restart the kube-scheduler
Move back the kube-scheduler.yaml file to /etc/kubernetes/manifests/:

mv /tmp/kube-scheduler.yaml /etc/kubernetes/manifests/

Wait for the kube-scheduler-cluster2-controlplane pod to come up:

kubectl get pods -n kube-system | grep kube-scheduler

4. Deploy ember-pod on cluster2-node01
Use the following command to deploy ember-pod without specifying a node explicitly:

kubectl run ember-pod --image=redis --restart=Never

Verify that it is running on cluster2-node01:

kubectl get pods -o wide | grep ember-pod

Details

Is the onyx-pod running on cluster2-controlplane node?
Is the ember-pod running on cluster2-node01 node?

### Task SECTION: TROUBLESHOOTING


On cluster4, we are seeing an intermittent issue where the following error appears while running kubectl commands.


The connection to the server cluster4-controlplane:6443 was refused - did you specify the right host or port?

Whenever you get this error, you can wait for 10-15 seconds for the kubectl command to work again, but the issue recurs after few seconds.


We also noticed that the kube-controller-manager-cluster4-controlplane pod is restarting continuously. Look into the issue and troubleshoot it.


Note: After updating, the system pods might take a little time to reach the running state, so wait for a few minutes after making changes.

Solution
SSH into the cluster4-controlplane host
ssh cluster4-controlplane

Let's check the POD status
kubectl get pod -n kube-system

You will see that kube-controller-manager-cluster4-controlplane pod is crashing or restarting. So let's try to watch the logs.

kubectl logs -f kube-controller-manager-cluster4-controlplane  -n kube-system

You will see some logs as below:

 leaderelection.go:330] error retrieving resource lock kube-system/kube-controller-manager: Get "https://10.10.129.21:6443/apis/coordination.k8s.io/v1/namespaces/kube-system/leases/kube-controller-manager?timeout=5s": dial tcp 10.10.129.21:6443: connect: connection refused

You will notice that somehow the connection to the kube api is breaking, let's check if kube api pod is healthy.

kubectl get pod -n kube-system

Now you might notice that kube-apiserver-cluster4-controlplane pod is also restarting, so we should dig into its logs or relevant events.

kubectl logs -f kube-apiserver-cluster4-controlplane -n kube-system
kubectl get event --field-selector involvedObject.name=kube-apiserver-cluster4-controlplane -n kube-system

In events you will see this error

Warning   Unhealthy      pod/kube-apiserver-cluster4-controlplane   Liveness probe failed: Get "https://10.10.132.25:6444/livez": dial tcp 10.10.132.25:6444: connect: connection refused

From this we can see that the Liveness probe is failing for the kube-apiserver-cluster4-controlplane pod, and we can see its trying to connect to port 6444 port but the default api port is 6443. So let's look into the kube api server manifest.

vi /etc/kubernetes/manifests/kube-apiserver.yaml

Under livenessProbe: you will see the port: value is 6444, change it to 6443 and save. Now wait for few seconds let the kube api pod come up.

kubectl get pod -n kube-system

Watch the PODs status for some time and make sure these are not restarting now.

Details

Is the Issue fixed?

### Task SECTION: TROUBLESHOOTING


We have an external webserver running on student-node which is exposed at port 9999. We have created a service called external-webserver-cka03-svcn that can connect to our local webserver from within the kubernetes cluster3, but at the moment, it is not working as expected.

Fix the issue so that other pods within cluster3 can use external-webserver-cka03-svcn service to access the webserver.

Solution

SSH into the cluster3-controlplane host
ssh cluster3-controlplane

Let's check if the webserver is working or not:

cluster3-controlplane  ~ ➜  curl student-node:9999
...
<h1>Welcome to nginx!</h1>
...

Now we will check if service is correctly defined:

cluster3-controlplane  ~ ➜  kubectl describe svc -n kube-public external-webserver-cka03-svcn 
Name:              external-webserver-cka03-svcn
Namespace:         kube-public
.
.
Endpoints:         <none> # there are no endpoints for the service
...

As we can see there is no endpoints specified for the service, hence we won't be able to get any output. Since we can not destroy any k8s object, let's create the endpoint manually for this service as shown below:

First, obtain the IP address of the student node, easiest way is to ping it:

root@student-node ~ ✦  ping student-node
PING student-node (192.168.222.128) 56(84) bytes of data.
64 bytes from student-node (192.168.222.128): icmp_seq=1 ttl=64 time=0.023 ms
64 bytes from student-node (192.168.222.128): icmp_seq=2 ttl=64 time=0.030 ms

In this example : student-node IP is 192.168.222.128

Next, use the IP address to create the EndpointSlice:

cluster3-controlplane  ~ ➜ kubectl  apply -f - <<EOF
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: external-webserver-cka03-svcn
  namespace: kube-public
  labels:
    kubernetes.io/service-name: external-webserver-cka03-svcn
addressType: IPv4
ports:
  - protocol: TCP
    port: 9999
endpoints:
  - addresses:
      - 192.168.222.128   # IP of student node
EOF

Finally check if the curl test works now:

cluster3-controlplane  ~ ➜  kubectl run -n kube-public --rm  -i test-curl-pod --image=curlimages/curl --restart=Never -- curl -m 2 external-webserver-cka03-svcn
...
<title>Welcome to nginx!</title>
...

Details

Can the pod within cluster3 access the external webserver?
Does the external-webserver-cka03-svcn service have the correct IP addresses listed as endpoints?
Is the correct port specified?

###  Task SECTION: WORKLOADS & SCHEDULING

Create a ConfigMap called db-user-pass-cka17-arch in the default namespace using the contents of the file /opt/db-user-pass on the cluster1-controlplane

Solution

SSH into the cluster1-controlplane host
ssh cluster1-controlplane

Create the required configmap:

cluster1-controlplane ~ ➜  kubectl create cm db-user-pass-cka17-arch --from-file=/opt/db-user-pass

Details

Is db-user-pass-cka17-arch configmap created?


### TaskSECTION: TROUBLESHOOTING

An nginx-based pod called cyan-pod-cka28-trb is running under the cyan-ns-cka28-trb namespace and is exposed within the cluster using the cyan-svc-cka28-trb service.

This is a restricted pod, so a network policy called cyan-np-cka28-trb has been created in the same namespace to apply some restrictions on this pod.


Two other pods called cyan-white-cka28-trb and cyan-black-cka28-trb are also running in the default namespace.


The nginx-based app running on the cyan-pod-cka28-trb pod is exposed internally on the default nginx port (80).


Expectation: This app should only be accessible from the cyan-white-cka28-trb pod.


Problem: This app is not accessible from anywhere.


Troubleshoot this issue and fix the connectivity as per the requirement listed above.


Note: You can exec into cyan-white-cka28-trb and cyan-black-cka28-trb pods and test connectivity using the curl utility.


You may update the network policy, but make sure it is not deleted from the cyan-ns-cka28-trb namespace.

Solution
SSH into the cluster1-controlplane host
ssh cluster1-controlplane



Let's look into the network policy

kubectl edit networkpolicy cyan-np-cka28-trb -n cyan-ns-cka28-trb

Under spec: -> egress: you will notice there is not cidr: block has been added, since there is no restrcitions on egress traffic so we can update it as below. Further you will notice that the port used in the policy is 8080 but the app is running on default port which is 80 so let's update this as well (under egress and ingress):

Change port: 8080 to port: 80
- ports:
  - port: 80
    protocol: TCP
  to:
  - ipBlock:
      cidr: 0.0.0.0/0

Now, lastly notice that there is no POD selector has been used in ingress section but this app is supposed to be accessible from cyan-white-cka28-trb pod under default namespace. So let's edit it to look like as below:

ingress:
- from:
  - namespaceSelector:
      matchLabels:
        kubernetes.io/metadata.name: default
    podSelector:
      matchLabels:
        app: cyan-white-cka28-trb

Now, let's try to access the app from cyan-white-pod-cka28-trb

kubectl exec cyan-white-cka28-trb -- sh -c 'curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local'

Also make sure its not accessible from the other pod(s)

kubectl exec cyan-black-cka28-trb -- sh -c 'curl cyan-svc-cka28-trb.cyan-ns-cka28-trb.svc.cluster.local'

It should not work from this pod. So its looking good now.

Details

Is the app accessible from the cyan-white-cka28-trb pod?


Is the App NOT accessible from the cyan-black-cka28-trb pod?


Is the Network Policy still in use?



