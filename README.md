# 🌱 ecoDrive

Aplicativo Flutter para promover práticas de direção ecológica, incentivando motoristas a adotarem hábitos que reduzem o consumo de combustível e as emissões de carbono.

## 🚀 Funcionalidades

- Monitoramento em tempo real de dados do veículo (velocidade, RPM, posição do acelerador) via protocolo OBD-II.
- Pontuação e classificação do desempenho do motorista com base em métricas ecológicas.
- Armazenamento local dos dados de condução para análise posterior.

## 📱 Tecnologias Utilizadas

- [Flutter](https://flutter.dev/) para desenvolvimento multiplataforma.
- [Dart](https://dart.dev/) como linguagem de programação.
- Comunicação com dispositivos OBD-II via Bluetooth.
- Armazenamento local utilizando SQLite.

## 🛠️ Instalação

1. Clone o repositório:
  ```bash
  git clone https://github.com/lgs8Lucas/ecoDrive.git
  ```

2. Navegue até o diretório do projeto:
  ```bash
  cd ecoDrive
  ```

3. Instale as dependências:
  ```bash
  flutter pub get
  ```

4. Conecte um dispositivo e execute o aplicativo:
  ```bash
  flutter run
  ```

## 📂 Estrutura do Projeto
lib/ – Código fonte principal do aplicativo.

android/ – Configurações específicas para Android.

ios/ – Configurações específicas para iOS.

assets/ – Recursos como imagens e ícones.

pubspec.yaml – Gerenciamento de dependências e configurações do projeto.
