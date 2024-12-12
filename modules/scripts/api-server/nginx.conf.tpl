events {
    worker_connections 1024;
}

http {

    server {
        listen 80;

        location / {
            proxy_pass http://backend-service;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
    }
}