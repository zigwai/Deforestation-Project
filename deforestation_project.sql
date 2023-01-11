CREATE  OR REPLACE VIEW forestation AS 
	SELECT (f.forest_area_sqkm/(l.total_area_sq_mi*2.59)*100) as forest_percent, f.country_code as country_code, f.year as year, f.country_name as country_name, (total_area_sq_mi*2.59) as total_area_sqkm, forest_area_sqkm, region, income_group
	FROM forest_area f
	JOIN land_area l 
	ON f.country_code = l.country_code AND f.year = l.year
	JOIN regions r 
	ON f.country_code = r.country_code;
	
SELECT region, year, SUM(total_area_sqkm) as tot, SUM(forest_area_sqkm) as suum, ((SUM(forest_area_sqkm)/SUM(total_area_sqkm))*100) as region_percent
FROM forestation
GROUP BY 1, 2
HAVING year = '1990'
ORDER BY region_percent DESC;

SELECT *
FROM forestation
WHERE year = '1990' AND region = 'World';

SELECT country_name, year, total_area_sqkm, forest_area_sqkm, ((forest_area_sqkm/total_area_sqkm)*100) as country_percent
FROM forestation
WHERE year = '1990' OR year = '2016'
ORDER BY country_percent DESC

SELECT country_name, year as sixyear, forest_area_sqkm as sixforest
FROM forestation 
WHERE year = '2016'
	
WITH t1 AS
	(SELECT country_name, region, forest_area_sqkm
	FROM forestation 
	WHERE year = '1990' 
	ORDER BY country_name),
t2 AS 
	(SELECT country_name, forest_area_sqkm
	FROM forestation 
	WHERE year = '2016' 
	ORDER BY country_name)
SELECT t1.country_name, t1.region, t1.forest_area_sqkm as forest_1, t2.forest_area_sqkm as forest_2, (t1.forest_area_sqkm-t2.forest_area_sqkm) as forest_diff
FROM t1
JOIN t2
ON t1.country_name = t2.country_name
ORDER BY forest_diff

WITH t1 AS
	(SELECT country_name, region, forest_area_sqkm, total_area_sqkm
	FROM forestation 
	WHERE year = '1990' 
	ORDER BY country_name),
t2 AS 
	(SELECT country_name, forest_area_sqkm
	FROM forestation 
	WHERE year = '2016' 
	ORDER BY country_name)
SELECT t1.country_name, t1.region, t1.forest_area_sqkm as forest_1, t2.forest_area_sqkm as forest_2, t1.total_area_sqkm as land, (((t1.forest_area_sqkm-t2.forest_area_sqkm)/t1.forest_area_sqkm)*100) as forest_percent
FROM t1
JOIN t2
ON t1.country_name = t2.country_name
ORDER BY forest_percent DESC;

WITH T1 AS
	(SELECT country_name, forest_percent,
	CASE
		WHEN forest_percent < 25 THEN '1st_quartile'
		WHEN forest_percent between 25 and 49 THEN '2nd_quartile'
		WHEN forest_percent between 50 and 74 THEN '3rd_quartile'
		WHEN forest_percent between 75 and 100 THEN '4th quartile'
		ELSE 'NULL'
	END AS quartile
	FROM forestation
	WHERE year = '2016' AND country_name NOT LIKE('World'))
SELECT COUNT(quartile) as num_percentile, quartile
FROM T1 
GROUP BY 2
ORDER BY 1;

SELECT * 
FROM forestation
WHERE forest_percent IS NOT NULL AND year = '2016'
ORDER BY forest_percent DESC;