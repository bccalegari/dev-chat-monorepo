FROM kong:3.9.1

USER root

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/local/share/lua/5.1/resty

RUN curl -L https://raw.githubusercontent.com/cdbattags/lua-resty-jwt/master/lib/resty/jwt.lua -o /usr/local/share/lua/5.1/resty/jwt.lua

USER kong
