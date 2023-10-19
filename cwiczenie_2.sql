--zad4
CREATE TABLE tableB AS
SELECT
	p.gid, p.cat, p.f_codedesc, p.f_code, p.type, p.geom
FROM 
	popp p,
	majrivers r
WHERE
	p.f_codedesc='Building' AND ST_Distance(p.geom, r.geom)<1000;

SELECT
	COUNT (*) AS "Liczba budynkow"
FROM
	tableB;
	
--zad5
CREATE TABLE airportsNew AS
SELECT
	a.name, a.elev, a.geom
FROM
	airports a;
--a	
--zachod
SELECT 
	geom 
FROM 
	airportsNew
ORDER BY
	ST_Y(geom)
LIMIT 1;
--wschod
SELECT 
	*
FROM 
	airportsNew
ORDER BY
	ST_Y(geom) DESC
LIMIT 1;
--b
INSERT INTO
	airportsNew
VALUES
	('airportB', 45, 
	 (SELECT ST_Centroid(ST_MakeLine(
		 (SELECT geom FROM airportsNew ORDER BY ST_Y(geom) DESC LIMIT 1), 
		 (SELECT geom FROM airportsNew ORDER BY ST_Y(geom) LIMIT 1)
	 ))));
	 
--zad6
SELECT
	ST_Area(ST_Buffer(ST_ShortestLine(a.geom, l.geom), 1000))
FROM
	lakes l, airports a
WHERE
	a.name='AMBLER' AND l.names='Iliamna Lake';
	
--zad7
SELECT
	ST_AsText(geom)
FROM
	swamp s

SELECT
	*
FROM
	tundra t
	
SELECT
	*
FROM
	trees t

SELECT
	tr.vegdesc, ST_Area(ST_Intersection(tr.geom, ST_Union(tu.geom, s.geom))) AS "Pole powierzchni"
FROM
	swamp s,
	tundra tu,
	trees tr
GROUP BY
	tr.vegdesc;

SELECT
	ST_AsText(ST_Union(tu.geom, s.geom)) AS "Pole powierzchni"
FROM
	swamp s,
	tundra tu,
	trees tr

SELECT
	ST_AsText(ST_Intersection(tr.geom, ST_Union(tu.geom, s.geom))) AS "Pole powierzchni"
FROM
	swamp s,
	tundra tu,
	trees tr
GROUP BY
	tr.vegdesc;
