SELECT
  DATE(PARSE_DATE('%Y%m%d', 
    FORMAT('%04d%02d%02d', released_year, released_month, released_day)
  )) AS data_lancamento
FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`