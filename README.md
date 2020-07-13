# terraform-swap-provider-instances

POC for how to run separate and potentially concurrent `terraform apply`s for each different provider instances while sharing a single configuration file.

This POC uses Consul to create different provider instances - Consul server agents running on different ports. For each instance, the `terraform apply` will create different k/v pair resources.

**Approximate workflow:**

Create resource(s) for one Consul agent (east) using `terraform apply -var "workspace=east"`

Create resource(s) for another Consul agent (west) using `terraform apply -var "workspace=west"`

**Notable Configuration Details:**

There is one configuration file `main.tf` that contains the configuration information for different Consul provider instances stored in `local` map.

`terraform.auto.tfvars`'s `service_mapping` contains the expected resources to be created for each Consul agent east/west. `services` contains the details of the resources that are created.

**Steps:**

Run a Consul agent (east) locally at port `8500`
```
consul agent \
   -server \
   -bootstrap-expect=1 \
   -data-dir=consul-data \
   -bind=127.0.0.1 \
   -node=agent-one \
   -http-port=8500 \
   -ui
```

Confirm working: go to UI http://localhost:8500/ui and navigate to the the "Key/Value" page.

Create k/v resources: `terraform apply -var "workspace=east"`

Confirm k/v resources are created: refresh "Key/Value" page and see the east directory. Click into east directory and see 'web1' resource. This matches `service_mapping` in `terraform.auto.tfvars`.

Destroy resources and stop Consul agent:
```
terraform destroy
consul leave
```

Now, repeating steps above to run a Consul agent (west) locally at port `8501`
```
consul agent \
   -server \
   -bootstrap-expect=1 \
   -data-dir=consul-data \
   -bind=127.0.0.1 \
   -node=agent-one \
   -http-port=8501 \
   -ui
```

Confirm working: go to UI http://localhost:8501/ui and navigate to the the "Key/Value" page.

Create k/v resources: `terraform apply -var "workspace=west"`

Confirm k/v resources are created: refresh "Key/Value" page and see the west directory. Click into west directory and see two resources: 'web1' and 'web2'

Destroy resources and stop Consul agent:
```
terraform destroy
consul leave -http-addr=http://127.0.0.1:8501
```
