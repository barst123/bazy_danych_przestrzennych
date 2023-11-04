--zad1
SELECT
	SUM(ST_Area(t.geom))
FROM
	trees t
WHERE
	t.vegdesc='Mixed Trees';
--zad2
SELECT
	*
FROM
	trees t
WHERE
	t.vegdesc='Mixed Trees';

SELECT
	*
FROM
	trees t
WHERE
	t.vegdesc='Deciduous';

SELECT
	*
FROM
	trees t
WHERE
	t.vegdesc='Evergreen';
--zad3
SELECT
	SUM(ST_Length(ST_Intersection(rail.geom, reg.geom)))
FROM
	railroads rail,
	regions reg
WHERE
	reg.name_2 LIKE 'Matanuska-Susitna';
--zad4
SELECT 
	AVG(a.elev)
FROM
	airports a
WHERE 
	a.use LIKE '%Military%';

SELECT 
	COUNT(*)
FROM
	airports a
WHERE 
	a.use LIKE '%Military%';
	
DELETE FROM
	airports a
WHERE 
	a.use LIKE '%Military%' AND a.elev>1400;
--jedno lotnisko (bylo 11, jest 10)
--zad5
CREATE TABLE bristolbay_buildings AS 
SELECT 
	p.*
FROM 
	popp p
WHERE 
	ST_Within(p.geom, (SELECT r.geom FROM regions r WHERE r.name_2 LIKE 'Bristol Bay')) AND p.f_codedesc LIKE 'Building';

SELECT
	COUNT(*)
FROM 
	bristolbay_buildings;
--zad6
SELECT 
	*
FROM 
	bristolbay_buildings b
WHERE 
	ST_Within(b.geom, ST_Buffer((SELECT ST_Union(r.geom) FROM rivers r), 100));

SELECT 
	COUNT(*)
FROM 
	bristolbay_buildings;
--zad 7
SELECT 
	COUNT(*)
FROM 
	majrivers m,
	railroads r
WHERE 
	ST_Intersects(m.geom, r.geom);
--zad 8
SELECT
	COUNT(*)
FROM 
	vertices;
--zad 9
SELECT
	ST_UNION(geom)
FROM 
	hotele_lokalizacja;
--zad 10
--przed simplify
SELECT 
	ST_Area(ST_Union(s.geom)), SUM(ST_Npoints(s.geom))
FROM 
	swamp s;
	
--po simplify
SELECT 
	ST_Area(ST_Union(s.geom)), SUM(ST_Npoints(s.geom))
FROM 
	simplified_swamp s;
