<a href="https://datibenecomune.substack.com/about"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

# Stradario e indirizzario dell'Archivio Nazionale dei Numeri Civici e delle Strade

Questo repository contiene l'archivio completo degli odonimi italiani - i "nomi delle strade" -  estratti dalle API dell'Archivio Nazionale dei Numeri Civici e delle Strade Urbane (ANNCSU), il 9 febbraio 2025.

I nomi delle strade raccontano la **storia** e le **scelte culturali**, **politiche**, **religiose** e **sociali** che hanno plasmato e plasmano le nostre città.

**Novità**: Dal giorno 11 febbraio 2025, [**grazie a quanto pubblicato da @ivandortenzio**](https://github.com/ivandorte/anncsu_dump), sono disponibili anche i dati relativi ai **numeri civici** delle strade italiane. La grandissima parte non ha coordinate associate.

URL utili:

- URL API https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?help_show
- mini tutorial con esempi di utilizzo <https://aborruso.github.io/posts/accesso_archivio_nazionale_numeri_civici_e_strade_urbane/>

**NOTA BENE**: l'ANNCSU non ha ancora pubblicato una nota di rilascio, quindi questo archivio potrebbe non essere completo o aggiornato.

## Dati disponibili

I dati sono disponibili nella cartella [`output`](output) e includono:

- [`STRAD_ITA_20250128.parquet`](output/STRAD_ITA_20250128.parquet): File Parquet con tutti gli odonimi italiani, scaricato in blocco come `CSV` e convertito in `Parquet`;
- [`INDIR_ITA_20250128.parquet`](output/INDIR_ITA_20250128.parquet): File Parquet con tutti i civici italiani, scaricato in blocco come `CSV` e convertito in `Parquet`;
- [`odonimi.parquet`](output/odonimi.parquet): File Parquet con tutti gli odonimi italiani, scaricato dalle API ANNCSU, ciclando per codice comunale;
- [`odonimi.csv.gz`](output/odonimi.csv.gz): File CSV compresso con tutti gli odonimi italiani.

## Se usi questi dati

I dati sono rilasciati con licenza [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.it), quindi sei libero di utilizzarli per qualsiasi scopo, a patto di **citare questa fonte**.

Quando li usi includi per favore la dicitura "dati estratti dall'[associazione onData](https://www.ondata.it/), a partire dalle [API dell'ANNCSU](https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?help_show)".
