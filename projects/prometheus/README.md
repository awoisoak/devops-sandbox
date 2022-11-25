A Prometheus server is setup together with an instance of AlertManager, Grafana, and a bunch of servers and Exporters.
[AlertManager](https://prometheus.io/docs/alerting/latest/alertmanager/) is configured to send alert notifications via email.

How metrics are generated:
 - The host metrics are exposed through a [Node exporter](https://github.com/prometheus/node_exporter)
 - Containers metrics are exposed by a [Cadvisor exporter](https://github.com/google/cadvisor)
 - The stand alone [Photo-shop](https://github.com/awoisoak/photo-shop) web server internally exposes app metrics 
  
  TODO: The Photo-shop running behind the load balancer can't be scrapped by Prometheus. The web server instances should probably be [pushing metrics](https://prometheus.io/docs/instrumenting/pushing/) instead. 

<img width="1355" alt="grafana" src="https://user-images.githubusercontent.com/11469990/203922046-ad55f9f0-43a2-40dc-afb0-fa995c5648d1.png">
