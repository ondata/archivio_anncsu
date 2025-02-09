#!/bin/bash

# Script per l'elaborazione dei dati odonomastici scaricati
# Requisiti:
# - DuckDB per elaborazione dati
# - Miller (mlr) per elaborazione CSV
# - jq per elaborazione JSON

# Configurazione ambiente
#set -x  # Debug: mostra comandi eseguiti (commentato)
set -e  # Exit on error
set -u  # Exit on undefined variables
set -o pipefail  # Exit on pipe failures

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea directory necessarie
mkdir -p "${folder}"/tmp  # File temporanei
mkdir -p "${folder}"/tmp/liste_odonimi  # Liste odonimi
mkdir -p "${folder}"/../rawdata  # Dati scaricati
mkdir -p "${folder}"/../output  # Dati elaborati

# Pulisci file temporaneo JSONL se esiste
if [ -f "${folder}"/tmp.jsonl ]; then
  rm "${folder}"/tmp.jsonl
fi

# Elabora ogni file JSON scaricato
find ../rawdata/ -type f | while read -r file; do
  nome=$(basename "${file}" .json)
  codice_belfiore=$(echo "${nome}" | cut -d'_' -f2)
  codice_regione=$(echo "${file}" | cut -d'/' -f3)

  if grep -q "non trovati\|alert" "${file}"; then
    echo "alert"
  else
    jq -c '.result.records[] | . + {codice_belfiore: "'"$codice_belfiore"'",codice_regione: "'"$codice_regione"'"}' "${file}" >>"${folder}"/tmp.jsonl
  fi

done

mv "${folder}"/tmp.jsonl "${folder}"/../output/odonomi.jsonl

# Converti JSONL in Parquet con DuckDB
duckdb -c "COPY (
  SELECT CAST(Progressivo_nazionale AS BIGINT) AS Progressivo_nazionale,
         * EXCLUDE(Progressivo_nazionale)
  FROM read_json_auto('${folder}/../output/odonomi.jsonl')
  ORDER BY codice_regione, codice_belfiore, Progressivo_nazionale
) TO '${folder}/../output/odonimi.parquet' (
  FORMAT 'parquet',
  COMPRESSION 'zstd',
  ROW_GROUP_SIZE 100_000
);"

# Converti JSONL in CSV compresso con DuckDB
duckdb -c "COPY (
  SELECT CAST(Progressivo_nazionale AS BIGINT) AS Progressivo_nazionale,
         * EXCLUDE(Progressivo_nazionale)
  FROM read_json_auto('${folder}/../output/odonomi.jsonl')
  ORDER BY codice_regione, codice_belfiore, Progressivo_nazionale
) TO '${folder}/../output/odonimi.csv.gz';"

# Estrai codici regione ISTAT univoci
mlr --c2n cut -f IDREGIONE then uniq -a "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/lista_regioni.txt

# Crea file Parquet separati per ogni regione
# Crea file CSV compressi separati per ogni regione
cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  duckdb -c "COPY (select * from '${folder}/../output/odonimi.parquet' where codice_regione like '19'order by codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi_${regione}.parquet' (FORMAT 'parquet', COMPRESSION 'zstd', ROW_GROUP_SIZE 100_000);"
done

cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  duckdb -c "COPY (select * from '${folder}/../output/odonimi.parquet' where codice_regione like '19'order by codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi_${regione}.csv.gz';"
done
