# Projeto Sync

Aplicação de estudo em **Java + Spring Boot** que simula uma integração entre sistemas/ERPs. O objetivo é receber cadastros de produtos em JSON, preservar o payload original para controle e, posteriormente, processá-lo para dados relacionais.

## Objetivo

Representar o fluxo de uma integração típica:

```text
ERP externo
  -> API REST Java
  -> histórico do JSON bruto
  -> processamento da integração
  -> tabela de produtos
  -> visualização em interface/dashboard
```

Manter o JSON original permite auditoria, diagnóstico de erros e reprocessamento sem depender de um novo envio do sistema de origem.

## Tecnologias

- Java 25
- Spring Boot
- Spring Web MVC
- Spring Data JPA / Hibernate
- Bean Validation
- SQL Server
- Maven
- Springdoc OpenAPI / Swagger UI

Tecnologias previstas para as próximas etapas:

- T-SQL e `OPENJSON`
- Vaadin
- Docker / Docker Compose

## O que já foi implementado

- Estrutura inicial em camadas: `Controller -> Service -> Repository -> Banco`.
- Endpoint `POST /integracao/json`.
- DTO de entrada com os campos `conteudo` e `tipo`.
- Entidade JPA `JsonEntity`, mapeada para a tabela `dbo.TB_JSON_RECEBIDO`.
- Persistência do conteúdo recebido e do seu tipo por meio do `JsonRepository`.
- Configuração de conexão por variáveis de ambiente:
  - `DB_URL`
  - `DB_USER`
  - `DB_SENHA`
- Dependências iniciais para JPA, validação, web, SQL Server e documentação OpenAPI.

## Fluxo atual

1. Um sistema envia uma requisição `POST` para `/integracao/json`.
2. O controller recebe um objeto com `conteudo` e `tipo`.
3. O serviço cria uma entidade de histórico.
4. O repositório persiste a entidade em `TB_JSON_RECEBIDO`.

Exemplo de requisição, considerando que `conteudo` armazena o JSON original como texto:

```json
{
  "conteudo": "{\"codigoErp\":123,\"descricao\":\"Produto Exemplo\",\"categoriaId\":10,\"estoque\":50,\"preco\":29.90,\"statusId\":1}",
  "tipo": "produtos"
}
```

> As aspas internas são escapadas porque `conteudo` é uma string que contém outro JSON.

## Estrutura atual

```text
src/main/java/br/dev/lucassantos/sync
├── api/controller
│   └── JsonController.java
├── domain/dto
│   └── JsonRequestDTO.java
├── domain/model
│   └── JsonEntity.java
├── domain/repository
│   └── JsonRepository.java
└── domain/service
    └── JsonService.java
```

## Princípios do projeto

- Evoluir gradualmente e manter a solução simples.
- Usar DTOs para a comunicação da API e entidades para persistência.
- Evitar regras de negócio nos controllers.
- Preservar o dado de origem antes de transformá-lo.
- Explicar e avaliar o impacto antes de mudanças estruturais.

