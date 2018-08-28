#Get the latest armv7 base image from
#https://registry.hub.docker.com/u/resin/armv7hf-debian/

# base image
#============
# for deployment to RPi2 via Resin.io
FROM resin/armv7hf-debian:latest

ENV READTHEDOCS True
# install python3
#================
RUN apt-get update && apt-get install -yq --no-install-recommends \
		python3 \
		python3-dev \
		python3-dbus \
		build-essential \
		curl \
		redis-server \
	&& rm -rf /var/lib/apt/lists/*

# create venv
#===================================
# --without-pip and curl necessary because somee Debian/Ubuntu versions
# run broken versions of Python - http://askubuntu.com/questions/488529/
RUN python3 -m venv --without-pip venv \
  && curl --insecure https://bootstrap.pypa.io/get-pip.py | /venv/bin/python

# copy our python source into container
#======================================
COPY src/ /app

RUN apt-get update
RUN apt-get install python3-pip
RUN python3 -m pip install --upgrade pip setuptools wheel
RUN apt-get install git
RUN git clone https://github.com/adafruit/Adafruit_Python_DHT.git
RUN sudo python3 Adafruit_Python_DHT/setup.py install --force-pi
#RUN pip3 install Adafruit_DHT --force-pi 

# install dependencies
#===================
RUN /venv/bin/pip install -r /app/requirements.txt

#run the app when the container starts
#======================================s
CMD ["/venv/bin/honcho", "-f", "/app/Procfile", "start"]

EXPOSE 80
