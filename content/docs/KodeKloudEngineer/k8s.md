## k8s Level 2

### Kubernetes Shared Volumes

Create a pod named volume-share-xfusion.


For the first container, use image fedora with latest tag only and remember to mention the tag i.e fedora:latest, container should be named as volume-container-xfusion-1, and run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/news.


For the second container, use image fedora with the latest tag only and remember to mention the tag i.e fedora:latest, container should be named as volume-container-xfusion-2, and again run a sleep command for it so that it remains in running state. Volume volume-share should be mounted at path /tmp/cluster.


Volume name should be volume-share of type emptyDir.


After creating the pod, exec into the first container i.e volume-container-xfusion-1, and just for testing create a file news.txt with the content Welcome to xFusionCorp Industries under the mounted path of first container i.e /tmp/news.


The file news.txt should be present under the mounted path /tmp/cluster on the second container volume-container-xfusion-2 as well, since they are using a shared volume.

```
apiVersion: v1
kind: Pod
metadata:
  name: volume-share-xfusion
spec:
  volumes:
  - name: volume-share
    emptyDir: {}
  containers:
  - name: volume-container-xfusion-1
    image: fedora:latest
    command: ["/bin/sleep", "infinity"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/news
  - name: volume-container-xfusion-2
    image: fedora:latest
    command: ["/bin/sleep", "infinity"]
    volumeMounts:
    - name: volume-share
      mountPath: /tmp/cluster

kubectl apply -f volume-share-xfusion.yaml

kubectl exec -it volume-share-xfusion -c volume-container-xfusion-1 -- /bin/sh -c 'echo "Welcome to xFusionCorp Industries" > /tmp/news/news.txt'
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-2 -- cat /tmp/cluster/news.txt
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-1 -- ls -l /tmp/news
kubectl exec -it volume-share-xfusion -c volume-container-xfusion-2 -- ls -l /tmp/cluster

```

## Kubernetes Sidecar Containers

Create a pod named webserver.
Create an emptyDir volume shared-logs.
Create two containers from nginx and ubuntu images with latest tag only and remember to mention tag i.e nginx:latest, nginx container name should be nginx-container and ubuntu container name should be sidecar-container on webserver pod.
Add command on sidecar-container "sh","-c","while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"
Mount the volume shared-logs on both containers at location /var/log/nginx, all containers should be up and running.
Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.


```
apiVersion: v1
kind: Pod
metadata:
  name: webserver
spec:
  volumes:
  - name: shared-logs
    emptyDir: {}
  containers:
  - name: nginx-container
    image: nginx:latest
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
  - name: sidecar-container
    image: ubuntu:latest
    command: ["sh", "-c", "while true; do cat /var/log/nginx/access.log /var/log/nginx/error.log; sleep 30; done"]
    volumeMounts:
    - name: shared-logs
      mountPath: /var/log/nginx
```

## Deploy Nginx Web Server on Kubernetes Cluster

Create a deployment using nginx image with latest tag only and remember to mention the tag i.e nginx:latest. Name it as nginx-deployment. The container should be named as nginx-container, also make sure replica counts are 3.

Create a NodePort type service named nginx-service. The nodePort should be 30011.

Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx-container
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80

```


## Print Environment Variables

Create a pod named print-envars-greeting.

Configure spec as, the container name should be print-env-container and use bash image.

Create three environment variables:

a. GREETING and its value should be Welcome to

b. COMPANY and its value should be Nautilus

c. GROUP and its value should be Industries

Use command ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"'] (please use this exact command), also set its restartPolicy policy to Never to avoid crash loop back.

You can check the output using kubectl logs -f print-envars-greeting command.


```
apiVersion: v1
kind: Pod
metadata:
  name: print-envars-greeting
spec:
  containers:
  - name: print-env-container
    image: bash:latest
    env:
    - name: GREETING
      value: "Welcome to"
    - name: COMPANY
      value: "Nautilus"
    - name: GROUP
      value: "Industries"
    command: ["/bin/sh", "-c", 'echo "$(GREETING) $(COMPANY) $(GROUP)"']
  restartPolicy: Never
```

### Rolling Updates And Rolling Back Deployments in Kubernetes

Create a namespace xfusion. Create a deployment called httpd-deploy under this new namespace, It should have one container called httpd, use httpd:2.4.25 image and 4 replicas. The deployment should use RollingUpdate strategy with maxSurge=1, and maxUnavailable=2. Also create a NodePort type service named httpd-service and expose the deployment on nodePort: 30008.


Now upgrade the deployment to version httpd:2.4.43 using a rolling update.


Finally, once all pods are updated undo the recent update and roll back to the previous/original version.


```
apiVersion: v1
kind: Namespace
metadata:
  name: xfusion
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: httpd-deploy
  namespace: xfusion
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 2
  selector:
    matchLabels:
      app: httpd
  template:
    metadata:
      labels:
        app: httpd
    spec:
      containers:
      - name: httpd
        image: httpd:2.4.25
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: httpd-service
  namespace: xfusion
spec:
  type: NodePort
  selector:
    app: httpd
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30008

    kubectl apply -f httpd-deploy-xfusion.yaml
    kubectl set image deployment/httpd-deploy httpd=httpd:2.4.43 -n xfusion
    kubectl rollout undo deployment/httpd-deploy -n xfusion
    kubectl get deployment httpd-deploy -n xfusion -o jsonpath='{.spec.template.spec.containers[0].image}'
    kubectl rollout history deployment/httpd-deploy -n xfusion

```

## Deploy Jenkins on Kubernetes

1) Create a namespace jenkins

2) Create a Service for jenkins deployment. Service name should be jenkins-service under jenkins namespace, type should be NodePort, nodePort should be 30008

3) Create a Jenkins Deployment under jenkins namespace, It should be name as jenkins-deployment , labels app should be jenkins , container name should be jenkins-container , use jenkins/jenkins image , containerPort should be 8080 and replicas count should be 1.


Make sure to wait for the pods to be in running state and make sure you are able to access the Jenkins login screen in the browser before hitting the Check button.


Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.

```
apiVersion: v1
kind: Namespace
metadata:
  name: jenkins
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jenkins-deployment
  namespace: jenkins
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jenkins
  template:
    metadata:
      labels:
        app: jenkins
    spec:
      containers:
      - name: jenkins-container
        image: jenkins/jenkins
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: jenkins-service
  namespace: jenkins
spec:
  type: NodePort
  selector:
    app: jenkins
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30008
---
kubectl apply -f jenkins-deployment.yaml
kubectl get ns jenkins

kubectl get deployment jenkins-deployment -n jenkins

kubectl get pods -n jenkins -l app=jenkins -w
kubectl get svc jenkins-service -n jenkins
kubectl get nodes -o wide

http://<NODE-IP>:30008
(Example: http://192.168.10.XX:30008)

kubectl exec -it $(kubectl get pod -n jenkins -l app=jenkins -o jsonpath="{.items[0].metadata.name}") -n jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

## Deploy Grafana on Kubernetes Cluster


1.) Create a deployment named grafana-deployment-nautilus using any grafana image for Grafana app. Set other parameters as per your choice.


2.) Create NodePort type service with nodePort 32000 to expose the app.


You do not need to make any configuration changes inside the Grafana app once deployed; just make sure you can access the Grafana login page.


Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.

```

apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana-deployment-nautilus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        resources:
          requests:
            cpu: "100m"
            memory: "256Mi"
          limits:
            cpu: "500m"
            memory: "512Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: grafana-service
spec:
  type: NodePort
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
    nodePort: 32000

kubectl get deployment grafana-deployment-nautilus

kubectl get pods -l app=grafana -w

kubectl logs -l app=grafana --tail=50

```

## Deploy Tomcat App on Kubernetes

```
apiVersion: v1
kind: Namespace
metadata:
  name: tomcat-namespace-xfusion
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deployment-xfusion
  namespace: tomcat-namespace-xfusion
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tomcat
  template:
    metadata:
      labels:
        app: tomcat
    spec:
      containers:
      - name: tomcat-container-xfusion
        image: kodekloud/centos-ssh-enabled:tomcat
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tomcat-service-xfusion
  namespace: tomcat-namespace-xfusion
spec:
  type: NodePort
  selector:
    app: tomcat
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 32227

# Check namespace
kubectl get namespace tomcat-namespace-xfusion

# Check deployment
kubectl get deployment tomcat-deployment-xfusion -n tomcat-namespace-xfusion

# Check pod (wait until it shows Running and READY 1/1)
kubectl get pods -n tomcat-namespace-xfusion -l app=tomcat -w
kubectl get nodes -o wide
kubectl get svc tomcat-service-xfusion -n tomcat-namespace-xfusion
kubectl logs -n tomcat-namespace-xfusion -l app=tomcat --tail=100

```

## Deploy Node App on Kubernetes

Create a deployment using kodekloud/centos-ssh-enabled:node image, replica count must be 2.

Create a service to expose this app, the service type must be NodePort, targetPort must be 8080 and nodePort should be 30012.

Make sure all the pods are in Running state after the deployment.

You can check the application by clicking on NodeApp button on top bar.


You can use any labels as per your choice.


Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nodeapp
  template:
    metadata:
      labels:
        app: nodeapp
    spec:
      containers:
      - name: node-container
        image: kodekloud/centos-ssh-enabled:node
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: node-service
spec:
  type: NodePort
  selector:
    app: nodeapp
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30012

# Check deployment
kubectl get deployment node-deployment

# Check pods (wait until both show Running and READY 2/2)
kubectl get pods -l app=nodeapp -w
kubectl get svc node-service

kubectl get nodes -o wide

# View detailed status
kubectl describe deployment node-deployment

# Check service details
kubectl describe svc node-service

# View pod logs (if needed)
kubectl logs -l app=nodeapp --tail=50

```

## Troubleshoot Deployment issues in Kubernetes

The deployment name is redis-deployment. The pods are not in running state right now, so please look into the issue and fix the same.
Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.


Correct the config spelling and update the image name, it should work

```
# Check pod status
kubectl get pods -l app=redis   # or whatever label the deployment uses

# Get detailed pod events and errors
kubectl describe pod <pod-name>   # replace with actual pod name from above

# Check deployment events
kubectl describe deployment redis-deployment

kubectl edit deployment redis-deployment

# Check events for more clues
kubectl get events --sort-by=.metadata.creationTimestamp

# Check if the deployment is using the correct labels/selectors
kubectl get deployment redis-deployment -o yaml

```

## Fix issue with LAMP Environment in Kubernetes

FYI, the deployment name is lamp-wp and it is using a service named lamp-service. Apache is using the default HTTP port, and the NodePort is 30008. From the application logs, it has been identified that the application is facing some issues connecting to the database, in addition to other problems. Additionally, there are some environment variables associated with the pods, such as MYSQL_ROOT_PASSWORD, MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, and MYSQL_HOST

Also, do not attempt to delete or modify any other existing components, such as deployment names, service names, types, labels, secrets and so on.


Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.


```

service apache2 restart

Update below variable in /app/index.php
 
$dbpass = $_ENV['MYSQL_PASSWORD'];
$dbhost = $_ENV['MYSQL_HOST'];

Update the Service port#

```

## Level 4 

## Deploy Redis Deployment on Kubernetes


Create a config map called my-redis-config having maxmemory 2mb in redis-config.

Name of the deployment should be redis-deployment, it should use
redis:alpine image and container name should be redis-container. Also make sure it has only 1 replica.

The container should request for 1 CPU.

Mount 2 volumes:

a. An Empty directory volume called data at path /redis-master-data.

b. A configmap volume called redis-config at path /redis-master.

c. The container should expose the port 6379.

Finally, redis-deployment should be up and running.

```

apiVersion: v1
kind: ConfigMap
metadata:
  name: my-redis-config
data:
  redis-config: |
    maxmemory 2mb


apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
      - name: redis-container
        image: redis:alpine
        resources:
          requests:
            cpu: "1"
        ports:
        - containerPort: 6379
        volumeMounts:
        - name: data
          mountPath: /redis-master-data
        - name: redis-config
          mountPath: /redis-master
      volumes:
      - name: data
        emptyDir: {}
      - name: redis-config
        configMap:
          name: my-redis-config

# Check deployment
kubectl get deployment redis-deployment

# Check pod (wait until it shows Running and READY 1/1)
kubectl get pods -l app=redis -w

kubectl get all -l app=redis

# Check if ConfigMap is mounted correctly
kubectl exec -it $(kubectl get pod -l app=redis -o jsonpath="{.items[0].metadata.name}") -- cat /redis-master/redis-config

# Check Redis is running and maxmemory is set (optional)
kubectl exec -it $(kubectl get pod -l app=redis -o jsonpath="{.items[0].metadata.name}") -- redis-cli CONFIG GET maxmemory


```

1.) Create a PersistentVolume mysql-pv, its capacity should be 250Mi, set other parameters as per your preference.


2.) Create a PersistentVolumeClaim to request this PersistentVolume storage. Name it as mysql-pv-claim and request a 250Mi of storage. Set other parameters as per your preference.


3.) Create a deployment named mysql-deployment, use any mysql image as per your preference. Mount the PersistentVolume at mount path /var/lib/mysql.


4.) Create a NodePort type service named mysql and set nodePort to 30007.


5.) Create a secret named mysql-root-pass having a key pair value, where key is password and its value is YUIidhb667, create another secret named mysql-user-pass having some key pair values, where first key is username and its value is kodekloud_rin, second key is password and value is GyQkFRVNr3, create one more secret named mysql-db-url, key name is database and value is kodekloud_db9


6.) Define some environment variables within the container:


a.) name: MYSQL_ROOT_PASSWORD, should pick value from secretKeyRef name: mysql-root-pass and key: password


b.) name: MYSQL_DATABASE, should pick value from secretKeyRef name: mysql-db-url and key: database


c.) name: MYSQL_USER, should pick value from secretKeyRef name: mysql-user-pass key key: username


d.) name: MYSQL_PASSWORD, should pick value from secretKeyRef name: mysql-user-pass and key: password


Note: The kubectl utility on the jump-host has been configured to work with the Kubernetes cluster.





```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/mnt/data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 250Mi
  storageClassName: manual
---



apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-root-pass
              key: password
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: mysql-db-url
              key: database
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: username
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mysql-user-pass
              key: password
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim


apiVersion: v1
kind: Service
metadata:
  name: mysql
spec:
  type: NodePort
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
    nodePort: 30007

```
```
# Root password secret
kubectl create secret generic mysql-root-pass --from-literal=password=YUIidhb667

# User credentials secret
kubectl create secret generic mysql-user-pass \
  --from-literal=username=kodekloud_rin \
  --from-literal=password=GyQkFRVNr3

# Database name secret
kubectl create secret generic mysql-db-url --from-literal=database=kodekloud_db9

```


```
# Check PV and PVC
kubectl get pv mysql-pv
kubectl get pvc mysql-pv-claim

# Check secrets
kubectl get secrets

# Check deployment and pod (wait until Running and 1/1 Ready)
kubectl get deployment mysql-deployment
kubectl get pods -l app=mysql -w

# Check service
kubectl get svc mysql

```

## Kubernetes Nginx and PhpFPM Setup


```

apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    events { }
    http {
        server {
            listen 8096;
            root /var/www/html;
            index index.html index.htm index.php;

            location / {
                try_files $uri $uri/ =404;
            }

            location ~ \.php$ {
                fastcgi_pass 127.0.0.1:9000;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                include fastcgi_params;
            }
        }
    }

---

apiVersion: v1
kind: Pod
metadata:
  name: nginx-phpfpm
  labels:
    app: nginx-phpfpm
spec:
  volumes:
  - name: shared-files
    emptyDir: {}
  - name: nginx-config-volume
    configMap:
      name: nginx-config

  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 8096
    volumeMounts:
    - name: shared-files
      mountPath: /var/www/html
    - name: nginx-config-volume
      mountPath: /etc/nginx/nginx.conf
      subPath: nginx.conf

  - name: php-fpm-container
    image: php:8.2-fpm-alpine
    volumeMounts:
    - name: shared-files
      mountPath: /var/www/html

---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  type: NodePort
  selector:
    app: nginx-phpfpm   # Optional, you can also leave selector empty or match pod labels if added
  ports:
  - port: 8096
    targetPort: 8096
    nodePort: 30012


```


```
# Copy the file from jump host into the shared volume via nginx container
kubectl cp /opt/index.php nginx-phpfpm:/var/www/html/index.php -c nginx-container

# Check pod status
kubectl get pod nginx-phpfpm

# Check both containers are running
kubectl get pod nginx-phpfpm -o jsonpath='{.spec.containers[*].name}'

# Verify files in shared volume
kubectl exec -it nginx-phpfpm -c nginx-container -- ls -l /var/www/html

# Check nginx config is mounted correctly
kubectl exec -it nginx-phpfpm -c nginx-container -- cat /etc/nginx/nginx.conf | head -20

kubectl get nodes -o wide

kubectl exec -it nginx-phpfpm -c nginx-container -- chmod 644 /var/www/html/index.php
kubectl exec -it nginx-phpfpm -c nginx-container -- chown 101:101 /var/www/html/index.php

#1. Copy the index.php file again
kubectl cp /opt/index.php nginx-phpfpm:/var/www/html/index.php -c nginx-container

#2. Fix permissions (very important)

kubectl exec -it nginx-phpfpm -c nginx-container -- chmod 644 /var/www/html/index.php
kubectl exec -it nginx-phpfpm -c nginx-container -- chown 101:101 /var/www/html/index.php

#3. Verify the file is correctly placed
kubectl exec -it nginx-phpfpm -c nginx-container -- ls -l /var/www/html
kubectl exec -it nginx-phpfpm -c nginx-container -- cat /var/www/html/index.php
 
# 4. Reload Nginx

kubectl exec -it nginx-phpfpm -c nginx-container -- nginx -s reload

```

Issue Identified:
Nginx is unable to resolve the hostname php-fpm-container in the upstream. Even though both containers are in the same Pod, using the container name sometimes causes resolution issues. The reliable solution is to use 127.0.0.1:9000 (localhost) since both containers share the same network namespace.

Correct Labels in svc and pods should match

copy the file locally


## Deploy Drupal App on Kubernetes

```

apiVersion: v1
kind: PersistentVolume
metadata:
  name: drupal-mysql-pv
spec:
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: "/drupal-mysql-data"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: drupal-mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 3Gi
  storageClassName: manual
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: drupal-mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drupal-mysql
  template:
    metadata:
      labels:
        app: drupal-mysql
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        env:
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_ROOT_PASSWORD
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_DATABASE
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_PASSWORD
        ports:
        - containerPort: 3306
        volumeMounts:
        - name: mysql-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-storage
        persistentVolumeClaim:
          claimName: drupal-mysql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: drupal-mysql-service
spec:
  selector:
    app: drupal-mysql
  ports:
  - port: 3306
    targetPort: 3306
---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: drupal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: drupal
  template:
    metadata:
      labels:
        app: drupal
    spec:
      containers:
      - name: drupal
        image: drupal:8.6
        ports:
        - containerPort: 80
        env:
        - name: MYSQL_HOST
          value: drupal-mysql-service
        - name: MYSQL_PORT
          value: "3306"
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_DATABASE
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_USER
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: drupal-mysql-secret
              key: MYSQL_PASSWORD
 
---
apiVersion: v1
kind: Service
metadata:
  name: drupal-service
spec:
  type: NodePort
  selector:
    app: drupal
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30095

```

```

kubectl create secret generic drupal-mysql-secret \
  --from-literal=MYSQL_ROOT_PASSWORD=rootpassword \
  --from-literal=MYSQL_DATABASE=drupal \
  --from-literal=MYSQL_USER=drupaluser \
  --from-literal=MYSQL_PASSWORD=drupalpass

```

Verify
```
kubectl get pv,pvc,secret,deployment,service

kubectl get pods -w


```

## Deploy Guest Book App on Kubernetes

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-master
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
      role: master
  template:
    metadata:
      labels:
        app: redis
        role: master
    spec:
      containers:
      - name: master-redis-nautilus
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis-master
spec:
  selector:
    app: redis
    role: master
  ports:
  - port: 6379
    targetPort: 6379
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-slave
spec:
  replicas: 2
  selector:
    matchLabels:
      app: redis
      role: slave
  template:
    metadata:
      labels:
        app: redis
        role: slave
    spec:
      containers:
      - name: slave-redis-nautilus
        image: gcr.io/google_samples/gb-redisslave:v3
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis-slave
spec:
  selector:
    app: redis
    role: slave
  ports:
  - port: 6379
    targetPort: 6379
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: php-redis-nautilus
        image: gcr.io/google-samples/gb-frontend@sha256:a908df8486ff66f2c4daa0d3d8a2fa09846a1fc8efd65649c0109695c7c5cbff
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        env:
        - name: GET_HOSTS_FROM
          value: dns
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30009

```
Verify

```
kubectl get deployments
kubectl get pods -w
kubectl get services
```