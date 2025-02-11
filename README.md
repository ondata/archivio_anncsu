<a href="https://datibenecomune.substack.com/about"><img src="https://img.shields.io/badge/%F0%9F%99%8F-%23datiBeneComune-%23cc3232"/></a>

# Stradario e indirizzario dell'Archivio Nazionale dei Numeri Civici e delle Strade

Questo *repository* contiene l'archivio completo degli odonimi italiani - i "nomi delle strade" -  estratti dalle API dell'Archivio Nazionale dei Numeri Civici e delle Strade Urbane (ANNCSU), il 9 febbraio 2025.

Nella prima versione di questo *repository*, i dati sono stati estratti puntando alle API ufficiali.

Dal giorno 11 febbraio 2025, [**grazie a quanto pubblicato da @ivandortenzio**](https://github.com/ivandorte/anncsu_dump), abbiamo scoperto che sono disponibili anche i dati relativi ai **numeri civici** delle strade italiane. Tramite download in blocco.

E successivamente abbiamo visto che [**catalogo nazionale dei dati aperti**](https://www.dati.gov.it/view-dataset/dataset?id=c71b8aca-da9f-486a-bd22-9b532accf7df) sono presenti gli URL per scaricare in blocco tutti dati regionali e/o nazionali su odonimi e civici.


URL utili:

- URL API https://anncsu.open.agenziaentrate.gov.it/age-inspire/opendata/anncsu/querydata.php?help_show
- mini tutorial con esempi di utilizzo <https://aborruso.github.io/posts/accesso_archivio_nazionale_numeri_civici_e_strade_urbane/>


**NOTA BENE**: l'ANNCSU non ha ancora pubblicato una nota di rilascio.

## Dati disponibili

I dati sono disponibili nella cartella [`output`](output) e includono:

- [`STRAD_ITA_20250128.parquet`](output/STRAD_ITA_20250128.parquet): File Parquet con tutti gli odonimi italiani, scaricato in blocco come `CSV` e convertito in `Parquet`;
- [`INDIR_ITA_20250128.parquet`](output/INDIR_ITA_20250128.parquet): File Parquet con tutti i civici italiani, scaricato in blocco come `CSV` e convertito in `Parquet`;
- [`odonimi.parquet`](output/odonimi.parquet): File Parquet con tutti gli odonimi italiani, scaricato dalle API ANNCSU, ciclando per codice comunale;
- [`odonimi.csv.gz`](output/odonimi.csv.gz): File CSV compresso con tutti gli odonimi italiani.

Ma è caldamente consigliato di scaricare i dati direttamente dal [**catalogo nazionale dei dati aperti**](https://www.dati.gov.it/view-dataset/dataset?id=c71b8aca-da9f-486a-bd22-9b532accf7df).

### Note sui numeri civici

Il [`INDIR_ITA_20250128.parquet`](output/INDIR_ITA_20250128.parquet), scaricato giorno 11 febbraio 2025 ha diverse problematiche correlate ai numeri civici:

- la grandissima parte dei numeri civici **non ha coordinate associate**;
- ci sono tanti civici con le coordinate **pari a `0,0`**;
- ci sono tanti civici con coordinate **non in gradi decimali (come previsto da specifiche)**, ma in qualche sistema metrico.
