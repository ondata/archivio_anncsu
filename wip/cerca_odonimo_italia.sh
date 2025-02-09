#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

# estrai lista codici belfiore

curl -kL "https://dait.interno.gov.it/territorio-e-autonomie-locali/sut/elenco_codici_comuni.php" | scrape -be ".tdc:nth-child(6)" | xq -r '.html.body.td[]."#text"' >"${folder}"/tmp/codici_belfiore.txt

while read -r codice_belfiore; do
  curl -X GET "https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?resource=odonimi&codicecomune=${codice_belfiore}&denominazione=lago%20di%20Lesi" >"${folder}"/tmp/odonimi_${codice_belfiore}.json
  # se output contiene "non trovati odonimi" cancella file
  if grep -q "non trovati odonimi" "${folder}"/tmp/odonimi_${codice_belfiore}.json; then
    rm "${folder}"/tmp/odonimi_${codice_belfiore}.json
  fi
done <"${folder}"/tmp/codici_belfiore.txt

# se il file "${folder}"/lago_di_lesi.jsonl esiste cancellalo
if [ -f "${folder}"/lago_di_lesi.jsonl ]; then
  rm "${folder}"/lago_di_lesi.jsonl
fi

for file in "${folder}"/tmp/odonimi_*.json; do
  nome=$(basename "${file}" .json)
  jq -c '.result.records[] | . + {codice_belfiore: "'"$nome"'"}' "${file}" >>"${folder}"/lago_di_lesi.jsonl
done

mlr -I --jsonl put '$codice_belfiore=sub($codice_belfiore,"odonimi_","")' "${folder}"/lago_di_lesi.jsonl

mlr --ijsonl --ocsv cat "${folder}"/lago_di_lesi.jsonl >"${folder}"/lago_di_lesi.csv
