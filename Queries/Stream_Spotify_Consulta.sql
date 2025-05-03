SELECT
  AVG(streams_limpo) AS media,
  MIN(streams_limpo) AS minimo,
  MAX(streams_limpo) AS maximo
FROM (SELECT 
SAFE_CAST(streams AS INT64) as streams_limpo
 FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`)
WHERE streams_limpo IS NOT NULL;