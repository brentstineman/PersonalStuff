# setup
# pull the following images
#    microsoft/nanoserver:latest
#    microsoft/dotnet:1.0.0-nanoserver-core
#
# run/start the following images
#    docker run microsoft/nanoserver cmd

##
### Slide 16
##

# show that docker is installed
docker version

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
docker rm 

# remove all containers
docker ps –a -–format “{{.ID}}” | %{docker rm $_ -f}

##
### Slide 21
##
# after creating project, build it
docker build -t 'bstineman/demos:devup-2016‘ .

# push it to docker hub
docker login
docker push 