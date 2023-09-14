#!/bin/bash

# Lê o conteúdo do arquivo default.js e define como uma variável de ambiente
export APP_CONFIG=$(cat default.js)

# Inicia o contêiner com o docker-compose
docker-compose up -d
# docker run -d -p 3000:80/tcp -e APP_CONFIG="$(cat default.js)" --name ohif-viewer-container ohif/app:v3.7.0-beta.62