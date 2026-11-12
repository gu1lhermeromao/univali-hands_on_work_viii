# 🌐 Calculadora de Sub-rede (IPv4 & IPv6)

Aplicação desenvolvida em **Flutter** para cálculo e dimensionamento de sub-redes **IPv4** (máscara decimal, CIDR, endereço de rede, broadcast, faixa de hosts utilizáveis) e **IPv6** (compressão RFC 5952, expansão completa de 128 bits, prefixo de rede, intervalo do bloco e quantidade de sub-redes `/64`).

Todo o ambiente de compilação e execução está containerizado via **Docker**, permitindo que qualquer integrante do grupo execute o projeto ou gere o arquivo **APK (Android)** sem precisar instalar o Flutter SDK, Android SDK, Java ou Gradle localmente na máquina.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado em sua máquina:

1. **Git**

2. **Docker** e **Docker Compose**

3. **Pelo menos 10 GB de espaço livre em disco** (a imagem do Flutter + Android SDK + NDK/CMake consome bastante espaço durante a compilação do APK).

4. *(Opcional)* **Android Studio** (apenas se desejar rodar o APK em um Emulador Android virtual no computador).

## ⚙️ Configuração do Ambiente (Linux vs. Windows)

### 🐧 Para usuários Linux (Debian, Ubuntu, Fedora, etc.)

1. Certifique-se de que o serviço do Docker está ativo:

   ```
   sudo systemctl start docker
   
   ```

2. Caso seu usuário não esteja no grupo `docker`, adicione-o para não precisar usar `sudo` em todos os comandos:

   ```
   sudo usermod -aG docker $USER
   newgrp docker
   
   ```

### 🪟 Para usuários Windows (Docker Desktop + WSL 2)

1. Instale o **Docker Desktop for Windows** e certifique-se de que a opção **Use the WSL 2 based engine** está ativada nas configurações (*Settings > General*).

2. **Dica de Performance:** Clone o repositório preferencialmente dentro do sistema de arquivos do WSL 2 (ex.: `~/projetos/calculadora_subrede`) ou no PowerShell, mas certifique-se de que o Docker Desktop está aberto e rodando antes de executar os comandos.

3. **Atenção ao `docker-compose.yml` no Windows:**
   No arquivo `docker-compose.yml`, a montagem `- /dev/bus/usb:/dev/bus/usb` e `network_mode: host` são voltadas para Linux.

   * Para que funcione perfeitamente tanto no **Windows** quanto no **Linux** (inclusive permitindo acesso à porta web `8080`), recomendamos deixar o `docker-compose.yml` da seguinte forma:

```
services:
  flutter:
    image: ghcr.io/cirruslabs/flutter:stable
    container_name: calculadora_subrede_flutter
    working_dir: /app
    stdin_open: true
    tty: true
    ports:
      - "8080:8080"
    volumes:
      - .:/app
      - flutter_pub_cache:/root/.pub-cache
      - gradle_cache:/root/.gradle
    environment:
      ANDROID_HOME: /opt/android-sdk
      ANDROID_SDK_ROOT: /opt/android-sdk
    command: tail -f /dev/null

volumes:
  flutter_pub_cache:
  gradle_cache:

```

*(Nota: Usar `ports: - "8080:8080"` no lugar de `network_mode: host` garante que o servidor Web funcione tanto no Docker Desktop para Windows/Mac quanto no Linux nativo!)*

## 🚀 Passo a Passo: Subindo o Ambiente

1. **Clone o repositório e entre na pasta do projeto:**

   ```
   git clone <URL_DO_REPOSITORIO_AQUI>
   cd <NOME_DA_PASTA_DO_PROJETO>
   
   ```

2. **Inicie o container em segundo plano:**

   ```
   docker compose up -d
   
   ```

   *(Na primeira execução, o Docker fará o download da imagem `ghcr.io/cirruslabs/flutter:stable`, o que pode levar alguns minutos dependendo da sua conexão).*

3. **Baixe as dependências do projeto Flutter:**

   ```
   docker compose exec flutter flutter pub get
   
   ```

## 💻 Modo de Desenvolvimento Rápido (Servidor Web com Hot Reload)

Se você quiser alterar o código em `lib/` e testar o layout e os cálculos rapidamente sem precisar gerar o APK a cada mudança, utilize o servidor Web integrado:

1. **Inicie o servidor web dentro do container:**

   ```
   docker compose exec flutter flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
   
   ```

2. **Acesse no seu navegador:**

   * **Se o Docker estiver na sua própria máquina (Windows ou Linux):** Abra `http://localhost:8080`

   * **Se o Docker estiver rodando em uma Máquina Virtual (VM):** Abra `http://<IP_DA_VM>:8080`

3. **Atualizando o código em tempo real:**
   Sempre que salvar uma alteração nos arquivos `.dart`, vá ao terminal onde o comando está rodando e pressione:

   * **`r` (minúsculo):** *Hot Reload* (atualiza a tela instantaneamente mantendo os dados preenchidos).

   * **`R` (maiúsculo):** *Hot Restart* (reinicia a aplicação do zero).

   * **`q`:** Encerra o servidor web.

## 📦 Gerando o Arquivo APK (Deploy para Android)

Para compilar o aplicativo e gerar o arquivo `.apk` instalável, escolha uma das opções abaixo conforme onde você pretende testar:

### Opção A: Gerar APK para o Emulador do Android Studio no PC (Arquitetura x86_64) — *Mais rápido*

Compila apenas para a arquitetura de processadores de PC/Emulador, economizando tempo e espaço em disco:

```
docker compose exec flutter flutter build apk --debug --target-platform android-x64

```

### Opção B: Gerar APK para Celular Físico Android (Arquitetura ARM64)

Compila apenas para celulares reais modernos:

```
docker compose exec flutter flutter build apk --debug --target-platform android-arm64

```

### Opção C: Gerar APK Universal (Todas as arquiteturas / Release)

Gera um APK compatível com qualquer aparelho ou emulador:

```
# Versão Debug Universal
docker compose exec flutter flutter build apk --debug

# Versão Release (Otimizada para entrega final)
docker compose exec flutter flutter build apk --release

```

### 📂 Onde fica o APK gerado?

Assim que o terminal exibir a mensagem `✓ Built build/app/outputs/flutter-apk/...`, o arquivo já estará disponível diretamente na pasta do seu projeto (no seu Windows ou Linux), no seguinte caminho:

* **APK Debug:** `build/app/outputs/flutter-apk/app-debug.apk`

* **APK Release:** `build/app/outputs/flutter-apk/app-release.apk`

## 📱 Como Testar o APK no Emulador do Android Studio

1. Abra o **Android Studio** e acesse o **Device Manager** (Gerenciador de Dispositivos).

2. Inicie o seu emulador virtual clicando no ícone de **Play** e aguarde o Android carregar até a tela inicial.

3. Abra o gerenciador de arquivos do seu sistema operacional (Windows Explorer ou arquivos do Linux) e vá até a pasta do projeto em:
   `build/app/outputs/flutter-apk/`

4. **Arraste e solte** o arquivo `app-debug.apk` diretamente **em cima da tela do celular virtual** (e não no editor de código do Android Studio).

5. Aguarde o aviso `"Installing APK..."` desaparecer. Depois, arraste a tela inicial do celular virtual de baixo para cima para abrir a gaveta de aplicativos e clique em **Calculadora de Sub-rede**.

## 🛠️ Solução de Problemas Comuns (Troubleshooting)

### 1. Erro `java.io.IOException: No space left on device` durante o build

O build do Android baixa o CMake, NDK e pacotes do Gradle. Se o disco da sua máquina ou VM ficar cheio, o build falhará.

* **No Linux / VM:** Verifique o espaço livre com `df -h` e limpe caches antigos do Docker:

  ```
  docker compose down
  docker builder prune -af
  sudo apt-get clean && sudo journalctl --vacuum-size=100M
  
  ```

* **No Windows (Docker Desktop):** Caso o disco virtual do WSL2 atinja o limite, abra o Docker Desktop, vá em *Settings > Resources > Virtual disk limit* e aumente o limite disponível, ou execute `docker builder prune -af` no PowerShell.

### 2. Erro de compilação no SDK (`'Matrix4' isn't a type`, `'Vector3' isn't a type`, etc.)

Isso acontece se o download de pacotes foi interrompido anteriormente (por falta de espaço ou queda de rede) e corrompeu o volume `flutter_pub_cache`.

* **Como corrigir (Linux e Windows):**

  ```
  docker compose exec flutter sh -c 'rm -rf /root/.pub-cache/* /app/.dart_tool /app/build'
  docker compose exec flutter flutter pub get
  
  ```

### 3. Erro de permissão nos arquivos gerados (Apenas Linux)

Como o container roda como `root`, a pasta `build/` gerada pode ficar pertencendo ao usuário `root` no Linux. Se precisar apagar ou mover arquivos pelo seu usuário normal:

```
sudo chown -R $USER:$USER .

```

### 4. Erro `INSTALL_FAILED_NO_MATCHING_ABIS` ao arrastar o APK para o Emulador

Significa que você gerou um APK para celular físico (`android-arm64`) e tentou instalar em um emulador de PC (`x86_64`), ou vice-versa. Gere novamente especificando `--target-platform android-x64` (ou sem a flag `--target-platform` para gerar o APK universal).