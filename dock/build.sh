
echo http_proxy:${http_proxy}
echo https_proxy:${https_proxy}

docker build --no-cache=true\
 --build-arg http_proxy=${http_proxy}\
 --build-arg https_proxy=${https_proxy}\
 -t emaki\
 .
