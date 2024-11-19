FROM cgr.dev/chainguard/node:latest-dev AS build-stage

WORKDIR /app

COPY --chown=node:node package*.json /app/

RUN npm install

COPY --chown=node:node ./ /app/

ARG VITE_API_URL=${VITE_API_URL}

RUN npm run build


# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
FROM cgr.dev/chainguard/nginx:latest as runtime

COPY --from=build-stage /app/dist/ /usr/share/nginx/html

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx-backend-not-found.conf /etc/nginx/extra-conf.d/backend-not-found.conf
