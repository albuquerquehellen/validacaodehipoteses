-- Criar resumo por artista: número de músicas e total de streams
WITH artist_summary AS (
  SELECT
    artist_name_limpo,
    COUNT(DISTINCT track_id) AS number_of_tracks,
    SUM(streams) AS streams
  FROM
    projeto-2-spotify-457006.Spotify.Dados_Otimizados
  GROUP BY
    artist_name_limpo
)

-- Calcular a correlação entre número de faixas e total de streams
SELECT
  CORR(number_of_tracks, streams) AS correlation
FROM
  artist_summary;
