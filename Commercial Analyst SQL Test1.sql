
/*1.	Calculate the eCPM per asset per country.
		eCPM is defined as effective cost per 1,000 impressions in the App
*/

With Other AS
(SELECT 
    country_code,
    store_address_id,
    asset_type,
    SUM(amount) AS total_amount
FROM 
    Other_revenue 
WHERE amount is not null
GROUP BY country_code, store_address_id, asset_type)

SELECT
	--o.store_address_id
	o.country_code
	,o.total_amount
	,o.asset_type
	,SUM(f.total_store_impressions) AS total_store_impressions
	,(o.total_amount / SUM(f.total_store_impressions)) * 1000 AS eCPM
FROM 
	other AS o
JOIN Store_facts AS f ON o.store_address_id = f.store_address_id
WHERE f.total_store_impressions is not null and f.total_store_impressions <> '0'
GROUP BY  o.country_code, o.total_amount, o.asset_type;

/*	2.	Calculate the best performing asset from a partner point of view.
		To evaluate an asset’s performance you can make use of all the variables you have
*/

WITH AllAssetData AS (
SELECT
	o.asset_type,
	SUM(o.amount) AS total_costs,
	SUM(f.total_store_impressions) AS total_impressions,
	SUM(f.orders_count) AS total_orders,
	SUM(f.new_orders_count) AS total_new_orders,
	(SUM(o.amount) / SUM(f.total_store_impressions)) * 1000 AS average_eCPM,
	SUM(CASE WHEN f.store_facts_date >= o.start_date THEN f.total_store_impressions ELSE 0 END) AS post_campaign_impressions,
	SUM(CASE WHEN f.store_facts_date >= o.start_date THEN f.new_orders_count ELSE 0 END) AS post_campaign_orders,
	SUM(CASE WHEN f.store_facts_date >= o.start_date and f.store_facts_date <= o.end_date THEN f.new_orders_count ELSE 0 END) AS in_campaign_orders,
	SUM(CASE WHEN f.store_facts_date >= o.start_date and f.store_facts_date <= o.end_date THEN f.total_store_impressions ELSE 0 END) AS in_campaign_impressions,
	AVG(o.amount) AS average_campaign_cost
FROM Other_revenue AS o
	JOIN Store_facts AS f
ON o.store_address_id = f.store_address_id
GROUP BY o.asset_type
						)
SELECT
	AllAssetData.asset_type,
	AllAssetData.total_costs,
	AllAssetData.average_campaign_cost,
	AllAssetData.total_orders,
	AllAssetData.total_impressions,
	AllAssetData.post_campaign_impressions,
	AllAssetData.post_campaign_orders,
	AllAssetData.average_eCPM,
	AllAssetData.in_campaign_orders,
	AllAssetData.in_campaign_impressions,
	(AllAssetData.total_costs * -3) + (AllAssetData.total_impressions * 1) + (AllAssetData.total_orders * 1) + (AllAssetData.post_campaign_impressions * 3) + (AllAssetData.post_campaign_orders * 3) + (AllAssetData.average_eCPM * 2) AS Final_Score
FROM AllAssetData
ORDER BY Final_Score DESC

/* To weight these factors according to their importance for a partner, I have assigned a weight to each metric and then multiply that weight by the value of the metric (starting from '-3' being the lowest metric which  
	is the total cost for each asset type, maximum being '3')
		WEIGHTS: -3 total_costs; 1 total_impressions; 1 total_orders; 3 post_activation_impressions; 3 post_campaign_orders; 2 average_eCPM 
*/


/*	3.	Make reasonable assumptions on the missing data.

I assume that data is missing in the Other_revenue.start_date and Other_revenue.end_date columns because the campaigns didn't start yet. Data on Other_revenue.position is tied to asset_type 'Positioning'
*/