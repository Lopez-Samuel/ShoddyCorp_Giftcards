# part_1_complete
Part one's goal is to find secrets in the django file and report on them. 
The first step I took in this assignment to find the secrets is to grep for the output with  

## Finding Secrets ## 
Grep -I "secret" in each subdirectory 

By doing this I found the following results: 

 
GiftcardSite/k8/django-deploy.yaml:37:                secretKeyRef: 

GiftcardSite/k8/django-deploy.yaml:38:                    name: admin-login-secrets 

GiftcardSite/k8/django-deploy.yaml:43:                secretKeyRef: 

GiftcardSite/k8/django-deploy.yaml:44:                    name: admin-login-secrets 

GiftcardSite/k8/django-admin-pass-secret.yaml:2:kind: Secret 

GiftcardSite/k8/django-admin-pass-secret.yaml:4:    name: admin-login-secrets 

GiftcardSite/GiftcardSite/settings.py:23:# SECURITY WARNING: keep the secret key used in production secret! 

GiftcardSite/GiftcardSite/settings.py:24:SECRET_KEY = 'kmgysa#fz+9(z1*=c0ydrjizk*7sthm2ga1z4=^61$cxcq8b$l' 

env: 

            - name: MYSQL_ROOT_PASSWORD 

              value: thisisatestthing. 
             
### Modifying the Secrets File (newsecret.yaml) ###
These files stored sensitive data so to go about correcting this data, I created my own yaml file named newsecret that contained appropriate base64 encoding for some of the secrets and applied an environmental variable with export SECRET_KEY = <value> 

After this, I went into settings.py and changed my secret_key hardcoded value to os.environment.get(SECRET_KEY) to use what I had in local storage, and this ensured the code could successfully run without exposing the secret key to the public 

` apiVersion: v1
kind: Secret
metadata:
    name: newsecret
type: Opaque
data:
    username: YWRtaW4=
    password: dGhpc2lzYXRlc3R0aGluZy4=
    #secret_key: kmgysa#fz+9(z1*=c0ydrjizk*7sthm2ga1z4=^61$cxcq8b$l
    secret_key: a21neXNhI2Z6KzkoejEqPWMweWRyaml6ayo3c3RobTJnYTF6ND1eNjEkY3hjcThiJGw=
    `
    
### Modifying db-deployment ###
`
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-container
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql-container
  template:
    metadata:
      labels:
        app: mysql-container
        tier: backend
    spec:
      containers:
        - name: mysql-container
          image: nyuappsec/assign3-db:v0
          env:
            #- name: MYSQL_ROOT_PASSWORD
            #  value: thisisatestthing.
            - name: MYSQL_ROOT_PASSWORD 
              valueFrom:
                secretKeyRef:
                  name: newsecret
                  key: password

            - name: MYSQL_DATABASE
              value: GiftcardSiteDB

          ports:
            - containerPort: 3306
          volumeMounts:
            - name: mysql-volume-mount
              mountPath: /var/lib/mysql

      volumes:
        - name: mysql-volume-mount
          persistentVolumeClaim:
            claimName: mysql-pvc
   `
   
  ### modifying django-deploy-yaml ###
  `apiVersion: apps/v1
kind: Deployment
metadata:
  name: assignment3-django-deploy
  labels:
    app: assignment3-django-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      pod: assignment3-django-deploy
  template:
    metadata:
      labels:
        pod: assignment3-django-deploy
    spec:
      containers:
        - name: assignment3-django-deploy
          image: nyuappsec/assign3:v0
          ports:
            - containerPort: 8000
          env:
            - name: MYSQL_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: newsecret
                  key: password

            - name: MYSQL_DB
              value: GiftcardSiteDB

            - name: MYSQL_HOST
              value: mysql-service

            - name: ALLOWED_HOSTS
              value: "*,"

            - name: ADMIN_UNAME
              valueFrom:
                secretKeyRef:
                    name: admin-login-secrets
                    key: username

            - name: ADMIN_PASS
              valueFrom:
                secretKeyRef:
                    name: admin-login-secrets
                    key: password

            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                    name: newsecret
                    key: secret_key

          volumeMounts:
            - name: mysql-volume-mount
              mountPath: /var/lib/busybox

            - name: static-data-volume-mount
              mountPath: /vol/static

      volumes:
        - name: mysql-volume-mount
          persistentVolumeClaim:
            claimName: mysql-pvc

        - name: static-data-volume-mount
          persistentVolumeClaim:
            claimName: static-data-pvc`
            
  ### Settings.py ###
  `
  import os
import base64

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY')`


   
   

