SELECT
  AVG(bpm) AS media_bpm,
  MIN(bpm) AS minimo_bpm,
  MAX(bpm) AS maximo_bpm,

  AVG(`danceability_%`) AS media_danceability,
  MIN(`danceability_%`) AS minimo_danceability,
  MAX(`danceability_%`) AS maximo_danceability,

  AVG(`valence_%`) AS media_valence,
  MIN(`valence_%`) AS minimo_valence,
  MAX(`valence_%`) AS maximo_valence,

  AVG(`energy_%`) AS media_energy,
  MIN(`energy_%`) AS minimo_energy,
  MAX(`energy_%`) AS maximo_energy,

  AVG(`acousticness_%`) AS media_acousticness,
  MIN(`acousticness_%`) AS minimo_acousticness,
  MAX(`acousticness_%`) AS maximo_acousticness,

  AVG(`instrumentalness_%`) AS media_instrumentalness,
  MIN(`instrumentalness_%`) AS minimo_instrumentalness,
  MAX(`instrumentalness_%`) AS maximo_instrumentalness,

  AVG(`liveness_%`) AS media_liveness,
  MIN(`liveness_%`) AS minimo_liveness,
  MAX(`liveness_%`) AS maximo_liveness,

  AVG(`speechiness_%`) AS media_speechiness,
  MIN(`speechiness_%`) AS minimo_speechiness,
  MAX(`speechiness_%`) AS maximo_speechiness

FROM `projeto-2-spotify-457006.Spotify.Informações Técnicas`

WHERE `valence_%` IS NOT NULL OR 
      bpm IS NOT NULL OR
      `energy_%` IS NOT NULL OR
      `danceability_%` IS NOT NULL OR
      `acousticness_%` IS NOT NULL OR
      `instrumentalness_%` IS NOT NULL OR
      `liveness_%` IS NOT NULL OR
      `speechiness_%` IS NOT NULL;
