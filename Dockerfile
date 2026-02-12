#J'utilise Nginx car c'est léger et suffisant pour servir du statique
FROM nginx:1.27-alpine

# On supprime la page par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# On copie le site statique (index.html + assets/ + images/ + etc.)
COPY . /usr/share/nginx/html

# Le conteneur écoute sur le port 80
EXPOSE 80

# On démarre Nginx au premier plan
CMD ["nginx", "-g", "daemon off;"]
