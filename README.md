fursa terraform HW
the tasks are explaind in the pdf file on this repo


to run the homework :

terraform apply .


also we must make a docker image for our website using the command
docker build - < Dockerfile

and then transfer the docker image to the instance (we can use ssh to do that or ftp)

then run the docker image on port 5000 using the command

docker run -d -p 5000:5000 my_image

another way is to upload the docker image to docker hub and download it and run it
