-- 1) VIEW: variáveis derivadas completas
CREATE OR REPLACE VIEW projeto-2-spotify-457006.Spotify.view_dados_otimizados AS

WITH 
-- passo 1: limpeza de caracteres e tipo
spotify_clean AS (
  SELECT
    track_id,
    REGEXP_REPLACE(track_name, r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS track_name_limpo,
    REGEXP_REPLACE(artist_s__name, r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS artist_name_limpo,
    SAFE_CAST(streams AS INT64) AS streams,
    in_spotify_playlists,
    in_spotify_charts,
    released_year, released_month, released_day,
    artist_count
  FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`
),

-- passo 2: deduplicação (soma streams e flags divergentes)
spotify_dedup AS (
  SELECT
    track_name_limpo,
    artist_name_limpo,
    MIN(track_id)             AS track_id,
    MAX(artist_count)         AS artist_count,
    MIN(released_year)        AS released_year,
    MIN(released_month)       AS released_month,
    MIN(released_day)         AS released_day,
    SUM(streams)              AS streams,
    MAX(in_spotify_playlists) AS in_spotify_playlists,
    MAX(in_spotify_charts)    AS in_spotify_charts
  FROM spotify_clean
  GROUP BY track_name_limpo, artist_name_limpo
),

-- passo 3: junta dados de competição e técnicos
dados_combinados AS (
  SELECT
    d.track_id,
    d.track_name_limpo,
    d.artist_name_limpo,
    d.streams,
    d.in_spotify_playlists,
    d.in_spotify_charts,
    COALESCE(c.in_apple_playlists, 0)  AS in_apple_playlists,
    COALESCE(c.in_apple_charts, 0)     AS in_apple_charts,
    COALESCE(c.in_deezer_playlists, 0) AS in_deezer_playlists,
    COALESCE(c.in_deezer_charts, 0)    AS in_deezer_charts,
    COALESCE(c.in_shazam_charts, 0)    AS in_shazam_charts,
     t.`bpm`,
     t.`key`,
     t.`mode`,
     t.`danceability_%`,
     t.`valence_%`,
     t.`energy_%`,
     t.`acousticness_%`,
     t.`instrumentalness_%`,
     t.`liveness_%`,
     t.`speechiness_%`,
    DATE(PARSE_DATE('%Y%m%d', FORMAT('%04d%02d%02d', 
      d.released_year, d.released_month, d.released_day
    ))) AS data_lancamento
  FROM spotify_dedup d
  LEFT JOIN `projeto-2-spotify-457006.Spotify.Competição` c USING(track_id)
  LEFT JOIN `projeto-2-spotify-457006.Spotify.Informações Técnicas` t USING(track_id)
),

-- passo 4: calcula limites de quantis para cada métrica técnica
quantis_tecnicos AS (
  SELECT
    APPROX_QUANTILES(bpm, 3)[OFFSET(1)]          AS q1_bpm,
    APPROX_QUANTILES(bpm, 3)[OFFSET(2)]          AS q2_bpm,
    APPROX_QUANTILES(`danceability_%`, 3)[OFFSET(1)] AS q1_dance,
    APPROX_QUANTILES(`danceability_%`, 3)[OFFSET(2)] AS q2_dance,
    APPROX_QUANTILES(`valence_%`, 3)[OFFSET(1)]     AS q1_valence,
    APPROX_QUANTILES(`valence_%`, 3)[OFFSET(2)]     AS q2_valence,
    APPROX_QUANTILES(`energy_%`, 3)[OFFSET(1)]      AS q1_energy,
    APPROX_QUANTILES(`energy_%`, 3)[OFFSET(2)]      AS q2_energy,
    APPROX_QUANTILES(`acousticness_%`, 3)[OFFSET(1)] AS q1_acoustic,
    APPROX_QUANTILES(`acousticness_%`, 3)[OFFSET(2)] AS q2_acoustic,
    APPROX_QUANTILES(`instrumentalness_%`, 3)[OFFSET(1)] AS q1_instr,
    APPROX_QUANTILES(`instrumentalness_%`, 3)[OFFSET(2)] AS q2_instr,
    APPROX_QUANTILES(`liveness_%`, 3)[OFFSET(1)]   AS q1_live,
    APPROX_QUANTILES(`liveness_%`, 3)[OFFSET(2)]   AS q2_live,
    APPROX_QUANTILES(`speechiness_%`, 3)[OFFSET(1)] AS q1_speech,
    APPROX_QUANTILES(`speechiness_%`, 3)[OFFSET(2)] AS q2_speech,
    APPROX_QUANTILES(streams, 3)[OFFSET(1)] AS q1_streams,
    APPROX_QUANTILES(streams, 3)[OFFSET(2)] AS q2_streams,
    APPROX_QUANTILES(in_spotify_playlists + in_apple_playlists + in_deezer_playlists, 3)[OFFSET(1)] AS q1_playlists,
    APPROX_QUANTILES(in_spotify_playlists + in_apple_playlists + in_deezer_playlists, 3)[OFFSET(2)] AS q2_playlists,
    APPROX_QUANTILES(in_spotify_charts + in_apple_charts + in_deezer_charts + in_shazam_charts, 3)[OFFSET(1)] AS q1_charts,
    APPROX_QUANTILES(in_spotify_charts + in_apple_charts + in_deezer_charts + in_shazam_charts, 3)[OFFSET(2)] AS q2_charts
  FROM dados_combinados
),

-- passo 5: monta o resultado final com todas as variáveis
final AS (
  SELECT
    d.track_id,
    d.track_name_limpo,
    d.artist_name_limpo,
    d.streams,
    d.in_spotify_playlists,
    d.in_spotify_charts,
    d.in_apple_playlists,
    d.in_apple_charts,
    d.in_deezer_playlists,
    d.in_deezer_charts,
    d.in_shazam_charts,
    d.in_spotify_charts + d.in_apple_charts + d.in_deezer_charts + d.in_shazam_charts AS n_plataformas_charts,
    d.in_apple_playlists + d.in_deezer_playlists + d.in_spotify_playlists AS n_plataformas_playlists,
    d.data_lancamento,
    FORMAT_DATE('%Y-%m', d.data_lancamento)      AS mes_ano_lancamento,
    DATE_DIFF(CURRENT_DATE(), d.data_lancamento, DAY) AS tempo_desde_lancamento,
   CASE
     WHEN d.data_lancamento IS NULL THEN 'No Data'
     WHEN EXTRACT(YEAR FROM d.data_lancamento) < 2023 THEN 'Antes de 2023'
     WHEN EXTRACT(MONTH FROM d.data_lancamento) BETWEEN 1 AND 6 THEN 'Consolidado no Ano'
     WHEN EXTRACT(MONTH FROM d.data_lancamento) BETWEEN 7 AND 9 THEN 'Recente'
     WHEN EXTRACT(MONTH FROM d.data_lancamento) BETWEEN 10 AND 12 THEN 'Muito Recente'
   END AS categoria_lancamento,
       CASE 
      WHEN d.data_lancamento IS NULL THEN 'No Data'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) < 1970 THEN 'Antes de 70'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 1970 AND 1979 THEN '70s'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 1980 AND 1989 THEN '80s'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 1990 AND 1999 THEN '90s'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 2000 AND 2009 THEN '2000s'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 2010 AND 2019 THEN '2010s'
      WHEN EXTRACT(YEAR FROM d.data_lancamento) BETWEEN 2020 AND 2023 THEN '2020s'
      ELSE 'Futuro?'
    END AS decada_lancamento,
     d.`bpm`,
     d.`key`,
     d.`mode`,
     d.`danceability_%`,
     d.`valence_%`,
     d.`energy_%`,
     d.`acousticness_%`,
     d.`instrumentalness_%`,
     d.`liveness_%`,
     d.`speechiness_%`,
     CASE WHEN d.bpm <= q.q1_bpm       THEN 'Baixa'
         WHEN d.bpm <= q.q2_bpm       THEN 'Média'
         ELSE 'Alta' END              AS nivel_bpm,
    CASE WHEN d.`danceability_%` <= q.q1_dance THEN 'Baixa'
         WHEN d.`danceability_%` <= q.q2_dance THEN 'Média'
         ELSE 'Alta' END              AS nivel_danceability,
    CASE WHEN d.`valence_%` <= q.q1_valence     THEN 'Baixa'
         WHEN d.`valence_%` <= q.q2_valence     THEN 'Média'
         ELSE 'Alta' END              AS nivel_valence,
    CASE WHEN d.`energy_%` <= q.q1_energy       THEN 'Baixa'
         WHEN d.`energy_%` <= q.q2_energy       THEN 'Média'
         ELSE 'Alta' END              AS nivel_energy,
    CASE WHEN d.`acousticness_%` <= q.q1_acoustic THEN 'Baixa'
         WHEN d.`acousticness_%` <= q.q2_acoustic THEN 'Média'
         ELSE 'Alta' END             AS nivel_acousticness,
    CASE WHEN d.`instrumentalness_%` <= q.q1_instr THEN 'Baixa'
         WHEN d.`instrumentalness_%` <= q.q2_instr THEN 'Média'
         ELSE 'Alta' END             AS nivel_instrumentalness,
    CASE WHEN d.`liveness_%` <= q.q1_live     THEN 'Baixa'
         WHEN d.`liveness_%` <= q.q2_live     THEN 'Média'
         ELSE 'Alta' END              AS nivel_liveness,
    CASE WHEN d.`speechiness_%` <= q.q1_speech THEN 'Baixa'
         WHEN d.`speechiness_%` <= q.q2_speech THEN 'Média'
         ELSE 'Alta' END              AS nivel_speechiness,
    CASE 
          WHEN d.streams <= q.q1_streams THEN 'Baixa'
          WHEN d.streams <= q.q2_streams THEN 'Média'
          ELSE 'Alta'    END AS nivel_streams,
    CASE 
          WHEN d.in_spotify_playlists + d.in_apple_playlists + d.in_deezer_playlists <= q.q1_playlists THEN 'Baixo'
          WHEN d.in_spotify_playlists + d.in_apple_playlists + d.in_deezer_playlists <= q.q2_playlists THEN 'Médio'
          ELSE 'Alto'
          END AS nivel_playlists,

    CASE 
          WHEN d.in_spotify_charts + d.in_apple_charts + d.in_deezer_charts + d.in_shazam_charts <= q.q1_charts THEN 'Baixo'
          WHEN d.in_spotify_charts + d.in_apple_charts + d.in_deezer_charts + d.in_shazam_charts <= q.q2_charts THEN 'Médio'
           ELSE 'Alto'
END AS nivel_charts     
  FROM dados_combinados d
  CROSS JOIN quantis_tecnicos q
)

-- Substituição de NULLs por "No Data"
SELECT
  track_id,
  track_name_limpo,
  artist_name_limpo,
  IFNULL(`streams`, 0) AS `streams`,
  IFNULL(`in_spotify_playlists`, 0) AS `in_spotify_playlists`,
  IFNULL(`in_spotify_charts`, 0) AS `in_spotify_charts`,
  IFNULL(`in_apple_playlists`, 0) AS `in_apple_playlists`,
  IFNULL(`in_apple_charts`, 0) AS `in_apple_charts`,
  IFNULL(`in_deezer_playlists`, 0) AS `in_deezer_playlists`,
  IFNULL(`in_deezer_charts`, 0) AS `in_deezer_charts`,
  IFNULL(`in_shazam_charts`, 0) AS `in_shazam_charts`,
  IFNULL(`n_plataformas_charts`, 0) AS `n_plataformas_charts`,
  IFNULL(`n_plataformas_playlists`, 0) AS `n_plataformas_playlists`,
  IFNULL(CAST(`data_lancamento` AS STRING), 'No Data') AS `data_lancamento`,
  IFNULL(`mes_ano_lancamento`, 'No Data') AS `mes_ano_lancamento`,
  IFNULL(CAST(`tempo_desde_lancamento` AS STRING), 'No Data') AS `tempo_desde_lancamento`,
  IFNULL(`categoria_lancamento`, 'No Data') AS `categoria_lancamento`,
  IFNULL(`decada_lancamento`, 'No Data') AS `decada_lancamento`,
  IFNULL(CAST(`bpm` AS STRING), 'No Data') AS `bpm`,
  IFNULL(`key`, 'No Data') AS `key`,
  IFNULL(CAST(`mode` AS STRING), 'No Data') AS `mode`,
  IFNULL(CAST(`danceability_%` AS STRING), 'No Data') AS `danceability_%`,
  IFNULL(CAST(`valence_%` AS STRING), 'No Data') AS `valence_%`,
  IFNULL(CAST(`energy_%` AS STRING), 'No Data') AS `energy_%`,
  IFNULL(CAST(`acousticness_%` AS STRING), 'No Data') AS `acousticness_%`,
  IFNULL(CAST(`instrumentalness_%` AS STRING), 'No Data') AS `instrumentalness_%`,
  IFNULL(CAST(`liveness_%` AS STRING), 'No Data') AS `liveness_%`,
  IFNULL(CAST(`speechiness_%` AS STRING), 'No Data') AS `speechiness_%`,
  IFNULL(`nivel_bpm`, 'No Data') AS `nivel_bpm`,
  IFNULL(`nivel_danceability`, 'No Data') AS `nivel_danceability`,
  IFNULL(`nivel_valence`, 'No Data') AS `nivel_valence`,
  IFNULL(`nivel_energy`, 'No Data') AS `nivel_energy`,
  IFNULL(`nivel_acousticness`, 'No Data') AS `nivel_acousticness`,
  IFNULL(`nivel_instrumentalness`, 'No Data') AS `nivel_instrumentalness`,
  IFNULL(`nivel_liveness`, 'No Data') AS `nivel_liveness`,
  IFNULL(`nivel_speechiness`, 'No Data') AS `nivel_speechiness`,
  IFNULL(`nivel_streams`, 'No Data') AS `nivel_streams`,
  IFNULL(`nivel_charts`, 'No Data') AS `nivel_charts`,
  IFNULL(`nivel_playlists`, 'No Data') AS `nivel_playlists`,
FROM final;