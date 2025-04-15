# 🍕 Optimisation logistique et produit dans une pizzeria digitalisée- SQL

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
- Approfondir la **modélisation temporelle** dans SQL (temps de commande vs livraison) et les jointures
- Manipuler des fonctions avancées (`STRING_SPLIT`, `STRING_AGG`, `CASE`, `CAST`)e
- Travailler la **logique métier retail** et formuler des recommandations activables
- Traduire une base de données en **décisions stratégiques**
- Créer des analyses **actionnables** pour les métiers de la logistique, du retail ou de la restauration
- **Restituer la donnée** de façon claire, visuelle et compréhensible
- Travailler à la **croisée de la technique, de l’expérience client et de l’optimisation opérationnelle**

## Exemple de requetes

Volume de pizzas commandées par heure
```sql
SELECT 
    DATEPART(HOUR, order_time) AS heure,
    COUNT(pizza_id) AS nombre_pizzas
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time)
ORDER BY heure;
```
Temps moyen de préparation d’une commande
```sql
SELECT
    ro.runner_id,
    AVG(DATEDIFF(MINUTE, co.order_time, ro.pickup_time)) AS temps_preparation_moyen
FROM runner_orders ro
JOIN customer_orders co ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY ro.runner_id;
```

Vitesse moyenne de livraison par livreur (km/h)
```sql
WITH clean_duration AS (
    SELECT 
        order_id,
        CASE 
            WHEN duration LIKE '%minutes%' THEN CAST(REPLACE(duration, 'minutes', '') AS FLOAT)
            WHEN duration LIKE '%mins%' THEN CAST(REPLACE(duration, 'mins', '') AS FLOAT)
            WHEN duration LIKE '%minute%' THEN CAST(REPLACE(duration, 'minute', '') AS FLOAT)
            ELSE NULL 
        END AS duration_numeric
    FROM runner_orders
)

SELECT 
    ro.runner_id,
    ROUND(AVG(CAST(REPLACE(ro.distance, 'km', '') AS FLOAT) / NULLIF(cd.duration_numeric, 0)), 2) AS vitesse_km_h
FROM runner_orders ro
JOIN clean_duration cd ON ro.order_id = cd.order_id
WHERE ro.distance IS NOT NULL AND cd.duration_numeric IS NOT NULL
GROUP BY ro.runner_id;
```

Évolution quotidienne du volume de commandes
```sql
SELECT 
    CAST(order_time AS DATE) AS date_commande,
    COUNT(order_id) AS nb_commandes
FROM customer_orders
GROUP BY CAST(order_time AS DATE)
ORDER BY date_commande;
```

 Nombre de pizzas livrées avec exclusions ou extras par client
```sql
SELECT
    co.customer_id,
    SUM(CASE 
            WHEN (co.exclusions IS NOT NULL AND co.exclusions != '') OR
                 (co.extras IS NOT NULL AND co.extras != '') 
            THEN 1 ELSE 0 
        END) AS pizzas_personnalisees,
    SUM(CASE 
            WHEN (co.exclusions IS NULL OR co.exclusions = '') AND
                 (co.extras IS NULL OR co.extras = '') 
            THEN 1 ELSE 0 
        END) AS pizzas_standard
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;
```
