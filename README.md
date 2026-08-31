# 🎬 Catálogo de Filmes — .NET + MySQL + Azure

Projeto acadêmico desenvolvido para demonstrar a **conteinerização, registro e execução de uma aplicação .NET e de um banco de dados MySQL na nuvem utilizando Microsoft Azure**.

A solução consiste em uma API REST desenvolvida em **ASP.NET Core 8.0**, responsável pelo gerenciamento de filmes, e um banco de dados **MySQL 8.0**, executados em containers.

As imagens Docker são construídas localmente e posteriormente registradas no **Azure Container Registry (ACR)**. Em seguida, os containers são executados na nuvem utilizando **Azure Container Instances (ACI)**.

Os dados do MySQL são persistidos utilizando um **Azure Storage Account com Azure File Share**, enquanto informações sensíveis, como credenciais e connection string, são armazenadas no **Azure Key Vault**.

---

## 📌 Sobre o projeto

A aplicação disponibiliza uma API REST para realizar operações de **CRUD (Create, Read, Update e Delete)** sobre uma tabela de filmes.

A tabela `filmes` possui os seguintes campos:

| Campo             | Tipo         | Descrição              |
| ----------------- | ------------ | ---------------------- |
| `id`              | INT          | Identificador do filme |
| `titulo`          | VARCHAR(100) | Título do filme        |
| `descricao`       | VARCHAR(255) | Descrição do filme     |
| `genero`          | VARCHAR(50)  | Gênero do filme        |
| `duracao_minutos` | INT          | Duração em minutos     |
| `data_lancamento` | DATE         | Data de lançamento     |

A API utiliza **Entity Framework Core** para comunicação com o banco de dados MySQL.

---

## 🛠️ Tecnologias utilizadas

* C#
* ASP.NET Core 8.0
* Entity Framework Core
* MySQL 8.0
* Docker
* Azure CLI
* Azure Container Registry (ACR)
* Azure Container Instances (ACI)
* Azure Storage Account
* Azure File Share
* Azure Key Vault
* Git e GitHub

---

## 📂 Repositórios

O projeto foi dividido em dois repositórios no GitHub:

### API .NET

Repositório contendo a aplicação ASP.NET Core, seus controllers, models, configuração do Entity Framework e Dockerfile.

🔗 **[Repositório da API .NET](https://github.com/mfernandx/api-catalogo-filmes-dotnet.git)**

### MySQL

Repositório contendo o Dockerfile do banco de dados e o script `init.sql`, responsável pela criação da tabela e inserção dos dados iniciais.

🔗 **[Repositório do MySQL](https://github.com/mfernandx/mysql-catalogofilmes.git)**

---

## 🎥 Demonstração

O funcionamento da solução foi apresentado em dois vídeos.

### Parte 1 — Recursos da Azure

Nesta primeira parte são apresentados os recursos criados na Microsoft Azure, incluindo o Resource Group, Azure Container Registry, Storage Account, Key Vault e Azure Container Instances.

🔗 **[Vídeo — Parte 1: Recursos Azure](https://youtu.be/a1K2iAp-6rA)**

### Parte 2 — Testes CRUD

Nesta segunda parte são realizados os testes das operações CRUD na API e diretamente no banco de dados, utilizando `SELECT` para demonstrar os resultados.

🔗 **[Vídeo — Parte 2: Testes CRUD](https://youtu.be/WAHvOuTT7PU)**

---

# 🚀 Tutorial de execução

## 1. Pré-requisitos

Para executar o projeto, é necessário possuir:

* Docker
* Azure CLI
* Conta na Microsoft Azure
* Git

Também é necessário estar autenticado na Azure:

```bash
az login
```

Verifique a assinatura atualmente selecionada:

```bash
az account show
```

---

## 2. Clonar os repositórios

Clone os dois repositórios:

```bash
git clone https://github.com/mfernandx/api-catalogo-filmes-dotnet.git
```

```bash
git clone https://github.com/mfernandx/mysql-catalogofilmes.git
```

---

# 🐳 Build das imagens Docker

As imagens são construídas localmente antes de serem enviadas para o Azure Container Registry.

## 3. Build da imagem da API

Dentro do diretório da API:

```bash
docker build -t api-catalogo-filmes -f docker/Dockerfile .
```

Verifique se a imagem foi criada:

```bash
docker image ls
```

---

## 4. Build da imagem do MySQL

Dentro do diretório do MySQL:

```bash
docker build -t mysql-catalogofilmes -f Dockerfile.mysql .
```

Verifique novamente as imagens:

```bash
docker image ls
```

---

# 🧪 Testes locais

Antes do envio das imagens para a nuvem, as aplicações podem ser executadas localmente para validação.

Crie uma rede Docker:

```bash
docker network create catalogo-filmes-network
```

Execute o MySQL:

```bash
docker run -d \
  --name mysql-catalogofilmes \
  --network catalogo-filmes-network \
  -p 3306:3306 \
  -e MYSQL_ROOT_PASSWORD=senha-catalogofilmes \
  -e MYSQL_DATABASE=db-catalogofilmes \
  -e MYSQL_USER=user-catalogofilmes \
  -e MYSQL_PASSWORD=senha-catalogofilmes \
  mysql-catalogofilmes
```

Execute a API:

```bash
docker run -d \
  --name api-catalogo-filmes \
  --network catalogo-filmes-network \
  -p 8080:8080 \
  -e ConnectionStrings__DefaultConnection="Server=mysql-catalogofilmes;Port=3306;Database=db-catalogofilmes;User=user-catalogofilmes;Password=senha-catalogofilmes;" \
  api-catalogo-filmes
```

Verifique os containers:

```bash
docker ps
```

---

# ☁️ Registro das imagens no Azure Container Registry

O projeto utiliza um **Azure Container Registry privado** para armazenar as imagens Docker.

O ACR utilizado neste projeto é:

```text
catalogofilmesrm565277.azurecr.io
```

As imagens foram registradas utilizando o RM do representante como prefixo:

```text
rm565277-api-catalogo-filmes
rm565277-mysql-catalogo-filmes
```

---

## 5. Login no ACR

```bash
az acr login --name catalogofilmesrm565277
```

---

## 6. Tag da imagem da API

```bash
docker tag api-catalogo-filmes:latest \
catalogofilmesrm565277.azurecr.io/rm565277-api-catalogo-filmes:v1
```

## 7. Tag da imagem do MySQL

```bash
docker tag mysql-catalogofilmes:latest \
catalogofilmesrm565277.azurecr.io/rm565277-mysql-catalogo-filmes:v1
```

---

## 8. Push da imagem da API

```bash
docker push \
catalogofilmesrm565277.azurecr.io/rm565277-api-catalogo-filmes:v1
```

---

## 9. Push da imagem do MySQL

```bash
docker push \
catalogofilmesrm565277.azurecr.io/rm565277-mysql-catalogo-filmes:v1
```

Para verificar os repositórios existentes no ACR:

```bash
az acr repository list \
  --name catalogofilmesrm565277 \
  --output table
```

Resultado esperado:

```text
rm565277-api-catalogo-filmes
rm565277-mysql-catalogo-filmes
```

---

# 🔐 Azure Key Vault

As informações sensíveis utilizadas pelos containers são armazenadas no Azure Key Vault.

Entre os dados armazenados estão:

* Usuário do MySQL
* Senha do MySQL
* Nome do banco de dados
* Connection String
* Credenciais de acesso ao ACR

Dessa forma, informações sensíveis não precisam ficar expostas diretamente nos scripts de criação dos containers.

O Key Vault utilizado no projeto é:

```text
keyvault-rm565277
```

---

# 💾 Persistência dos dados

Para garantir a persistência dos dados do MySQL, foi criado um **Azure Storage Account** com um **Azure File Share**.

O volume é montado no container MySQL em:

```text
/var/lib/mysql
```

Dessa maneira, os dados do banco não dependem exclusivamente do ciclo de vida do container.

---

# ☁️ Deploy dos containers no Azure Container Instances

Após o registro das imagens no ACR, os containers são criados utilizando **Azure Container Instances (ACI)**.

Os dois ACIs utilizam o RM do representante no nome.

### MySQL

```text
rm565277-mysql-catalogofilmes
```

### API .NET

```text
rm565277-api-catalogofilmes
```

Para listar os containers:

```bash
az container list \
  --resource-group rg-catalogo-filmes \
  --output table
```

---

# 🗄️ Testando o MySQL na nuvem

É possível verificar as informações do ACI MySQL:

```bash
az container show \
  --resource-group rg-catalogo-filmes \
  --name rm565277-mysql-catalogofilmes \
  --query "ipAddress.{IP:ip,FQDN:fqdn,Portas:ports}" \
  --output json
```

Também é possível verificar os logs:

```bash
az container logs \
  --resource-group rg-catalogo-filmes \
  --name rm565277-mysql-catalogofilmes
```

---

# 🌐 Testando a API .NET na nuvem

Para obter o endereço público da API:

```bash
az container show \
  --resource-group rg-catalogo-filmes \
  --name rm565277-api-catalogofilmes \
  --query ipAddress.fqdn \
  --output tsv
```

A API utiliza a porta:

```text
8080
```

A rota principal para filmes é:

```text
/api/filme
```

---

# 🔄 Testes CRUD da API

Substitua `FQDN_DA_API` pelo endereço retornado pelo Azure.

## GET — Listar filmes

```bash
curl -X GET http://FQDN_DA_API:8080/api/filme
```

## GET — Buscar filme por ID

```bash
curl -X GET http://FQDN_DA_API:8080/api/filme/1
```

---

## POST — Inserir filme

```bash
curl -X POST http://FQDN_DA_API:8080/api/filme \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "Oppenheimer",
    "descricao": "A historia do cientista responsavel pelo desenvolvimento da primeira bomba atomica.",
    "genero": "Drama",
    "duracaoMinutos": 180,
    "dataLancamento": "2023-07-21"
  }'
```

Após o POST, pode ser realizado um GET para verificar o novo registro:

```bash
curl -X GET http://FQDN_DA_API:8080/api/filme
```

---

## PUT — Alterar filme

Utilizando o `id` retornado pelo POST:

```bash
curl -X PUT http://FQDN_DA_API:8080/api/filme/8 \
  -H "Content-Type: application/json" \
  -d '{
    "id": 8,
    "titulo": "Oppenheimer - Versao Atualizada",
    "descricao": "Filme sobre a vida e o trabalho de J. Robert Oppenheimer.",
    "genero": "Drama",
    "duracaoMinutos": 190,
    "dataLancamento": "2023-07-21"
  }'
```

Depois, verificar:

```bash
curl -X GET http://FQDN_DA_API:8080/api/filme/8
```

---

## DELETE — Excluir filme

```bash
curl -X DELETE http://FQDN_DA_API:8080/api/filme/8
```

Depois, confirmar a exclusão:

```bash
curl -X GET http://FQDN_DA_API:8080/api/filme
```

---

# 📜 Scripts Azure CLI

Todos os recursos da infraestrutura Azure utilizados no projeto são criados por meio de **Azure CLI**, conforme solicitado na atividade.

Os scripts de infraestrutura incluem:

* Criação/configuração do Storage Account
* Criação/configuração do Key Vault
* Criação do ACI MySQL
* Criação do ACI da API .NET

Os scripts estão disponíveis neste repositório.

---

# 🔒 Segurança

O projeto utiliza o **Azure Key Vault** para armazenar informações sensíveis.

As credenciais não devem ser armazenadas diretamente no código-fonte ou nos scripts versionados no GitHub.

Além disso, a API .NET é executada no container utilizando um **usuário não privilegiado**, conforme definido no Dockerfile:

```dockerfile
USER appuser
```

Dessa forma, a aplicação não é executada como `root`.

---

# 📁 Estrutura dos projetos

## API .NET

```text
api-catalogo-filmes-dotnet/
├── docker/
│   └── Dockerfile
├── src/
│   └── ApiCatalogoFilmes/
│       ├── Controllers/
│       │   └── FilmeController.cs
│       ├── Data/
│       │   └── AppDbContext.cs
│       ├── Models/
│       │   └── Filme.cs
│       ├── Program.cs
│       └── appsettings.json
└── .gitignore
```

## MySQL

```text
mysql-catalogofilmes/
├── docker-entrypoint-initdb.d/
│   └── init.sql
└── Dockerfile.mysql
```

---

# ✅ Resultado

Ao final da atividade, a solução possui:

* ✅ API REST em ASP.NET Core
* ✅ Banco de dados MySQL
* ✅ Dockerfile para a API
* ✅ Dockerfile para o MySQL
* ✅ Build local das imagens
* ✅ Testes locais
* ✅ Imagens registradas no Azure Container Registry
* ✅ ACI para a API
* ✅ ACI para o MySQL
* ✅ Persistência do MySQL em Azure Storage
* ✅ Azure Key Vault para informações sensíveis
* ✅ API executando como usuário não privilegiado
* ✅ Testes CRUD pela API
* ✅ Testes CRUD diretamente no banco de dados
* ✅ Scripts de infraestrutura utilizando Azure CLI

---

## 👩‍💻 Projeto acadêmico

Projeto desenvolvido para fins acadêmicos, com foco em **Docker, Azure Container Registry, Azure Container Instances, persistência de dados e execução de aplicações conteinerizadas na nuvem**.
