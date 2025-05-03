SELECT
  AVG(in_apple_playlists) AS media_in_apple_playlists,
  MIN(in_apple_playlists) AS minimo_in_apple_playlists,
  MAX(in_apple_playlists) AS maximo_in_apple_playlists,

  AVG(in_apple_charts) AS media_in_apple_charts,
  MIN(in_apple_charts) AS minimo_in_apple_charts,
  MAX(in_apple_charts) AS maximo_in_apple_charts,

  AVG(in_deezer_playlists) AS media_in_deezer_playlists,
  MIN(in_deezer_playlists) AS minimo_in_deezer_playlists,
  MAX(in_deezer_playlists) AS maximo_in_deezer_playlists,

  AVG(in_deezer_charts) AS media_in_deezer_charts,
  MIN(in_deezer_charts) AS minimo_in_deezer_charts,
  MAX(in_deezer_charts) AS maximo_in_deezer_charts,

  AVG(in_shazam_charts) AS media_in_shazam_charts,
  MIN(in_shazam_charts) AS minimo_in_shazam_charts,
  MAX(in_shazam_charts) AS maximo_in_shazam_charts

FROM `projeto-2-spotify-457006.Spotify.Competição`

WHERE in_apple_playlists IS NOT NULL OR 
      in_apple_charts IS NOT NULL OR
      in_deezer_playlists IS NOT NULL OR
      in_deezer_charts IS NOT NULL OR
      in_shazam_charts IS NOT NULL;