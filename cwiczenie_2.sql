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
--chyba zly wynik
SELECT
	tr.vegdesc, SUM(ST_Area(tr.geom))
FROM
	trees tr,
	tundra tu,
	swamp s
WHERE
	ST_Intersects(tr.geom, s.geom) OR ST_Intersects(tr.geom, tu.geom)
GROUP BY
	tr.vegdesc;
--oszukana wersja (shp z qgis)
SELECT
	tr.vegdesc, SUM(ST_Area(ST_Intersection(tr.geom, cts.geom)))
FROM
	trees tr,
	cw2_tundra_swamp cts
GROUP BY
	tr.vegdesc;
--jak to przyspieszyć
SET work_mem='32MB';
SHOW work_mem;
SELECT
	tr.vegdesc, SUM(ST_Area(ST_Intersection(tr.geom, ST_Union(tu.geom, s.geom))))
FROM
	trees tr,
	tundra tu,
	swamp s
GROUP BY
	tr.vegdesc;
RESET work_mem;
SHOW work_mem;
