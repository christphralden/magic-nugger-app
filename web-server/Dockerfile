FROM node:20-alpine AS base
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM base AS dev
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]

FROM base AS builder
COPY . .
RUN npm run build

FROM node:20-alpine AS production
# dumb-init handles PID 1 signal forwarding properly
RUN apk add --no-cache dumb-init wget
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/db ./db
COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
USER node
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--", "/app/entrypoint.sh"]
CMD ["node", "dist/index.js"]
