#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp/liste_odonimi
mkdir -p "${folder}"/../rawdata

# estrai codici regioni Istat
mlr --c2n cut -f IDREGIONE then uniq -a "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/lista_regioni.txt

# converti elenco comuni in jsonl
mlr --icsv --ojsonl cat "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/comuniANPR_ISTAT.jsonl

# crea un jsonl per ogni regione
cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  mlr --jsonl filter '$IDREGIONE=="'"$regione"'"' "${folder}"/tmp/comuniANPR_ISTAT.jsonl >"${folder}"/tmp/comuni_"${regione}".jsonl
  mkdir -p "${folder}"/../rawdata/"${regione}"
done

# crea file con tutti i comuni da scaricare
:>"${folder}"/tmp/download_list.txt
for lista_comuni in "${folder}"/tmp/comuni_*.jsonl; do
  cat "${lista_comuni}" | jq -r '. | [.IDREGIONE, .CODCATASTALE] | @tsv' >>"${folder}"/tmp/download_list.txt
done

# scarica in parallelo
cat "${folder}"/tmp/download_list.txt | parallel --colsep '\t' -j4 --bar '
  regione={1}
  codice_belfiore={2}
  folder="'"${folder}"'"
  
  if [ ! -f "${folder}"/../rawdata/"${regione}"/odonimi_${codice_belfiore}.json ]; then
    curl -sS -X GET "https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?resource=odonimi&codicecomune=$codice_belfiore&denominazione=%20%20%20" >"${folder}"/../rawdata/"${regione}"/odonimi_${codice_belfiore}.json

    # se il file è vuoto, cancella
    if [ ! -s "${folder}"/../rawdata/"${regione}"/odonimi_${codice_belfiore}.json ]; then
      rm "${folder}"/../rawdata/"${regione}"/odonimi_${codice_belfiore}.json
    fi
  fi
'
