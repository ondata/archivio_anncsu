#!/bin/bash

# Script per il download dei dati odonomastici da API ANPR
# Requisiti:
# - GNU Parallel per download parallelo
# - Miller (mlr) per elaborazione CSV/JSON
# - jq per elaborazione JSON
# - curl per richieste HTTP

# Configurazione ambiente
# set -x  # Debug: mostra comandi eseguiti (commentato)
set -e  # Exit on error
set -u  # Exit on undefined variables
set -o pipefail  # Exit on pipe failures

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea directory necessarie
mkdir -p "${folder}"/tmp  # File temporanei
mkdir -p "${folder}"/tmp/liste_odonimi  # Liste odonimi
mkdir -p "${folder}"/../rawdata  # Dati scaricati

# Estrai codici regione ISTAT univoci
mlr --c2n cut -f IDREGIONE then uniq -a "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/lista_regioni.txt

# Converti elenco comuni da CSV a JSONL per elaborazione
mlr --icsv --ojsonl cat "${folder}"/../risorse/comuniANPR_ISTAT.csv >"${folder}"/tmp/comuniANPR_ISTAT.jsonl

# Crea file JSONL separati per ogni regione
cat "${folder}"/tmp/lista_regioni.txt | while read -r regione; do
  mlr --jsonl filter '$IDREGIONE=="'"$regione"'"' "${folder}"/tmp/comuniANPR_ISTAT.jsonl >"${folder}"/tmp/comuni_"${regione}".jsonl
  mkdir -p "${folder}"/../rawdata/"${regione}"
done

# Crea lista unica di tutti i comuni da scaricare
:>"${folder}"/tmp/download_list.txt
for lista_comuni in "${folder}"/tmp/comuni_*.jsonl; do
  cat "${lista_comuni}" | jq -r '. | [.IDREGIONE, .CODCATASTALE] | @tsv' >>"${folder}"/tmp/download_list.txt
done

# Esegui download parallelo (4 connessioni simultanee)
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
