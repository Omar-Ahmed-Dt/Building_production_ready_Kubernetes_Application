## platform:                                                                                        
- Gateway/Ingress : Ingress Nginx                                                                   
- Secret Management: External Secret Manager                                                        
- Certificate Management: Cert Manager                                                              
- Continous Delivery: Argo CD                                                                       
- Cluster Autoscaling                                                                               
                                                                                                    
## Observability:                                                                                   
- Visualization: Grafana                                                                            
- Logging: Grafana Loki                                                                             
- Metrics: Prometheus                                                                               
- Auto-instrumented Tracing: Pixie                                                                  
- Tracing: Grafana Tempo && Open Telemetry                                                          
                                                                                                    
## Resilience:                                                                                      
- Volume Backups: native cloud backups or Longhorn or Velero                                        
- API/ETCD Backups: Velero                                                                          
                                                                                                    
## FinOps:                                                                                          
- Event-driven Autoscaling: KEDA                                                                    
- Optimized Cluster Autoscaling: AWS:Karpenter                                                      
- Cost Monitoring: OpenCost                                                                         
                                                                                                    
## Security:                                                                                        
- Configuration Security: Kyverno                                                                   
- Image Security: Trivy                                                                             
- Cloud Security Posture: Prowler                                                                   
- CIS Benchmarks: Trivy                                                                             
- Service Mesh: Cilium                                                                              
- Runtime Monitoring: Falco                                                                         
- MicroVM Isolation: Firecracker                                                                    
                                                                                                    
## Developer Self-Service:                                                                          
- Workflows & Runbooks: Argo Workflows                                                              
- Service Catalog                                                                                   
                                                                                                    
## laaS Management:                                                                                 
- Cloud Resources: Crossplane                                                                       
- DNS: External DNS                                                                                 
- Cluster Fleet: Cluster API or Gardener)                                                                                                                                                                    

## Container Optimized OS
- AWS: Bottlerocket
- Anywhere: Fedora Core0S
