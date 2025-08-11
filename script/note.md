# Varie

## Lavorazione CSV ufficiale odonimi

```
INSTALL spatial;
LOAD spatial;

COPY (
  SELECT
    *,
    ST_Point(COORD_X_COMUNE, COORD_Y_COMUNE) AS geometry
  FROM read_csv(
    'INDIR_ITA_20250804.csv',
    types = {
      'CODICE_COMUNALE_ACCESSO': 'VARCHAR'
    },
    decimal_separator = ',',
    sample_size = -1
  )
) TO 'output_from_csv.geoparquet'
(
  FORMAT 'PARQUET',
  CODEC 'ZSTD'
);
```
