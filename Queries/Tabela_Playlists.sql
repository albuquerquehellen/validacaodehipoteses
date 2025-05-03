CREATE OR REPLACE TABLE `projeto-2-spotify-457006.Spotify.Total_Participacao_Playlists` AS
SELECT
  c.track_id,
  -- Soma total de participação nas playlists
  COALESCE(c.in_apple_playlists, 0) +  -- Playlists da Apple (da tabela Competição)
  COALESCE(c.in_deezer_playlists, 0) +  -- Playlists do Deezer (da tabela Competição)
  COALESCE(s.in_spotify_playlists, 0) AS total_playlists  -- Playlists do Spotify (da tabela Spotify - Dados)
FROM 
  `projeto-2-spotify-457006.Spotify.Competição` c  -- Tabela Competição
JOIN 
  `projeto-2-spotify-457006.Spotify.Spotify - Dados` s  -- Tabela Spotify - Dados
  ON c.track_id = s.track_id  -- União pelas colunas track_id
