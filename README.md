<a href="https://datibenecomune.substack.com/about"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

# Elenco degli Odonimi dell'Archivio Nazionale dei Numeri Civici e delle Strade

Questo repository contiene l'archivio completo degli odonimi italiani - dei "nomi delle strade" -  estratti dalle API dell'Archivio Nazionale dei Numeri Civici e delle Strade Urbane (ANNCSU) al 9 febbraio 2025.

URL utili:

- URL API https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?help_show
- mini tutorial con esempi di utilizzo <https://aborruso.github.io/posts/accesso_archivio_nazionale_numeri_civici_e_strade_urbane/>

**NOTA BENE**: l'ANNCSU non ha ancora pubblicato una nota di rilascio, quindi questo archivio potrebbe non essere completo o aggiornato.

## Dati disponibili

I dati sono disponibili nella cartella [`output`](output) e includono:

- [`odonimi.parquet`](output/odonimi.parquet): File Parquet con tutti gli odonimi italiani
- [`odonimi.csv.gz`](output/odonimi.csv.gz): File CSV compresso con tutti gli odonimi italiani
- `odonimi_XX.parquet`: File Parquet separati per ogni regione (XX = codice regione)
- `odonimi_XX.csv.gz`: File CSV compressi separati per ogni regione (XX = codice regione)

Ogni record contiene i campi originali delle API ANNCSU più due colonne aggiuntive:
- `codice_belfiore`: Codice catastale del comune (codice Belfiore)
- `codice_regione`: Codice ISTAT della regione

## Script di elaborazione

Nella cartella `script` sono presenti due script per l'acquisizione ed elaborazione dei dati:

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

## Se usi questi dati

I dati sono rilasciati con licenza [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.it), quindi sei libero di utilizzarli per qualsiasi scopo, a patto di **citare questa fonte**.

Quando li usi includi per favore la dicitura "dati estratti dall'[associazione onData](https://www.ondata.it/), a partire dalle [API dell'ANNCSU](https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?help_show)".
