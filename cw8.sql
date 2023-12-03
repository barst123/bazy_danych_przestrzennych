--zad1
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--zad2
CREATE SCHEMA rasters;

SELECT 
	* 
FROM 
	rasters.uk_250k;

--zad3
CREATE TABLE 
	rasters.uk_zad3 
AS
	SELECT 
		ST_Union(uk.rast)
	FROM
		rasters.uk_250k uk;
--zad 4 i 5
SELECT 
	*
FROM
	public.national_parks;
--zad 6
CREATE TABLE
	rasters.uk_lake_district
AS
	SELECT
		ST_Clip(uk250.rast, uk_parks.geom, true) AS rast
	FROM
		rasters.uk_250k AS uk250,
		public.national_parks AS uk_parks
	WHERE
		ST_Intersects(uk250.rast, uk_parks.geom) AND uk_parks.id=1;

SELECT
	*
FROM
	rasters.uk_lake_district;
	
--zad7
CREATE INDEX 
	idx_uk_lake_district
ON 
	rasters.uk_lake_district
USING 
	gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('rasters'::name,
'uk_lake_district'::name,'rast'::name);

--gdal_translate -of ENVI -co COMPRESS=DEFLATE -co PREDICTOR=2 -co ZLEVEL=9 PG:"host=localhost port=5432 dbname=bdp_cw8 user=postgres password=postgres123 schema=rasters table=uk_lake_district mode=2" C:\Users\bartoszstaron\Desktop\Studia\3_rok\5_semestr\bazy_danych_przestrzennych\dane\cw8_dane\uk_lake_district_gt.GTiff

--zad8 i zad9
SELECT
	*
FROM 
	rasters.sentinel_03;
	
SELECT
	*
FROM
	rasters.sentinel_08;

SELECT ST_Srid(rast) FROM rasters.sentinel_08
SELECT ST_Srid(rast) FROM rasters.uk_lake_district
SELECT ST_Srid(geom) FROM public.national_parks

--zad10
DROP TABLE rasters.ndwi
CREATE TABLE 
	rasters.ndwi
AS
WITH r AS(
	SELECT
		ST_MapAlgebra(
			s3.rast, 
			s8.rast,
			'([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF'
		) AS rast
	FROM
		rasters.sentinel_03 AS s3,
		rasters.sentinel_08 AS s8
)
SELECT
		ST_Clip(r.rast, ST_Transform(uk_parks.geom, 3857), true) AS rast
	FROM
		r,
		public.national_parks AS uk_parks
	WHERE
		ST_Intersects(r.rast, ST_Transform(uk_parks.geom, 3857)) AND uk_parks.id=1;

CREATE INDEX idx_ndwi ON rasters.ndwi
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('rasters'::name,
'ndwi'::name,'rast'::name);