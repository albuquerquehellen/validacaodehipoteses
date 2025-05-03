SELECT 
  REGEXP_REPLACE(track_name, r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS track_name_limpo,
  REGEXP_REPLACE(artist_s__name, r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS artists_name_limpo
FROM 
  `projeto-2-spotify-457006.Spotify.Spotify - Dados`;