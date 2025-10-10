# Use lightweight NGINX image
FROM nginx:alpine

# Copy production build to nginx html folder
COPY build/ /usr/share/nginx/html

# Expose port 80 for HTTP
EXPOSE 80

# Start NGINX
CMD ["nginx", "-g", "daemon off;"]

