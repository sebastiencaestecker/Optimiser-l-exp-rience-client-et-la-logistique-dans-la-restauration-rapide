# 🍕 Optimisation logistique et produit dans une pizzeria digitalisée

## Secteur ciblé : Retail / Restauration rapide / Logistique du dernier kilomètre

---

##  Problématique
**Comment améliorer l’efficacité des livraisons, la satisfaction client, et la rentabilité des menus dans un modèle de restauration rapide digitalisée ?**

Dans un contexte où la restauration rapide repose de plus en plus sur la livraison à domicile, les chaînes de pizzas font face à un triple enjeu :
- assurer une **livraison rapide et fiable**,
- **personnaliser les recettes** sans complexifier la préparation,
- **maximiser la rentabilité** de chaque commande.



##  But du projet
- Analyser les données clients, livreurs et recettes pour identifier les **points de friction** dans la chaîne de valeur.
- Comprendre les comportements d’achat et les préférences clients.
- Mesurer l’impact des personnalisations sur le temps de livraison.
- Proposer des **recommandations opérationnelles** exploitables par un manager retail/logistique.



## Méthodologie

Ce projet repose sur l'analyse d’un dataset simulant l’activité d’une pizzeria en ligne, avec des tables SQL représentant les :
- commandes clients
- livreurs et leurs performances
- recettes et ingrédients

###  1. Analyse commerciale
- Volume de pizzas par jour/heure
- Préférences clients (Meatlovers, Végétarienne, etc.)
- Commandes modifiées vs standard

###  2. Analyse logistique
- Taux de livraisons réussies vs annulées
- Temps et vitesse moyenne de livraison
- Estimation du coût de livraison (0.30 $/km)

###  3. Optimisation des recettes
- Toppings les plus populaires
- Ingrédients les plus souvent exclus
- Recettes complexes → pistes de simplification


##  Résultats Obtenus

- **64 %** des pizzas livrées sont modifiées (exclusions ou extras) → complexité accrue
- Temps de livraison **+30 %** pour les commandes personnalisées
- Les pizzas végétariennes sont les plus personnalisées
- Forte disparité entre livreurs : vitesse moyenne de **10 à 20 km/h**
- Taux de livraison réussie global : **87 %**


## Recommandations métier

- Réduire la carte aux recettes les plus commandées avec le moins de modifications
- Simplifier la personnalisation via des combinaisons prédéfinies
- Former les livreurs les plus lents ou les affecter en heures creuses
- Optimiser les achats d’ingrédients en fonction des exclusions fréquentes
- Proposer un bonus logistique basé sur performance (vitesse, distance)


##  Intentions d’apprentissage

Ce projet m’a permis de :
- Approfondir la **modélisation temporelle** dans SQL (temps de commande vs livraison)
- Manipuler des fonctions avancées (`STRING_SPLIT`, `STRING_AGG`, `CASE`, `CAST`)e
- Travailler la **logique métier retail** et formuler des recommandations activables
- Traduire une base de données en **décisions stratégiques**
- Créer des analyses **actionnables** pour les métiers de la logistique, du retail ou de la restauration
- **Restituer la donnée** de façon claire, visuelle et compréhensible
- Travailler à la **croisée de la technique, de l’expérience client et de l’optimisation opérationnelle**


