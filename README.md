
---

# Configuração do Docker no CentOS

Este guia descreve os passos para instalar e configurar o Docker no CentOS, iniciar containers e configurar imagens DCM4CHEE e OHIF para o seu o ambiente desejado.
## Passo 1: Instalando o Docker no Whm

### 1.1 Atualize os pacotes

```bash
sudo yum check-update
```

### 1.2 Instale o Docker

```bash
curl -fsSL https://get.docker.com/ | sh
```

### 1.3 Inicie o serviço Docker

```bash
sudo systemctl start docker
```

### 1.4 Verifique o status do Docker

```bash
sudo systemctl status docker
```

### 1.5 Configure o Docker para iniciar na inicialização do sistema

```bash
sudo systemctl enable docker
```

### 1.6 Adicione seu usuário ao grupo Docker (opcional)

```bash
sudo usermod -aG docker SEU_USUARIO (wwg2is)
```

> Substitua `SEU_USUARIO` pelo nome do seu usuário no sistema.

# Instruções para Criar uma KeyStore PKCS12 para SSL (HTTPS)

 A KeyStore é utilizada para configurar os certificados SSL do WildFly.

## Passo 1: Preparar os arquivos de chave e certificado

Primeiro você precisará gerar os seguintes arquvios no WHM:
- `server.key`: O arquivo de chave privada.
- `server.crt`: O arquivo de certificado público.

## Passo 2: Criar o arquivo PEM

Execute os seguintes comandos para criar um arquivo PEM que contém a chave e o certificado, com um espaço em branco entre eles:

```bash
cat server.key > server.pem
echo "" >> server.pem
cat server.crt >> server.pem
```

## Passo 3: Criar a KeyStore PKCS12

Agora, crie a KeyStore PKCS12 usando o arquivo PEM criado no passo anterior. Você precisará fornecer uma senha para a KeyStore. A senha padrão usada neste exemplo é `051390`, mas você pode escolher outra senha se desejar:

```bash
openssl pkcs12 -export -in server.pem -out keystore.pkcs12
```

Ao executar este comando, você será solicitado a inserir uma senha para a KeyStore duas vezes: uma para definir a senha da KeyStore e outra para proteger a chave privada.

**Nota:** Certifique-se de proteger adequadamente a senha da KeyStore, pois ela é usada para acessar a KeyStore e a chave privada associada. Lembre-se de cria-la na pasta path/ especificada.

## Passo 2: Configurações Adicionais

### 2.1 Senha de root do WHM

A senha de root do WHM é geralmente a senha padrão criada durante o acesso ao WHM.

### 2.2 Libere todas as portas no firewall

Navegue até a aba HG Firewall Administration.
Verifique se todas as portas necessárias para o funcionamento do Docker estão liberadas no firewall. Você poderá visualizar as portas utilizadas no arquivo docker-compose.yml. `Certifique-se de que nenhuma dessas portas esteja sendo usada por outros programas`.

### 2.3 Reinicie o Firewall no WHM

Certifique-se de reiniciar o firewall no WHM após fazer as configurações necessárias.

### 2.4 Reinicie o serviço Docker

Antes de reiniciá-lo, verifique se não há outros containers em execução, pois ao reiniciá-lo, todos serão interrompidos e, caso não haja a tag "restart", eles não serão reiniciados.
```bash
sudo systemctl restart docker
```

### 2.5 Iniciando containers

Portas liberadas e arquivo docker-compose.yml configurado, agora você já pode iniciar a aplicação com o seguinte comando:

```bash
docker compose up -d
```
Use o seguinte comando para verificar os containers em execução:

```bash
docker ps
```

Use `docker ps -a` para listar todos os containers, incluindo os que não estão em execução.

### 2.6 Gerenciando os containers

- Iniciar/parar um container:

  ```bash
  docker start/stop NOME/ID_DO_CONTAINER
  ```

- Remover um container:

  ```bash
  docker container rm NOME/ID_DO_CONTAINER
  ```

## Passo 3: Configurar o Contêiner OHIF

### 3.1 Atualize o arquivo docker-compose.yml

Edite o arquivo `docker-compose.yml` no contêiner OHIF. Na variável `APP_CONFIG`, altere o valor de `wadoUriRoot` para o domínio que você pretende usar externamente, por exemplo:

```yaml
wadoUriRoot: 'http://SEU_DOMINIO:PORTA/dcm4chee-arc/aets/DCM4CHEE/wado',
qidoRoot: 'http://SEU_DOMINIO:PORTA/dcm4chee-arc/aets/DCM4CHEE/rs',
wadoRoot: 'http://SEU_DOMINIO:PORTA/dcm4chee-arc/aets/DCM4CHEE/rs',
```

Substitua `SEU_DOMINIO` e `PORTA` pelas informações correspondentes ao seu ambiente.

## Passo 4: Instalando o Unrar para importação de imagens DICOM

### 4.1 Instale o Unrar no WHM

```bash
wget https://www.rarlab.com/rar/rarlinux-x64-6.0.2.tar.gz
tar -xzvf rarlinux-x64-6.0.2.tar.gz
cd rar
cp -v rar unrar /usr/local/bin/
```

### 4.2 Descompacte arquivos RAR

Para descompactar um arquivo RAR:

```bash
unrar e ARQUIVO.rar DIRETORIO_DESTINO/
```

Saiba mais em [linuxhelp.com/how-to-install-rar-unrar-on-centos-7](https://www.linuxhelp.com/how-to-install-rar-unrar-on-centos-7).

## Passo 5: Importação de Imagens para o PACS

Para importar imagens de um diretório para o novo PACS, utilizamos a imagem do tooltik do DCM4CHEE encontrada no dockerhub. Para importação, utilize o seguinte comando:

```bash
docker run --rm --network=nome_network -v /caminho/diretorioLocal:/diretorioContainer dcm4che/dcm4che-tools storescu -c DCM4CHEE@IP_DO_SERVIDOR:PORTA ./diretorioContainer
```

> Substitua `nome_network`, `IP_DO_SERVIDOR`, `PORTA` e outros valores conforme necessário.

---

Este é um guia básico para configurar o Docker no CentOS e gerenciar imagens e containers. Certifique-se de adaptar as configurações e comandos de acordo com a sua configuração específica. Para informações adicionais ou problemas, consulte a documentação oficial do Docker e do CentOS.

---

# Instalação do PostgreSQL no WHM

Este guia mostra como instalar o PostgreSQL em seu servidor WHM (Web Host Manager). O PostgreSQL é um sistema de gerenciamento de banco de dados relacional de código aberto, amplamente utilizado para aplicativos da web e de negócios.

**Nota:** Certifique-se de ter privilégios de administrador (root) para executar os comandos a seguir.

## Instale a versão desejada do PostgreSQL (exemplo: 13)

```bash
sudo yum -y install postgresql13 postgresql13-server
```

## Inicialize o banco de dados PostgreSQL

Execute o seguinte comando para inicializar o banco de dados PostgreSQL:

```bash
sudo /usr/pgsql-13/bin/postgresql-13-setup initdb
```

## Inicie o PostgreSQL

Inicie o PostgreSQL usando o seguinte comando:

```bash
sudo systemctl start postgresql-13
```

## Habilite o PostgreSQL na inicialização

Para garantir que o PostgreSQL seja iniciado automaticamente com o sistema, use o seguinte comando:

```bash
sudo systemctl enable postgresql-13
```

## Instale a extensão PostgreSQL para PHP

Se você deseja usar o PostgreSQL com PHP, instale a extensão do PostgreSQL para PHP com o seguinte comando:

```bash
sudo yum install php-pgsql
```

## Reinicie seu servidor web

Depois de concluir todas as etapas acima, é recomendável reiniciar o servidor web para aplicar as alterações:

```bash
sudo systemctl restart httpd
```

Agora, você deve ter o PostgreSQL instalado e configurado em seu servidor WHM.

---

## Integração com o Banco de Dados do Prontuário

Para integrar o banco de dados configurado com o prontuário, siga os passos abaixo no arquivo `config/app.php`.

1. Localize a seção de configuração de conexão com o banco de dados do prontuário. Você encontrará algo semelhante a:

```php
'pacs_docker_db' => [
    'className' => 'Cake\Database\Connection',
    'driver' => 'Cake\Database\Driver\Postgres',
    'persistent' => false,
    'host' => 'IP_DO_SERVIDOR',
    'port' => '5433',
    'username' => 'pacs',
    'password' => 'pacs',
    'database' => 'pacsdb_g2i',
    'encoding' => 'utf8',
    'flags' => [],
    'cacheMetadata' => true,
    'log' => false,
    'quoteIdentifiers' => false,
    'url' => env('DATABASE_URL', null),
]
```

2. Faça as seguintes configurações, se necessário:

   - `host`: O endereço IP ou nome do host onde o banco de dados está hospedado.
   - `port`: A porta na qual o banco de dados está escutando. Normalmente, a porta padrão para PostgreSQL é 5432, mas no seu caso, é 5433.
   - `username`: O nome de usuário usado para se conectar ao banco de dados.
   - `password`: A senha do usuário para autenticação no banco de dados.
   - `database`: O nome do banco de dados que você deseja usar para a integração.
   - `encoding`: A codificação de caracteres usada pelo banco de dados.
   - `quoteIdentifiers`: Configure como `true` se você estiver usando palavras reservadas ou caracteres especiais em nomes de tabelas ou colunas.

3. Salve as alterações no arquivo `config/app.php`.