events {
    worker_connections 1024;
}

http {
    server_tokens off;
    
    server {
        listen 80;

        location / {
            proxy_pass http://backend-service;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        location /ws {
            proxy_pass http://backend-service;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            proxy_read_timeout 86400;  # 24 hours
            proxy_send_timeout 86400;  # 24 hours
        }
    }
}