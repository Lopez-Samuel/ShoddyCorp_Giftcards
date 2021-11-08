# Part Two 


Looking at the instructions it looks like we are needed to do a migration with kubernetes jobs. 

To do this we must create a yaml file to integrate using django's migration functionality. In order to successfully do this, we must assign execute permissions and enter the following: 

Kubectl apply –f integration.yaml  

 Python manage.py migrations will seem like django can do this job for us. 

The setup.sql script seems to be performing the database migrations from the models file and seeds the database to populate it with data.  

 I modify db/Dockerfile to remove the lines that performs the migrations and database seeding similtaneously. This requires use to comment/remove lines from the Dockerfile. 
`COPY ./products.csv /products.csv
COPY ./users.csv /users.csv
#COPY ./setup.sql /docker-entrypoint-initdb.d/setup.sql
COPY ./db-seed.sql /docker-entrypoint-initdb.d/db-seed.sql
ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld", "--secure-file-priv=/"]
#CMD ["--secure-file-priv=/"]`
 
 ## kubectl get jobs ##
 kubectl get jobs will return a completed migration 
 Here is the migration yaml file 
 
 `apiVersion: batch/v1
kind: Job
metadata:
  name: dbmigration
spec:
  template:
    spec:
      containers: 
      - name: dbmigration
        image: nyuappsec/assign3:v0
        command: ['python3', 'manage.py', 'migrate']
        #command: ["shellscript.sh"]
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
                    name: newsecret
                    key: username

            - name: ADMIN_PASS
              valueFrom:
                secretKeyRef:
                    name: newsecret
                    key: password

            - name: SECRET_KEY
              valueFrom:
                secretKeyRef:
                    name: newsecret
                    key: secret_key

      restartPolicy: Never
  backoffLimit: 4`
  
  
