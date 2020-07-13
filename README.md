# terraform-swap-provider-instances

POC for how to run separate and potentially concurrent `terraform apply`s for each different provider instances while sharing a single configuration file.

This POC uses Consul to create different provider instances - Consul server agents running on different ports. For each instance, the `terraform apply` will create different k/v pair resources.

**Description:**

Each provider instance has its own `tfvars` files that contains the provider instance's specific configuration values. The system building the `tfvars` is aware of the mapping instance to provider configuration.

**Approximate workflow:**

Create resource(s) for one Consul agent (east) using `terraform apply -var-file="east.tfvars"`

Create resource(s) for another Consul agent (west) using `terraform apply -var-file="west.tfvars"`

**Notable Configuration Details:**

There is one configuration file `main.tf` which calls the variables that contain the configuration information for different Consul provider instances. The variable values are stored in each instance's `tfvars` file. For example `east.tfvars` contains the Consul address and datacenter to use for the east Consul instance.

The system building out the `tfvars` file will store the mapping of instance to provider configuration rather than storing it in Consul. Notably, this implementation does not contain a `service_mapping` variable mapping instances to services or a `local` variable mapping instance name to provider configuration.

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

Create k/v resources: `terraform apply -var-file="east.tfvars"`

Confirm k/v resources are created: refresh "Key/Value" page and see the east directory. Click into east directory and see 'web1' resource. This matches `east.tfvars` declared services.

Destroy resources and stop Consul agent:
```
terraform destroy -var-file="east.tfvars"
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

Create k/v resources: `terraform apply -var-file="west.tfvars"`

Confirm k/v resources are created: refresh "Key/Value" page and see the west directory. Click into west directory and see two resources: 'web1' and 'web2'

Destroy resources and stop Consul agent:
```
terraform destroy -var-file="west.tfvars"
consul leave -http-addr=http://127.0.0.1:8501
```
