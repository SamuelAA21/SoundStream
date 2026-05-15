FROM node:24-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm install

FROM deps AS build
COPY . .
RUN npm run prisma:generate && npm run build

FROM node:24-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY --from=build /app/storage ./storage
EXPOSE 3000
CMD ["node", "dist/src/server.js"]
