<h1 align="center">🎧 Validação de Hipóteses - Spotify 2023</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Power%20BI-FAFAFA?style=for-the-badge&logo=powerbi&logoColor=F2C811" />
  <img src="https://img.shields.io/badge/BigQuery-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white" />
</p>

---

## 🎯 Objetivo

Validar (refutar ou confirmar) hipóteses através da análise de dados e fornecer recomendações estratégicas.  
A ideia é apoiar artistas e gravadoras a tomar decisões que aumentem as chances de sucesso musical.

---

## 🛠️ Ferramentas e Tecnologias

- **BigQuery**
- **Power BI**

---

## ⚙️ Processamento de Dados

### 🔹 Limpeza e Normalização:
- Remoção de caracteres especiais de nomes de faixas e artistas.
- Conversão de valores de *streams* para números inteiros.
- Substituição de valores nulos:
  - `"No Data"` para variáveis categóricas.
  - `0` para variáveis numéricas.

### 🔹 Deduplicação:
- Agrupamento por nome da faixa e artista.
- Soma dos *streams* e flags máximas para presença em playlists e charts.

### 🔹 Integração de Dados:
- Dados integrados de **Apple Music**, **Deezer** e **Shazam**.

### 🔹 Criação de Variáveis:
- `data_lancamento`, `categoria_lancamento`, `década`, `total_charts_playlists`.
- Categorização de métricas técnicas (Baixo, Médio, Alto) como BPM, Danceability etc.

---

## 📊 Análise e Descobertas

### 🎵 Distribuição de Streams
- Forte assimetria à direita: poucas músicas concentram muitos *streams*.

### ⏳ Recorte Temporal
- A maioria das faixas analisadas foi lançada **antes de 2023**.

### 📈 Playlists e Charts
- **Playlists**: Correlação **forte** com *streams* (**0.781**).
- **Charts**: Correlação **fraca** (**0.107**).

### 🔄 Spotify vs Outras Plataformas
- **Deezer**: Correlação **0.61**
- **Shazam**: Correlação **0.57**
- **Apple Music**: Correlação **0.55**

### 💓 BPM e Streams
- Correlação **nula** (**-0.0008**) → BPM **não determina sucesso**.

### 👩‍🎤 Artistas com Mais Faixas
- Correlação forte (**0.7787**) → Catálogos maiores tendem a gerar mais *streams*.

### 🔬 Características Sonoras (correlação com streams)
- **Danceability**: -0.103  
- **Valence**: -0.0409  
- **Energy**: -0.0246  
- **Acousticness**: -0.0066  
- **Instrumentalness**: -0.0443  
- **Liveness**: -0.0454  
- **Speechiness**: -0.1128  
