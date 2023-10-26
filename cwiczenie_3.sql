--1
SELECT * FROM t2018_kar_buildings

SELECT * FROM t2019_kar_buildings

CREATE TABLE odnowione_budynki AS
SELECT
	t2019.*
FROM
	t2019_kar_buildings t2019
INNER JOIN
	t2018_kar_buildings t2018
ON
	t2019.polygon_id=t2018.polygon_id
WHERE
	ST_Equals(t2019.geom, t2018.geom)=FALSE OR t2019.height!=t2018.height;

CREATE TABLE nowe_budynki AS
SELECT
	*
FROM
	t2019_kar_buildings t2019
WHERE
	NOT EXISTS (SELECT * FROM t2018_kar_buildings t2018 WHERE t2019.polygon_id=t2018.polygon_id);
	
CREATE TABLE zmienione_budynki AS
SELECT
	*
FROM
	odnowione_budynki
UNION ALL
SELECT
	*
FROM
	nowe_budynki;

SELECT * FROM zmienione_budynki;

--zad2
CREATE TABLE stare_punkty AS
SELECT DISTINCT
	t2018.*
FROM
	t2018_kar_poi_table t2018,
	zmienione_budynki zb
WHERE
	ST_Distance(t2018.geom, zb.geom)<500;
	
CREATE TABLE nowe_punkty AS
SELECT DISTINCT
	t2019.*
FROM
	t2019_kar_poi_table t2019,
	zmienione_budynki zb
WHERE
	ST_Distance(t2019.geom, zb.geom)<500;

SELECT
	n.type, COUNT(n.type)
FROM
	nowe_punkty n
WHERE
	NOT EXISTS(SELECT * FROM stare_punkty s WHERE s.poi_id=n.poi_id)
GROUP BY
	n.type;

--zad3
CREATE TABLE streets_reprojected AS
SELECT
	ST_Transform(ST_SetSRID(t2019.geom, 4326), 3068)
FROM
	t2019_kar_streets t2019;

SELECT
	*
FROM
	streets_reprojected;
	
SELECT 
	ST_SRID(st_transform) 
FROM 
	streets_reprojected;

--zad4
CREATE TABLE input_points(
	id VARCHAR(3),
	geom geometry
);

INSERT INTO input_points
VALUES
('P1', ST_GeomFromText('Point(8.36093 49.03174)', 4326)),
('P2', ST_GeomFromText('Point(8.39876 49.00644)', 4326));

--zad5
UPDATE 
	input_points
SET
	geom=ST_Transform(geom, 3068);
	
SELECT 
	ST_SRID(geom) 
FROM 
	input_points;

SELECT 
	ST_AsText(geom) 
FROM 
	input_points;

SELECT * FROM input_points

--zad6
SELECT
	*
FROM
	t2019_kar_street_node t2019
WHERE
	ST_Distance(
		ST_Transform(t2019.geom, 3068), 
		ST_MakeLine(
			(SELECT geom FROM input_points WHERE id='P1'), 
			(SELECT geom FROM input_points WHERE id='P2'))
	)<200;

--zad7 -poprawic
SELECT * FROM t2019_kar_poi_table

SELECT DISTINCT
	COUNT(t2019_p.geom)
FROM
	t2019_kar_poi_table t2019_p, 
	t2019_kar_land_use_a t2019_l
WHERE
	t2019_p.type='Sporting Goods Store' AND t2019_l.type LIKE 'Park%' AND ST_Distance(t2019_p.geom, t2019_l.geom)<300;


--zad8
CREATE TABLE t2019_kar_bridges AS
SELECT
	ST_Intersection(t2019_wl.geom, t2019_r.geom) AS geom
FROM
	t2019_kar_water_lines t2019_wl,
	t2019_kar_railways t2019_r
WHERE
	ST_Intersects(t2019_wl.geom, t2019_r.geom);
	
SELECT
	*
FROM
	t2019_kar_bridges;