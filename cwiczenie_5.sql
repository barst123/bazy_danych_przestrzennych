--zad1
CREATE TABLE obiekty(
id INT,
geom GEOMETRY,
nazwa VARCHAR(30)
);


INSERT INTO obiekty
VALUES
(1, ST_GeomFromEWKT('COMPOUNDCURVE( (0 1, 1 1), CIRCULARSTRING(1 1, 2 0, 3 1, 4 2, 5 1), (5 1, 6 1) )'), 'obiekt1'),
(2, ST_GeomFromEWKT('CURVEPOLYGON( COMPOUNDCURVE((10 2, 10 6, 14 6), CIRCULARSTRING(14 6, 16 4, 14 2, 12 0, 10 2)), CIRCULARSTRING(11 2, 13 2, 11 2))'), 'obiekt2'),
(3, ST_GeomFromEWKT('TRIANGLE( (7 15, 10 17, 12 13, 7 15) )'), 'obiekt3'),
(4, ST_GeomFromEWKT('MULTILINESTRING( (20 20, 25 25), (25 25, 27 24), (27 24, 25 22), (25 22, 26 21), (26 21, 22 19), (22 19, 20.5 19.5))'), 'obiekt4'),
(5, ST_GeomFromEWKT('MULTIPOINT( (30 30 59), (38 32 234) )'), 'obiekt5'),
(6, ST_GeomFromEWKT('GEOMETRYCOLLECTION( LINESTRING( 1 1, 3 2 ), POINT(4 2))'), 'obiekt6');


SELECT * FROM obiekty

--zad2
SELECT
	ST_Area(ST_Buffer(ST_ShortestLine(o1.geom, o2.geom), 5))
FROM
	obiekty o1,
	obiekty o2
WHERE
	o1.nazwa='obiekt3' AND o2.nazwa='obiekt4';

--zad3
UPDATE 
	obiekty
SET
	geom=ST_MakePolygon(ST_Union(geom, 'MULTILINESTRING((20.5 19.5, 20 20))'))
WHERE
	nazwa='obiekt4'


--zad4
INSERT INTO obiekty
VALUES
(7, 
 ST_Collect(
 	(SELECT geom FROM obiekty WHERE nazwa='obiekt3'),
	(SELECT geom FROM obiekty WHERE nazwa='obiekt4')
 ),
 'obiekt7');

--zad5
SELECT
	ST_Area(
		ST_Buffer(
			ST_Union(
				(SELECT geom FROM obiekty WHERE ST_HasArc(geom)=FALSE)
			),
			5
		)
	)
FROM
	obiekty;
	
SELECT
ST_Union(
				(SELECT geom FROM obiekty WHERE ST_HasArc(geom)=FALSE)
			)
FROM obiekty
 