-- Cria tabela física a partir da view, com nome diferente
CREATE OR REPLACE TABLE `projeto-2-spotify-457006.Spotify.Dados_Otimizados` AS
SELECT
  *
FROM
  `projeto-2-spotify-457006.Spotify.view_dados_otimizados`;
