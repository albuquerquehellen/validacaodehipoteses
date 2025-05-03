CREATE OR REPLACE TABLE `projeto-2-spotify-457006.Spotify.solo_tracks_count` AS

WITH artistas_solos AS (
  SELECT
    track_id,
    artist_s__name,
    -- limpa o nome para agrupar corretamente
    REGEXP_REPLACE(artist_s__name, r'[^a-zA-Z0-9À-ÿ\s\(\)\-\,\.\']', '') AS artist_name_limpo
  FROM `projeto-2-spotify-457006.Spotify.Spotify - Dados`
  WHERE artist_count = 1  -- só artistas solo
),

contagem_distinta AS (
  SELECT
    artist_s__name,
    artist_name_limpo,
    COUNT(DISTINCT track_id) AS total_solo_tracks
  FROM artistas_solos
  GROUP BY artist_s__name, artist_name_limpo
)

SELECT
  artist_name_limpo,
  artist_s__name AS artist_name_original,
  total_solo_tracks
FROM contagem_distinta
ORDER BY total_solo_tracks DESC;
