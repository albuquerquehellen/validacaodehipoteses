-- Criação de uma nova tabela com os resultados da consulta
CREATE OR REPLACE TABLE `projeto-2-spotify-457006.Spotify.resultado_correlacoes` AS

WITH correlation_data AS (
  -- Dados necessários para calcular as correlações
  SELECT
    streams,
    n_plataformas_playlists,
    n_plataformas_charts,
    CAST(bpm AS INT64) AS bpm,
    CAST(`danceability_%` AS INT64) AS danceability,
    CAST(`valence_%` AS INT64) AS valence,
    CAST(`energy_%` AS INT64) AS energy,
    CAST(`acousticness_%` AS INT64) AS acousticness,
    CAST(`instrumentalness_%` AS INT64) AS instrumentalness,
    CAST(`liveness_%` AS INT64) AS liveness,
    CAST(`speechiness_%` AS INT64) AS speechiness,
    in_spotify_charts,
    in_apple_charts,
    in_deezer_charts,
    in_shazam_charts
  FROM
    `projeto-2-spotify-457006.Spotify.Dados_Otimizados`
),
artist_summary AS (
  -- Resumo por artista (número de faixas e streams)
  SELECT
    artist_name_limpo,
    COUNT(DISTINCT track_id) AS number_of_tracks,
    SUM(streams) AS streams
  FROM
    `projeto-2-spotify-457006.Spotify.Dados_Otimizados`
  GROUP BY
    artist_name_limpo
)

-- Calcular todas as correlações e armazenar na tabela
SELECT
  -- Correlações entre streams e variáveis de plataforma
  CORR(streams, n_plataformas_playlists) AS correlation_streams_playlist,
  CORR(streams, n_plataformas_charts) AS correlation_streams_charts,
  CORR(streams, bpm) AS correlation_streams_bpm,
  CORR(streams, danceability) AS correlation_streams_danceability,
  CORR(streams, valence) AS correlation_streams_valence, 
  CORR(streams, energy) AS correlation_streams_energy, 
  CORR(streams, acousticness) AS correlation_streams_acousticness, 
  CORR(streams, instrumentalness) AS correlation_streams_instrumentalness,
  CORR(streams, liveness) AS correlation_streams_liveness,
  CORR(streams, speechiness) AS correlation_streams_speechiness,
  
  -- Correlações entre charts
  CORR(in_spotify_charts, in_apple_charts) AS correlation_charts_apple_spotify, 
  CORR(in_spotify_charts, in_deezer_charts) AS correlation_charts_deezer_spotify,  
  CORR(in_spotify_charts, in_shazam_charts) AS correlation_charts_shazam_spotify,
  
  -- Correlação entre o número de faixas e streams
  (SELECT CORR(number_of_tracks, streams) FROM artist_summary) AS correlation_tracks_streams
FROM
  correlation_data;