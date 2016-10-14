Workshop in a box Cluster

The contents of this folder are intended to allow you to create a "DMZ" cluster for use in a Service Fabric workshop. This template creates a cluster in a vNet that consists of 3 Zones:

- A 'public' front end zone
- A 'private' back end zone
- A 'management' zone for the Service Fabric Services

The scripts will then add Load Balancer rules to both the front and back end Load Balancers so that each workshop attendee will have a dedicated, Load Balanced port they can deploy an application too. 

To deploy using this template you will need to Azure Powershell installed. Then simply run the CreateWorkshopCluster.ps1 script. It will prompt for either a deployment file or the required parameters and create the cluster for you. 

Note: The DMZ template supports a great many customizable parameters that are not supported by the creation script. To fully leverage those values, you will need to use a parameter file.