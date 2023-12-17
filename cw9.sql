CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

SELECT * FROM "Exports";

CREATE TABLE cw4
AS
	SELECT
		ST_Union(rast)
	FROM
		"Exports";

SELECT * FROM cw4;
