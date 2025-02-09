#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp/liste_odonimi

# scarica codici belfiore
vd -f html +:table_0:: -b --save-filetype json -o - "https://dait.interno.gov.it/territorio-e-autonomie-locali/sut/elenco_codici_comuni.php" >"${folder}"/tmp/codici_belfiore.json

<"${folder}"/tmp/codici_belfiore.json jq -c '.[]' | mlr --jsonl filter '${CODICE ISTAT}=~"^08[1-9].+"' >"${folder}"/tmp/codici_belfiore_sicilia.txt

cat "${folder}"/tmp/codici_belfiore_sicilia.txt | while read -r codice_belfiore; do
  CODICE_BELFIORE=$(echo "${codice_belfiore}" | jq -r '."CODICE BELFIORE"')

  # se file esiste già, salta
  if [ ! -f "${folder}"/tmp/liste_odonimi/odonimi_${CODICE_BELFIORE}.json ]; then
    curl -X GET "https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?resource=odonimi&codicecomune=$CODICE_BELFIORE&denominazione=%20%20%20" >"${folder}"/tmp/liste_odonimi/odonimi_${CODICE_BELFIORE}.json

    # se il file è vuoto, cancella
    if [ ! -s "${folder}"/tmp/liste_odonimi/odonimi_${CODICE_BELFIORE}.json ]; then
      rm "${folder}"/tmp/liste_odonimi/odonimi_${CODICE_BELFIORE}.json
    fi
  fi
done

# se il file esiste cancellalo "${file}" >>../odonimi_sicilia.jsonl
if [ -f "${folder}"/odonimi_sicilia.jsonl ]; then
  rm "${folder}"/odonimi_sicilia.jsonl
fi

for file in "${folder}"/tmp/liste_odonimi/odonimi_*.json; do
  nome=$(basename "${file}" .json)

  # Se il file contiene "non trovati" o "alert", scrivi "alert"
  if grep -q "non trovati\|alert" "${file}"; then
    echo "alert"
  else
    jq -c '.result.records[] | . + {codice_belfiore: "'"$nome"'"}' "$file" >> "${folder}"/odonimi_sicilia.jsonl
  fi

done

mlr -I --jsonl put '$codice_belfiore=sub($codice_belfiore,"odonimi_","")'  "${folder}"/odonimi_sicilia.jsonl

mlr --ijsonl --ocsv cat  "${folder}"/odonimi_sicilia.jsonl > "${folder}"/odonimi_sicilia.csv

duckdb -c "copy (select * from read_csv_auto('${folder}/odonimi_sicilia.csv')) to '${folder}/odonimi_sicilia.parquet' (FORMAT 'parquet', COMPRESSION 'zstd', ROW_GROUP_SIZE 50_000);"

