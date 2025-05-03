CREATE OR REPLACE TABLE `projeto-2-spotify-457006.Spotify.variaveis_derivadas` AS

WITH dados_combinados AS (
  SELECT
    s.track_id,
    s.in_spotify_charts,
    c.in_apple_charts,
    c.in_deezer_charts,
    c.in_shazam_charts,

    DATE(PARSE_DATE('%Y%m%d', FORMAT('%04d%02d%02d', s.released_year, s.released_month, s.released_day))) AS data_lancamento,

    t.bpm,
    t.`danceability_%`,
    t.`valence_%`,
    t.`energy_%`,
    t.`acousticness_%`,
    t.`instrumentalness_%`,
    t.`liveness_%`,
    t.`speechiness_%`

  FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados` s
  LEFT JOIN `projeto-2-spotify-457006.Spotify.Competição` c USING (track_id)
  LEFT JOIN `projeto-2-spotify-457006.Spotify.Informações Técnicas` t USING (track_id)
),

quantis_tecnicos AS (
  SELECT
    APPROX_QUANTILES(bpm, 3)[OFFSET(1)] AS q1_bpm,
    APPROX_QUANTILES(bpm, 3)[OFFSET(2)] AS q2_bpm,

    APPROX_QUANTILES(`danceability_%`, 3)[OFFSET(1)] AS q1_dance,
    APPROX_QUANTILES(`danceability_%`, 3)[OFFSET(2)] AS q2_dance,

    APPROX_QUANTILES(`valence_%`, 3)[OFFSET(1)] AS q1_valence,
    APPROX_QUANTILES(`valence_%`, 3)[OFFSET(2)] AS q2_valence,

    APPROX_QUANTILES(`energy_%`, 3)[OFFSET(1)] AS q1_energy,
    APPROX_QUANTILES(`energy_%`, 3)[OFFSET(2)] AS q2_energy,

    APPROX_QUANTILES(`acousticness_%`, 3)[OFFSET(1)] AS q1_acoustic,
    APPROX_QUANTILES(`acousticness_%`, 3)[OFFSET(2)] AS q2_acoustic,

    APPROX_QUANTILES(`instrumentalness_%`, 3)[OFFSET(1)] AS q1_instr,
    APPROX_QUANTILES(`instrumentalness_%`, 3)[OFFSET(2)] AS q2_instr,

    APPROX_QUANTILES(`liveness_%`, 3)[OFFSET(1)] AS q1_live,
    APPROX_QUANTILES(`liveness_%`, 3)[OFFSET(2)] AS q2_live,

    APPROX_QUANTILES(`speechiness_%`, 3)[OFFSET(1)] AS q1_speech,
    APPROX_QUANTILES(`speechiness_%`, 3)[OFFSET(2)] AS q2_speech
  FROM dados_combinados
),

final AS (
  SELECT
    d.track_id,

    -- Número de plataformas com presença em charts
    COALESCE(d.in_spotify_charts, 0) +
    COALESCE(d.in_apple_charts, 0) +
    COALESCE(d.in_deezer_charts, 0) +
    COALESCE(d.in_shazam_charts, 0) AS n_plataformas_charts,

    -- Mês/ano de lançamento
    FORMAT_DATE('%Y-%m', data_lancamento) AS mes_ano_lancamento,

    -- Dias desde o lançamento
    DATE_DIFF(CURRENT_DATE(), data_lancamento, DAY) AS tempo_desde_lancamento,

    -- Classificações por nível (com base em quantis)
    CASE
      WHEN bpm <= q.q1_bpm THEN 'Baixa'
      WHEN bpm <= q.q2_bpm THEN 'Média'
      ELSE 'Alta'
    END AS nivel_bpm,

    CASE
      WHEN `danceability_%` <= q.q1_dance THEN 'Baixa'
      WHEN `danceability_%` <= q.q2_dance THEN 'Média'
      ELSE 'Alta'
    END AS nivel_danceability,

    CASE
      WHEN `valence_%` <= q.q1_valence THEN 'Baixa'
      WHEN `valence_%` <= q.q2_valence THEN 'Média'
      ELSE 'Alta'
    END AS nivel_valence,

    CASE
      WHEN `energy_%` <= q.q1_energy THEN 'Baixa'
      WHEN `energy_%` <= q.q2_energy THEN 'Média'
      ELSE 'Alta'
    END AS nivel_energy,

    CASE
      WHEN `acousticness_%` <= q.q1_acoustic THEN 'Baixa'
      WHEN `acousticness_%` <= q.q2_acoustic THEN 'Média'
      ELSE 'Alta'
    END AS nivel_acousticness,

    CASE
      WHEN `instrumentalness_%` <= q.q1_instr THEN 'Baixa'
      WHEN `instrumentalness_%` <= q.q2_instr THEN 'Média'
      ELSE 'Alta'
    END AS nivel_instrumentalness,

    CASE
      WHEN `liveness_%` <= q.q1_live THEN 'Baixa'
      WHEN `liveness_%` <= q.q2_live THEN 'Média'
      ELSE 'Alta'
    END AS nivel_liveness,

    CASE
      WHEN `speechiness_%` <= q.q1_speech THEN 'Baixa'
      WHEN `speechiness_%` <= q.q2_speech THEN 'Média'
      ELSE 'Alta'
    END AS nivel_speechiness

  FROM dados_combinados d
  CROSS JOIN quantis_tecnicos q
)

SELECT * FROM final;
