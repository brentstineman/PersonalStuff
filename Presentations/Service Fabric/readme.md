Contained in this area are presentations and samples related to Service Fabric. In this readme, we'll present some background information on the presentations as well as a host of "learn more" links that help supplement the materials.

# Service Fabric Introduction#
This is an hour long presentation intended for audiences that are not familiar with service fabric and are looking to gain a general understanding. Unlike many other presentations, it focuses less on the creation of services, then it does on the environment that a Service Fabric Cluster presents. This include discussing cluster topology and the system services that perform some of the fabric function. The hope is that by providing some of this information, we can dispell the "magic" about the fabric and foster a better understanding of this powerful microservice orchestration framework.

The presentation is divided into several sections (with estimated times):
- Intro to Microservices (5 min)
- Service Fabric Cluster overview (10 min)
- The Service Fabric Application Model (20 min)
- Application Lifecycle (15 min)

For anyone that attends this presentation, you may find these additional links helpful.

**Service Fabric**
- [Official Documentation Documentation](http://aka.ms/servicefabric)
- [SDK (Windows, Linux ,OSX)](http://aka.ms/servicefabricSDK)
- [Programming Service Fabirc (Safari books)](https://www.safaribooksonline.com/library/view/programming-microsoft-azure/9781509301904/)
- [Introduction to the Resource Manager](https://azure.microsoft.com/en-us/documentation/articles/service-fabric-cluster-resource-manager-introduction/)


**Microservice Architecture**
- [Bounded Context](http://martinfowler.com/bliki/BoundedContext.html)
- ["Gang of Four“ Design Patterns](https://en.wikipedia.org/wiki/Design_Patterns)
- [Cloud Design Patterns](https://msdn.microsoft.com/en-us/library/dn568099.aspx)
- [Idempotence](https://en.wikipedia.org/wiki/Idempotence)
- [Throttling Pattern](https://msdn.microsoft.com/en-us/library/dn589798.aspx)

#Service Fabric Workshop#
This is a 3-4hr workshop for folks with a basic understanding of Service Fabric. It attempts to move beyond the "hello world" scenarios that are demonstrated in the [getting started documentation](https://azure.microsoft.com/en-us/documentation/articles/service-fabric-get-started/) and into some real world challenges. This is broken up into three core sections:

1. Placement Constraints and the Reverse Proxy
2. Stateful Services and Upgrades
3. Actor Framework and Diagnostics

Each section will be composed of a 15-20 minute presentation followed by 40-60 minutes of hands on time.

The workshop utilizes a workshop cluster template included within this section of the respository. It creates a complex Service Fabric cluster composed of 3 different node types in three different subnets, each with their own security restrictions. The cluster includes both internal and external load balancers and can be deployed with a range of ports available for students (I recommend just using a set of playing cards to assign ports to specific attendees).

Workshop Lab 1
These links should be helpful in completing the first workshop lab.

https://azure.microsoft.com/en-us/documentation/articles/service-fabric-reliable-services-communication-webapi/

https://brentdacodemonkey.wordpress.com/2016/09/11/placement-constraints-with-service-fabric/

https://azure.microsoft.com/en-us/documentation/articles/service-fabric-cluster-resource-manager-configure-services/

https://azure.microsoft.com/en-us/documentation/articles/service-fabric-reverseproxy/

Workshop Lab 2

Workshop Lab 3
