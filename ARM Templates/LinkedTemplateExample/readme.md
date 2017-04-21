# Linked Template samples
The contents of this folder provide some examples of doing Azure resource manager templates that go beyond the basics. It should be stressed that these are simply examples, **have not been fully tested for all scenarios**, and should not be taken as a best practice. They're only here to help assist in your own learnings as I learned while creating them.

## What's here
These templates, when run in their entirity will create 3 storage accounts, a web app, a service bus namespace and queue, a virtual network with 3 subnets (each with their own NSG), a public IP that's associated with a RDP "jump box", another public IP that's associated with an Azure Load Balancer that balances traffic across 2 or more VMs, and a service fabric cluster with 1 load type and 3 or more instances that's exposing its gateway/management services via a load balancer on an internal IP address.

You can one or all of these templates, depending on your needs. But they have been built with the intention of running them from the deploy.ps1 powershell script. This script prompts for some values and passes those values into the wrapper templates deploy-master.json

The powershell script is important because deploy-master.json uses linked templates which requires the other items to be linked to via a public URL. The Powershell script uploads the files to an Azure storage account where they can be linked from.

# Learning More
These templates were created to help illustrate creating flexible, reusable templates. To see more about the tips and trics demostrated here, [please refer to the accompaning blog post](https://brentdacodemonkey.wordpress.com/2017/03/09/azure-resource-manager-template-tips-and-tricks/).  