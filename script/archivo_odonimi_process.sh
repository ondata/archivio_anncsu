#!/bin/bash

#set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp
mkdir -p "${folder}"/tmp/liste_odonimi
mkdir -p "${folder}"/../rawdata
mkdir -p "${folder}"/../output

# se "${folder}"/tmp.jsonl esiste cancellalo
if [ -f "${folder}"/tmp.jsonl ]; then
  rm "${folder}"/tmp.jsonl
fi

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

duckdb -c "COPY (SELECT CAST(Progressivo_nazionale AS BIGINT) AS Progressivo_nazionale,* EXCLUDE(Progressivo_nazionale) FROM read_json_auto('${folder}/../output/odonomi.jsonl') order by codice_regione,codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi.parquet' (FORMAT 'parquet', COMPRESSION 'zstd', ROW_GROUP_SIZE 100_000);"

duckdb -c "COPY (SELECT CAST(Progressivo_nazionale AS BIGINT) AS Progressivo_nazionale,* EXCLUDE(Progressivo_nazionale) FROM read_json_auto('${folder}/../output/odonomi.jsonl') order by codice_regione,codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi.csv.gz';"

# estrai codici regioni Istat
mlr --c2n cut -f IDREGIONE then uniq -a "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/lista_regioni.txt

cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  duckdb -c "COPY (select * from '${folder}/../output/odonimi.parquet' where codice_regione like '19'order by codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi_${regione}.parquet' (FORMAT 'parquet', COMPRESSION 'zstd', ROW_GROUP_SIZE 100_000);"
done

cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  duckdb -c "COPY (select * from '${folder}/../output/odonimi.parquet' where codice_regione like '19'order by codice_belfiore,Progressivo_nazionale)  to '${folder}/../output/odonimi_${regione}.csv.gz';"
done
