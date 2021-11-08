# Part 3 #

## views.py | Remove Unwanted Monitoring ##
For this part I was viewing views.py for potential flaws.  From the looks of it- Prometheus was recording a secret password into the counter during a POST request request method. 

graphs[pword].inc  

In other instances it seems to be mapping to other keys as well that is unsafe. Views.py modified is in the part3 directory. 

 

To fix this I removed out several lines in views.py that I deemed to be vulnerable by commenting them out 

`graphs['r_counter'] = Counter('python_request_r_posts', 'The total number'\ 

  + ' of register posts.') 

graphs['l_counter'] = Counter('python_request_l_posts', 'The total number'\ 

  + ' of login posts.') 

graphs['b_counter'] = Counter('python_request_b_posts', 'The total number'\ 

  + ' of card buy posts.') 

graphs['g_counter'] = Counter('python_request_g_posts', 'The total number'\ 

  + ' of card gift posts.') 

graphs['u_counter'] = Counter('python_request_u_posts', 'The total number'\ 

  + ' of card use posts.')` 

 

## Expand Monitoring ##
I then added a line of my own to account for 404 errors: 

 graphs['error_counter'].inc() #rc4544 
 
 increment every time there is a 404 and this should be a good way to increment db errors
 
 ## Helm Prometheus ##
  

I then installed helm then prometheus as a service and ran it as follows: 

`curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 

chmod 700 get_helm.sh 

./get_helm.sh`

## Expanding Prometheus ##

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 

 

helm install prometheus prometheus-community/prometheus 
 


kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np 

 

minikube service prometheus-server-np 

 

`Kubectl get configmap 

kubectl edit configmap prometheus-server 

export KUBE_EDITOR="nano" 

 
kubectl get configmap prometheus-server -o yaml` 

 
Links: 
https://www.fosstechnix.com/install-prometheus-and-grafana-on-kubernetes-using-helm/#prerequisites 

https://blog.marcnuri.com/prometheus-grafana-setup-minikube 



## Prometheus Yaml## 
I installed prometheus via command line to work with systemctl as a service
From here, I edited the prometheus yaml file to contain the following 

this was added: 
`global:

  scrape_interval: 10s

scrape_configs:

  – job_name: ‘prometheus’

    scrape_interval: 5s

    static_configs:

      – targets: [‘localhost:9090’]`
      
I then started prometheus server with the following
`minikube service prometheus-server-np`

I verified with 
`kubectl get pods`

This ran successfully, and all I needed to do was point this to the GiftCardSite
From trial and error, I found a document to assist with this by editing the prometheus server file
https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/additional-scrape-config.md
`kubectl get configmap`

Exported to use with nano instead of VIM
 export KUBE_EDITOR="nano" 
 
 Exported my edits to myprometheus.yaml
 
 and edited the prometheus-server yaml to contain a job named Gift_Card_monitoring on port 8080
 
 `- job_name: GiftCardSite_monitoring
      static_configs:
      - targets:
      -  proxy-service:8080`
      
   
      
   
   From here, we can port forward with the following if the 8080 port is occupied (optional): 

kubectl port-forward deployment/prometheus-pushgateway 9092 

 

From here if we click on metrics on the website, we will find the key created in view.py 

You may be able to start prometheus server with 
minikube start prometheus-server 
or minikube service prometheus-operator 
 



