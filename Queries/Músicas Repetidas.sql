SELECT
  track_name,
  artist_s__name,
  COUNT(*)
FROM
  `projeto-2-spotify-457006.Spotify.Spotify - Dados`
GROUP BY
  track_name,
  artist_s__name
HAVING
  COUNT(*) > 1;