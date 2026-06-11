FROM node:20-alpine
RUN apk add --no-cache dumb-init wget
WORKDIR /app
COPY package*.json ./
COPY web-server/package*.json ./web-server/
COPY shared/package*.json ./shared/
RUN npm ci
COPY web-server/src ./web-server/src
COPY web-server/tsconfig.json ./web-server/tsconfig.json
COPY shared ./shared
COPY db ./db
COPY package.json ./
COPY web-server/entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
USER node
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--", "./entrypoint.sh"]
CMD ["node_modules/.bin/tsx", "web-server/src/index.ts"]
