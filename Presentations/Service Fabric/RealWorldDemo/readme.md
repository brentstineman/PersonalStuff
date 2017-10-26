To use this demo application, you'll need to perform some manual setup. 

First create a resource  group in your targer Azure region, place a key vault resource in that group. Upload the two certificates include in the same folder as this readme (if you do this post March 18, 2018, you'll need to create your own new certificates). Note the Azure Resource ID of the key vault once its been created and the URIs for both certificates. 

Create another resource group in which to place your service fabric cluster. An ARM template to define the cluster. A sample parameter file has been provided and since one of the parameters includes an object, its highly recommended you run the template from your preferred command line. Parameters are as follows:

clustername - 2 lower case, alphabetic characters. Provides a unique prefix for many of the resources. 
adminUserName - the administrative user to be used for all virtual machines
adminPassword - the administrative user password
frontEndLoadBalancedAppPort1, frontEndLoadBalancedAppPort2 - these are the ports for the application that will be deployed. leave per sample
VMSSSecrets - this is an object parameter that details the. Fill in the values for the key vault ID and certificate URLs

When deployed (correctly), this will create a 9 node cluster (20 cores in all), a jump box, and all the wiring to route connections on the front end and provide inbound network protections. Most important in these are the front end ip URL, and the management IP URL. 

With that in place, you can now open the visual studio project and publish the Service Fabric Application "Hackfest" to the cluster via its management IP URL. Once the application is deployed, you can conneect to the application front end via the front end IP address and port 8693. If you used the sample certificates I have provided, you'll get errors because they are self signed (hey, what did you expect from a certifcate you got off of GitHub).

The front end service uses the Service Fabric name resolution services to connect to the back end. I also exposes its endpoint on both a secure and non-secure port. This allows you to demonstrate both dynamic service discovery as well as using two inbound connection endpoints. This solution also allows you to demonstrate doing an upgrade of an application by changing the certificate thumbprint (provided below) so you can upgrade the application (by changing the version) to show the certificate has changed. 

Sample Certificates
    ThingOne: 59 df 28 92 07 a3 03 c6 94 ae 01 c0 e4 a8 4b 94 da b3 05 bc
    ThingTwo: 34 2f 78 96 5d 01 65 02 8a 2b ad f3 f2 ba 8c 4e 7e 95 85 2a\
password for **sample** self-signed certificates is: samplecertificate

Enjoy!