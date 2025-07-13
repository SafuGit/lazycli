# React.js Vite Dockerfile (AUTO-CREATED)
FROM node:20-alpine AS BUILDER

# STEP 1: BUILD
WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

# STEP 2: SERVE WITH ALPINE
FROM nginx:alpine

# Copy the built app to Nginx's default public folder
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose the port
EXPOSE 5173

# Start Nginx when container runs
CMD ["nginx", "-g", "daemon off;"]
