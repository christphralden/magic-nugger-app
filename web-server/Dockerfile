FROM node:20-alpine AS base
WORKDIR /magic-nugger
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
WORKDIR /magic-nugger
COPY --from=builder /magic-nugger/dist ./dist
COPY --from=builder /magic-nugger/db ./db
COPY --from=builder /magic-nugger/package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY entrypoint.sh /magic-nugger/entrypoint.sh
RUN chmod +x /magic-nugger/entrypoint.sh
USER node
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--", "/magic-nugger/entrypoint.sh"]
CMD ["node", "dist/index.js"]
