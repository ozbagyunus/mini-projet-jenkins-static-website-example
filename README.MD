# Mini projet DevOps – Déploiement d’un site statique avec GitLab CI/CD et AWS

## Contexte
Ce projet a été réalisé dans le cadre d’un **bootcamp DevOps**.  
L’objectif était de mettre en place une **pipeline CI/CD complète avec GitLab**, en utilisant **Docker** et **AWS**, à partir d’un site web statique.

Le projet couvre tout le cycle :
- build de l’image Docker
- tests automatiques
- publication de l’image
- déploiement automatique sur AWS
- gestion d’environnements (review, staging, production)

---

## Objectifs du projet
- Comprendre le fonctionnement de **GitLab CI/CD**
- Utiliser **Docker** pour packager une application
- Mettre en place des **tests automatisés**
- Déployer automatiquement sur **AWS EC2**
- Gérer des **Review Apps** pour les Merge Requests
- Avoir une séparation claire entre **staging** et **production**

---

## Architecture générale

### Outils utilisés
- **GitLab CI/CD** : orchestration des pipelines
- **Docker** : conteneurisation du site statique
- **GitLab Container Registry** : stockage des images Docker
- **AWS EC2** : hébergement des environnements
- **SSH** : déploiement distant
- **AWS CLI** : création et suppression d’instances EC2

---

## Fonctionnement de la pipeline CI/CD

La pipeline est découpée en plusieurs **stages**, exécutés dans un ordre précis.

### 1. Build
- Construction de l’image Docker à partir du Dockerfile
- Sauvegarde de l’image dans un fichier `.tar`
- Ce fichier est partagé aux jobs suivants via les **artifacts**

### 2. Test d’acceptation
- L’image Docker est lancée dans le runner GitLab
- Un test HTTP vérifie que le site répond correctement
- Si le test échoue, la pipeline s’arrête

### 3. Release de l’image
- L’image est taguée avec :
  - le nom de la branche
  - le hash du commit
- L’image est poussée dans le **GitLab Container Registry**

---

## Review Apps (Merge Requests)

Lorsqu’une **Merge Request** est créée :

- Une instance **EC2 dédiée** est créée automatiquement sur AWS
- L’image Docker correspondant à la branche est déployée
- GitLab affiche une **URL de review** directement dans la MR
- Cela permet de tester la fonctionnalité avant le merge

### Arrêt de la Review App
- Un bouton **“Stop environment”** est disponible dans GitLab
- Il déclenche un job manuel qui **supprime l’EC2**
- Cela évite de laisser des ressources AWS inutiles

---

## Environnements Staging et Production

### Staging
- Déploiement automatique depuis la branche `master`
- Instance EC2 déjà existante
- Permet de valider avant la production

### Production
- Déploiement automatique depuis `master`
- Instance EC2 dédiée à la production
- Un test HTTP final vérifie que le site est bien accessible

---

## Tests
- Tests d’acceptation pendant la CI
- Tests HTTP simples après déploiement sur staging et prod
- Vérification que le contenu HTML est bien servi

---

## Sécurité
- Les clés AWS et SSH ne sont **jamais stockées dans le dépôt**
- Elles sont définies dans les **variables protégées GitLab**
- Les accès AWS sont limités au strict nécessaire

---

## Ce que m’a apporté ce projet
- Compréhension concrète d’une pipeline CI/CD
- Manipulation réelle d’AWS et de Docker
- Gestion d’environnements dynamiques (Review Apps)
- Débogage de pipelines et résolution de problèmes réels
- Vision globale du workflow DevOps, de la CI jusqu’à la prod


---

## Auteur
Projet réalisé dans le cadre d’un **bootcamp DevOps**,  
par un apprenant en phase de montée en compétences sur GitLab CI/CD, Docker et AWS.