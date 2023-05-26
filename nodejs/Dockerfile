FROM node:lts-bullseye-slim
WORKDIR /app 
# add `/app/node_modules/.bin` to $PATH
ENV PATH /app/node_modules/.bin:$PATH
RUN npm install -g pnpm
RUN pnpm create vite