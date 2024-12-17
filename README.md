****Compute resource creation****


**Explanation of the components in the script:**

Provider Configuration:

The google provider is configured to authenticate using a service account JSON key (<YOUR-CREDENTIALS-FILE>.json), set the project, and select the region where resources are created.
VPC Network:

google_compute_network resource creates a custom Virtual Private Cloud (VPC) network called "my-vpc-network".
Subnetwork:

google_compute_subnetwork creates a subnet within the VPC with an IP range of 10.0.0.0/24.
Compute Instance:

google_compute_instance defines a VM instance with a specified machine type (e2-medium), zone (us-central1-a), and boot disk using a Debian image.
The network interface is attached to the VPC and subnet created earlier. It also includes an access_config block to assign a public IP to the VM.
Firewall Rule:

google_compute_firewall creates a firewall rule to allow inbound SSH traffic (port 22) from anywhere (0.0.0.0/0).

**Steps to use this script:**

Set up GCP Service Account:

In GCP, create a service account and download the JSON key.
Set the path to this key in the Terraform provider configuration.
Initialize Terraform: In the directory containing main.tf, run the following command to initialize the working directory:

bash
Copy code
terraform init
Plan: Run the following command to see the execution plan, which will show what resources will be created:

bash
Copy code
terraform plan
Apply: After reviewing the plan, apply the configuration to create the resources:

bash
Copy code
terraform apply
Confirm the action when prompted.

SSH into the VM: After the resources are created, you can SSH into the instance using the external IP of the VM.

bash
Copy code
ssh your-username@<VM-EXTERNAL-IP>
Clean up: After you are done, you can destroy the created resources using the command:

bash
Copy code
terraform destroy
Notes:
Credentials File: Make sure the credentials file (<YOUR-CREDENTIALS-FILE>.json) is securely stored and accessible.
Customizations: You can adjust the region, zone, machine type, network, subnetwork IP range, and VM image according to your requirements.

**GKE Cluster Creation**

**Explanation of the Components:**

Provider Configuration:

The google provider is configured with the credentials file, project ID, and region where the GKE cluster will be created.
Enable APIs:

The google_project_service resources enable the required GKE API (container.googleapis.com) and Compute Engine API (compute.googleapis.com) to create the GKE cluster.
VPC Network and Subnetwork:

A custom VPC network (gke-vpc-network) and subnet (gke-subnet) are created to ensure that the GKE cluster has its own private network.
GKE Cluster Configuration:

A GKE cluster is created with a name (my-gke-cluster) and the node pool configuration includes 3 nodes of type e2-medium. The oauth_scopes grant permissions to the nodes.
The ip_allocation_policy is configured to use IP aliasing for Kubernetes Pods and Services.
The node pool is configured to allow auto-upgrades and auto-repairs to ensure high availability and resilience.
Firewall Rule:

A firewall rule is created to allow HTTPS (port 443) traffic to the GKE cluster.
IAM Roles:

A service account (gke-service-account) is created for the GKE cluster with the roles/container.admin IAM role, which provides necessary permissions to manage GKE resources.


**Access the GKE Cluster:**

After Terraform creates the GKE cluster, you can configure your kubectl context to access the GKE cluster using the following command:

gcloud container clusters get-credentials my-gke-cluster --zone us-central1-a --project <YOUR-GCP-PROJECT>

Now you can interact with your GKE cluster using kubectl


**Compute instance with credentials from Hashicorp Vault**

Store GCP Credentials in Vault

Store the GCP service account credentials in HashiCorp Vault using the vault write command:

vault write secret/gcp-credentials \
  credentials=@/path/to/your/gcp-service-account-key.json


**Explanation of the Configuration**

Vault Provider:

The vault provider is configured to communicate with HashiCorp Vault. Replace the Vault address if needed (http://127.0.0.1:8200 is the default local address).

GCP Provider:

The google provider is configured to authenticate using credentials retrieved dynamically from Vault.
data.vault_generic_secret.gcp_credentials.data["credentials"] pulls the GCP service account credentials from Vault.
Fetching Credentials from Vault:

The data "vault_generic_secret" block reads the credentials stored in Vault at secret/gcp-credentials. These credentials are used by Terraform to authenticate to GCP.
GCP Resources:

VPC Network:
A custom VPC (my-vpc-network) is created without automatically created subnets.
Subnetwork: A subnet is created in us-central1 with a CIDR block of 10.0.0.0/24.
Compute Instance: A Linux-based virtual machine (my-linux-vm) is created with the e2-medium machine type and the Debian OS image.
Firewall Rule: A firewall rule allows inbound SSH traffic to the VM from any IP address (for access).
Metadata and SSH:

SSH keys are passed via the metadata block to enable SSH access to the instance.
