
# https://git.skewed.de/count0/graph-tool/-/wikis/installation-instructions

# https://git.skewed.de/count0/graph-tool/-/wikis/installation-instructions
# docker run -it -u user -w /home/user tiagopeixoto/graph-tool ipython

# xhost +local:

sudo docker run -p 8888:8888 -p 6006:6006 -it -u user -w /media/lnr-ai/christo/ tiagopeixoto/graph-tool bash
sudo docker run -p 8888:8888 -p 6006:6006 -it -u user -w /github_repos tiagopeixoto/graph-tool bash


sudo docker run -p 8888:8888 -p 6006:6006 -it -u user  tiagopeixoto/graph-tool bash
jupyter notebook --ip 0.0.0.0

sudo docker run -p 8888:8888 -p 6006:6006 -it -u user  -w /home/user -v my_data_volume:github_repos/graphing/data/ tiagopeixoto/graph-tool bash

# docker run --name=nginx -d -v ~/nginxlogs:/var/log/nginx -p 5000:80 nginx
# sudo docker run -p 8888:8888 -p 6006:6006 --name=nginx -it -u user  -w /home/user -v /media/lnr-ai/christo/github_repos/graphing:/home/user/graphing tiagopeixoto/graph-tool bash
sudo docker run -p 8888:8888 -p 6006:6006 -it -u user  -w /home/user -v /media/lnr-ai/christo/github_repos/graphing:/home/user/graphing tiagopeixoto/graph-tool bash
http://127.0.0.1:8888/?token=1d3e27294c1299bde4c92a0f9eb800c6507fc1badb6de549
