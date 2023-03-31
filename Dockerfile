# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
FROM node:18.15.0 as build-stage
WORKDIR /app
COPY package*.json /app/
RUN npm install
COPY . .
ARG configuration=production
RUN npm run build -- --output-path=./dist/out --configuration $configuration

# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
#FROM nginx:1.20
# need to use a special nginx image because openshift does not allow containers to run with root privileges
FROM nginxinc/nginx-unprivileged
#FROM nginx:stable

RUN groups
RUN whoami
#RUN ls -al
#RUN sudo apt-get update

# support running as arbitrary user which belogs to the root group

#RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx

#RUN chgrp -R 0 /var/cache/nginx /var/run /var/log/nginx && \
#    chmod -R g=u /var

#RUN chmod 777 /etc/nginx/nginx.conf && chmod 777 /var/run && chmod 777 /etc/nginx/conf.d/default.conf


# users are not allowed to listen on priviliged ports
#RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf
#RUN cat /etc/nginx/conf.d/default.conf

# comment user directive as master process is run as user in OpenShift anyhow
#RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
#RUN cat /etc/nginx/nginx.conf



#Copy ci-dashboard-dist
#COPY --from=build-stage /app/dist/out/ /usr/share/nginx/html

#### copy nginx conf
#USER root
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
RUN cat /etc/nginx/nginx.conf
RUN cat /etc/nginx/conf.d/default.conf

#### copy artifact build from the 'build environment'
#USER nginx
COPY --from=build-stage /app/dist/out/ /usr/share/nginx/html


#Copy default nginx configuration
#COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf

#RUN pwd

#COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
#COPY --from=build-stage /app/nginx-custom.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080:8080


CMD ["nginx", "-g", "daemon off;"]
