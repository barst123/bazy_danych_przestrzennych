CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--Tworzenie rastrów z istniejących rastrów i interakcja z wektorami

--ST_Intersects
CREATE TABLE staron.intersects AS
SELECT a.rast, b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

--ST_Clip
CREATE TABLE staron.clip AS
SELECT ST_Clip(a.rast, b.geom, true), b.municipality
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality like 'PORTO';

--ST_Union
CREATE TABLE staron.union AS
SELECT ST_Union(ST_Clip(a.rast, b.geom, true))
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast);

--Tworzenie rastrów z wektorów (rastrowanie)

--ST_AsRaster
CREATE TABLE staron.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--ST_Union
DROP TABLE staron.porto_parishes; --> drop table porto_parishes first
CREATE TABLE staron.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1
)
SELECT st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-32767)) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--ST_Tile
DROP TABLE staron.porto_parishes; --> drop table porto_parishes first
CREATE TABLE staron.porto_parishes AS
WITH r AS (
SELECT rast FROM rasters.dem
LIMIT 1 )
SELECT st_tile(st_union(ST_AsRaster(a.geom,r.rast,'8BUI',a.id,-
32767)),128,128,true,-32767) AS rast
FROM vectors.porto_parishes AS a, r
WHERE a.municipality ilike 'porto';

--Konwertowanie rastrów na wektory (wektoryzowanie)

--ST_Intersection
create table staron.intersection as
SELECT
a.rid,(ST_Intersection(b.geom,a.rast)).geom,(ST_Intersection(b.geom,a.rast)
).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--ST_DumpAsPolygons
CREATE TABLE staron.dumppolygons AS
SELECT
a.rid,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).geom,(ST_DumpAsPolygons(ST_Clip(a.rast,b.geom))).val
FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--Analiza rastrów

--ST_Band
CREATE TABLE staron.landsat_nir AS
SELECT rid, ST_Band(rast,4) AS rast
FROM rasters.landsat8;

--ST_Clip
CREATE TABLE staron.paranhos_dem AS
SELECT a.rid,ST_Clip(a.rast, b.geom,true) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.parish ilike 'paranhos' and ST_Intersects(b.geom,a.rast);

--ST_Slope
CREATE TABLE staron.paranhos_slope AS
SELECT a.rid,ST_Slope(a.rast,1,'32BF','PERCENTAGE') as rast
FROM staron.paranhos_dem AS a;

--ST_Reclass
CREATE TABLE staron.paranhos_slope_reclass AS
SELECT a.rid,ST_Reclass(a.rast,1,']0-15]:1, (15-30]:2, (30-9999:3',
'32BF',0)
FROM staron.paranhos_slope AS a;

--ST_SummaryStats
SELECT st_summarystats(a.rast) AS stats
FROM staron.paranhos_dem AS a;


--ST_SummaryStats i ST_Union
SELECT st_summarystats(ST_Union(a.rast))
FROM staron.paranhos_dem AS a;

--ST_SummaryStats z lepsza kontrola zlozonego typu danych
WITH t AS (
SELECT st_summarystats(ST_Union(a.rast)) AS stats
FROM staron.paranhos_dem AS a
)
SELECT (stats).min,(stats).max,(stats).mean FROM t;

--ST_SummaryStats i GROUP BY
WITH t AS (
SELECT b.parish AS parish, st_summarystats(ST_Union(ST_Clip(a.rast,
b.geom,true))) AS stats
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
group by b.parish
)
SELECT parish,(stats).min,(stats).max,(stats).mean FROM t;

--ST_Value
SELECT b.name,st_value(a.rast,(ST_Dump(b.geom)).geom)
FROM
rasters.dem a, vectors.places AS b
WHERE ST_Intersects(a.rast,b.geom)
ORDER BY b.name;

--ST_TPI
drop table staron.tpi30;
create table staron.tpi30 as
select ST_TPI(a.rast,1) as rast
from rasters.dem a;

CREATE INDEX idx_tpi30_rast_gist ON staron.tpi30
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('staron'::name,
'tpi30'::name,'rast'::name);

--problem do rozwiazania
create table staron.tpi30_porto as
SELECT ST_TPI(a.rast,1) as rast
FROM rasters.dem AS a, vectors.porto_parishes AS b
WHERE ST_Intersects(a.rast, b.geom) AND b.municipality ilike 'porto';

CREATE INDEX idx_tpi30_porto_rast_gist ON staron.tpi30_porto
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('staron'::name,
'tpi30_porto'::name,'rast'::name);

--Algebra map

--NDVI
--wyrazenie
CREATE TABLE staron.porto_ndvi AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
		r.rast, 1,
		r.rast, 4,
		'([rast2.val] - [rast1.val]) / ([rast2.val] +[rast1.val])::float','32BF'
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi_rast_gist ON staron.porto_ndvi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('staron'::name,
'porto_ndvi'::name,'rast'::name);

--funkcja zwrotna
create or replace function staron.ndvi(
	value double precision [] [] [],
	pos integer [][],
	VARIADIC userargs text []
)
RETURNS double precision AS $$
BEGIN
RETURN (value [2][1][1] - value [1][1][1])/(value [2][1][1]+value[1][1][1]);
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE COST 1000;

CREATE TABLE staron.porto_ndvi2 AS
WITH r AS (
	SELECT a.rid,ST_Clip(a.rast, b.geom,true) AS rast
	FROM rasters.landsat8 AS a, vectors.porto_parishes AS b
	WHERE b.municipality ilike 'porto' and ST_Intersects(b.geom,a.rast)
)
SELECT
	r.rid,ST_MapAlgebra(
	r.rast, ARRAY[1,4],
	'staron.ndvi(double precision[], integer[],text[])'::regprocedure,
	'32BF'::text
) AS rast
FROM r;

CREATE INDEX idx_porto_ndvi2_rast_gist ON staron.porto_ndvi2
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('staron'::name,
'porto_ndvi2'::name,'rast'::name);

--Eksport danych

--qgis
--ST_AsTiff
SELECT ST_AsTiff(ST_Union(rast))
FROM staron.porto_ndvi;

--ST_AsGDALRaster
SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
FROM staron.porto_ndvi;

--Zapisywanie danych za pomoca duzego obiektu
CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE', 'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM staron.porto_ndvi;

--dlaczego nie ma dostepu?
SELECT lo_export(loid, 'C:\Users\bartoszstaron\Desktop\Studia\3_rok\5_semestr\bazy_danych_przestrzennych\bazy_danych_przestrzennych\myraster.tiff')
FROM tmp_out;

SELECT lo_unlink(loid)
FROM tmp_out;


