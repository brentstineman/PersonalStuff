# setup
# pull the following images
#
# run/start the following images
#

##
### Slide 17
##

# list images in local repository
docker images

# get a docker image from docker hub
docker pull microsoft/sample-dotnet:latest

# remove a local image
docker rmi 

##
### Slide 18
##

# create and run an image
docker run microsoft/sample-dotnet:latest

# list containers
docker ps 

# list all containers (including those not running)
docker ps -a

# run an existing, stopped container (do from cmd prompt)
docker start -ia 

# stop a running container 
docker stop 

##
### Slide 19
##

# remove an existing container
docker rm <container>

# remove all containers
docker ps –a -–format “{{.ID}}” | %{docker rm $_ -f}
