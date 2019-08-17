from ubuntu:latest
WORKDIR /code
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y build-essential python-dev
RUN apt-get install -y python3 python-distribute python3-pip
RUN apt-get install -y graphviz
RUN pip3 install pip --upgrade
ADD requirements.txt /code
RUN pip3 install -r requirements.txt
RUN mkdir /notebooks
CMD jupyter notebook --no-browser --ip 0.0.0.0 --port 8888 --allow-root /notebooks

#from jupyter/base-notebook

#run sudo apt-get install -y graphviz
#run pip install graphviz



