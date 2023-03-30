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

#Copy ci-dashboard-dist
#COPY --from=build-stage /app/dist/out/ /usr/share/nginx/html

#### copy nginx conf
COPY nginx-custom.conf /etc/nginx/conf.d/default.conf

#### copy artifact build from the 'build environment'
COPY --from=build-stage ./dist/hello-world /usr/share/nginx/html


#Copy default nginx configuration
#COPY ./nginx-custom.conf /etc/nginx/conf.d/default.conf

#RUN pwd

#COPY nginx-custom.conf /etc/nginx/conf.d/default.conf
#COPY --from=build-stage /app/nginx-custom.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080:8080
CMD ["nginx", "-g", "daemon off;"]
