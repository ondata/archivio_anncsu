Due script per l'acquisizione ed elaborazione dei dati:

1. `archivo_odonimi_download.sh`:
   - Scarica i dati odonomastici dalle API ANNCSU
   - Organizza i file scaricati per regione
   - Utilizza GNU Parallel per download parallelo
   - Richiede: curl, jq, mlr (Miller)

2. `archivo_odonimi_process.sh`:
   - Elabora i file JSON scaricati
   - Converte i dati in formato Parquet e CSV
   - Crea file separati per ogni regione
   - Richiede: duckdb, mlr (Miller), jq
