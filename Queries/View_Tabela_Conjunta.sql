CREATE OR REPLACE VIEW `projeto-2-spotify-457006.Spotify.view_tabela_conjunta` AS

SELECT
  -- RAW Spotify - Dados
  s.track_id,
  s.track_name,
  s.artist_s__name,
  SAFE_CAST(s.streams     AS INT64)   AS streams,
  s.artist_count,
  s.in_spotify_playlists,
  s.in_spotify_charts,
  s.released_year,
  s.released_month,
  s.released_day,

  -- Limpeza de nomes
  REGEXP_REPLACE(s.track_name,      r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS track_name_limpo,
  REGEXP_REPLACE(s.artist_s__name,  r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS artist_name_limpo,

  -- Competição (outras plataformas)
  COALESCE(c.in_apple_playlists,   0) AS in_apple_playlists,
  COALESCE(c.in_apple_charts,      0) AS in_apple_charts,
  COALESCE(c.in_deezer_playlists,  0) AS in_deezer_playlists,
  COALESCE(c.in_deezer_charts,     0) AS in_deezer_charts,
  COALESCE(c.in_shazam_charts,     0) AS in_shazam_charts,

  -- Técnicos
  t.bpm,
  t.`danceability_%`,
  t.`valence_%`,
  t.`energy_%`,
  t.`acousticness_%`,
  t.`instrumentalness_%`,
  t.`liveness_%`,
  t.`speechiness_%`,

  -- Total participação em playlists
  p.total_playlists,

  -- Variáveis derivadas (já calculadas na view)
  v.n_plataformas_charts,
  v.mes_ano_lancamento,
  v.tempo_desde_lancamento,
  v.nivel_bpm,
  v.nivel_danceability,
  v.nivel_valence,
  v.nivel_energy,
  v.nivel_acousticness,
  v.nivel_instrumentalness,
  v.nivel_liveness,
  v.nivel_speechiness

FROM
  `projeto-2-spotify-457006.Spotify.Spotify - Dados` s

LEFT JOIN 
  `projeto-2-spotify-457006.Spotify.Competição` c
ON s.track_id = c.track_id

LEFT JOIN 
  `projeto-2-spotify-457006.Spotify.Informações Técnicas` t
ON s.track_id = t.track_id

LEFT JOIN 
  `projeto-2-spotify-457006.Spotify.Total_Participacao_Playlists` p
ON s.track_id = p.track_id

LEFT JOIN 
  `projeto-2-spotify-457006.Spotify.variaveis_derivadas` v
ON s.track_id = v.track_id;

