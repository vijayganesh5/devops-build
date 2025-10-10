# Use official lightweight Nginx image
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy pre-built React app files
COPY build/ .

# Expose port 80 for the container
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

