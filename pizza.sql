-- A. Pizza Metrics

-- 1. Combien de pizzas ont été commandées ? 14
SELECT 
    count(pizza_id)
FROM customer_orders

-- 2. Combien de commandes clients uniques ont été passées ? 5
Select count(distinct customer_id)
From customer_orders

-- 3. Combien de commandes réussies ont été livrées par chaque livreur ?

Select count(distinct order_id)
FROM runner_orders
where cancellation is NULL

-- 4. Combien de chaque type de pizza a été livré ?
SELECT
     pn.pizza_name, 
     COUNT(co.pizza_id) AS delivered_count
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
WHERE ro.cancellation IS NULL
GROUP BY pn.pizza_name

-- 5. Combien de pizzas végétariennes et Meatlovers ont été commandées par chaque client ?
SELECT
    pn.pizza_name,
    c.customer_id,
    count(c.order_id) as nb_commande
FROM customer_orders c
JOIN pizza_names pn ON pn.pizza_id=c.pizza_id
Group by pn.pizza_name,c.customer_id

-- 6. Quel est le nombre maximum de pizzas livrées en une seule commande ?

with nbpizza as(
SELECT 
    count(pizza_id) as nb_pizza,
    order_id
FROM customer_orders
group by order_id
)
Select max(nb_pizza) from nbpizza

-- 7. Pour chaque client, combien de pizzas livrées avaient au moins 1 modification et combien n’avaient aucune modification ?
SELECT
    c.customer_id,
    Sum(case 
            when c.exclusions IS NOT NULL AND c.exclusions != '' THEN 1
            when c.extras IS NOT NULL  AND c.extras != '' THEN 1
            else 0
        end
        ) as nb_change,
    Sum(
        CASE
            WHEN c.exclusions IS NULL OR c.exclusions = '' THEN 1
            WHEN c.extras IS NULL  OR c.extras = ''  THEN 1
            else 0
        end
    ) as no_change
FROM customer_orders c
JOIN runner_orders ro ON ro.order_id=c.order_id
where cancellation IS NULL 
GROUP BY customer_id

-- 8. Combien de pizzas livrées avaient à la fois des exclusions et des extras ?
SELECT
    count(pizza_id) as nb_pizza
FROM customer_orders c
JOIN runner_orders ro ON ro.order_id=c.order_id
where cancellation IS NULL AND
    c.exclusions IS NOT NULL AND c.exclusions != '' AND
    c.extras IS NOT NULL  AND c.extras != ''
 GROUP BY customer_id


-- 9. Volume total des pizzas commandées par heure

SELECT 
    DATEPART(HOUR, order_time) AS heure,
    COUNT(pizza_id) AS nombre_pizzas
FROM customer_orders
GROUP BY DATEPART(HOUR, order_time)
ORDER BY heure


-- 10. Volume des commandes pour chaque jour de la semaine
SELECT 
    DATEPART(day, order_time) AS jour,
    COUNT(pizza_id) AS nombre_pizzas
FROM customer_orders
GROUP BY DATEPART(day, order_time)
ORDER BY jour

-- B. Runner and Customer Experience

-- 11. Combien de livreurs se sont inscrits chaque semaine ?
Select 
    count(runner_id) as nb_runner,
    datepart(week,registration_date) as semaaine
FROM runners
group by datepart(week,registration_date)

-- 12. Temps moyen en minutes pour chaque livreur pour récupérer une commande
SELECT
    avg(datediff(MINUTE,co.order_time,ro.pickup_time)) as minute
FROM runner_orders ro
JOIN customer_orders co ON co.order_id=ro.order_id

-- 13. Relation entre le nombre de pizzas et le temps de préparation
SELECT
    count(co.pizza_id) as nb_pizaa,
    datediff(MINUTE,co.order_time,ro.pickup_time) as minute
FROM runner_orders ro
JOIN customer_orders co ON co.order_id=ro.order_id
group by datediff(MINUTE,co.order_time,ro.pickup_time)

-- 14. Distance moyenne parcourue par chaque client
SELECT 
    co.customer_id, 
    AVG(CAST(REPLACE(ro.distance, 'km', '') AS FLOAT)) AS avg_distance
FROM customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.distance IS NOT NULL
GROUP BY co.customer_id
-- 15. Différence entre le temps de livraison le plus long et le plus court

with clean_duration as(
SELECT 
    CASE 
        WHEN duration LIKE '%minutes%' THEN CAST(REPLACE(duration, 'minutes', '') AS FLOAT)
        WHEN duration LIKE '%mins%' THEN CAST(REPLACE(duration, 'mins', '') AS FLOAT)
        WHEN duration LIKE '%minute%' THEN CAST(REPLACE(duration, 'minute', '') AS FLOAT)
        ELSE duration 
    END AS duration_numeric,
    duration,
    order_id
FROM runner_orders)

Select max(duration_numeric)-min(duration_numeric) as diff_time
From clean_duration


-- 16. Vitesse moyenne pour chaque livreur
WITH clean_duration AS (
    SELECT 
        order_id,
        duration,
        CASE 
            WHEN duration LIKE '%minutes%' THEN CAST(REPLACE(duration, 'minutes', '') AS FLOAT)
            WHEN duration LIKE '%mins%' THEN CAST(REPLACE(duration, 'mins', '') AS FLOAT)
            WHEN duration LIKE '%minute%' THEN CAST(REPLACE(duration, 'minute', '') AS FLOAT)
            ELSE duration 
        END AS duration_numeric
    FROM runner_orders
)

SELECT 
    ro.runner_id,
    round(avg(CAST(REPLACE(ro.distance, 'km', '') AS FLOAT) / NULLIF(cd.duration_numeric, 0)),2) AS vitesse_km_h
FROM runner_orders ro
JOIN clean_duration cd ON cd.order_id = ro.order_id
group by ro.runner_id

-- 17. Pourcentage de livraisons réussies pour chaque livreur
SELECT
    runner_id,
    (COUNT(DISTINCT order_id) - SUM(CASE WHEN cancellation IS NOT NULL THEN 1 ELSE 0 END)) * 100.0 
    / COUNT(DISTINCT order_id) AS percent_reussi
FROM runner_orders
GROUP BY runner_id


-- 18. Schéma pour une table de notation
-- order_id foreign key
-- runner_id foreign key
-- customer_id foreign key
-- notation_id primary key
-- notation float

-- 19. Revenus totaux après paiement des livreurs (0.30$/km)
SELECT 
    sum(CAST(REPLACE(distance, 'km', '') AS FLOAT)) as distance_total,
    sum(CAST(REPLACE(distance, 'km', '') AS FLOAT))*0.30 as somme_total,
    runner_id
FROM runner_orders
group by runner_id
-- C. Ingredient Optimisation

-- 20. Quels sont les ingrédients standards pour chaque pizza ?

SELECT 
    pr.pizza_id,
   string_agg(pt.topping_name,',') as topping
FROM pizza_recipes pr
CROSS APPLY STRING_SPLIT(pr.toppings, ',') AS t 
JOIN pizza_toppings pt on CAST(t.value AS INT) = pt.topping_id
GROUP BY pr.pizza_id

--STRING_SPLIT()	Divise une chaîne en plusieurs valeurs
--CROSS APPLY	Applique une transformation sur chaque ligne
--CAST()	Convertit une valeur en un autre type de données
--STRING_AGG()	Concatène plusieurs valeurs en une seule chaîne

-- 21. Quel est le topping le plus souvent utilisé ?
SELECT top 1
    pt.topping_name,
   count(pt.topping_id) as extra
FROM pizza_recipes pr
CROSS APPLY STRING_SPLIT(pr.toppings, ',') AS t 
JOIN pizza_toppings pt on CAST(t.value AS INT) = pt.topping_id
GROUP BY pt.topping_name
order by extra desc 

-- 22. Quelle est l’exclusion la plus fréquente ?

SELECT 
    pt.topping_name, 
    COUNT(*) AS exclusion_count
FROM customer_orders co
CROSS APPLY STRING_SPLIT(co.exclusions, ',') AS exclu
JOIN pizza_toppings pt ON CAST(exclu.value AS INT) = pt.topping_id
WHERE co.exclusions IS NOT NULL
GROUP BY pt.topping_name
ORDER BY exclusion_count DESC;

