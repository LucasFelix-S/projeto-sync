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
- SQL Server
- Maven

Tecnologias previstas para as próximas etapas:

- Vaadin
- Docker / Docker Compose

## O que já foi implementado

- Estrutura inicial em camadas: `Controller -> Service -> Repository -> Banco`.
- Endpoint `POST /integracao/json`.
- DTO de entrada com os campos `conteudo` e `tipo`.
- Entidade JPA `JsonEntity`, mapeada para a tabela `dbo.TB_JSON_RECEBIDO`.
- Persistência do conteúdo recebido e do seu tipo por meio do `JsonRepository`.
- Schema SQL Server para histórico de integrações, categorias, status, cadastro, estoque e preço de produtos.
- Processamento dos JSONs de produto com T-SQL e `OPENJSON`.
- Transação para persistir cadastro, estoque e preço como uma única operação.
- Controle de processamento por meio da coluna `PROCESSADO`, evitando reprocessar JSONs já concluídos.
- Configuração de conexão por variáveis de ambiente:
  - `DB_URL`
  - `DB_USER`
  - `DB_SENHA`
- Dependências iniciais para JPA, validação, web, SQL Server e documentação OpenAPI.

## Fluxo atual

1. Um sistema envia uma requisição `POST` para `/integracao/json`.
2. O controller recebe um objeto com `conteudo` e `tipo`.
3. O serviço cria uma entidade de histórico.
4. O repositório persiste a entidade em `TB_JSON_RECEBIDO` com status inicial `N` (não processado).
5. O script `sql/openjson-scripts.sql` lê os JSONs pendentes do tipo `produtos`.
6. O `OPENJSON` transforma o conteúdo em dados de cadastro, estoque e preço.
7. As informações são persistidas nas tabelas relacionais em uma transação.
8. Após a conclusão, o JSON é marcado como `S` (processado).

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
sql
├── openjson-scripts.sql
└── schema-sync.sql

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

## Processamento com OPENJSON

O script `sql/openjson-scripts.sql` representa a etapa de integração no banco de dados. Ele seleciona registros pendentes de `TB_JSON_RECEBIDO`, interpreta o campo `CONTEUDO` com `OPENJSON` e distribui os dados nas tabelas:

- `TB_CADASTRO_PRODUTO`;
- `TB_ESTOQUE_PRODUTO`;
- `TB_PRECO_PRODUTO`.

O processamento ocorre em transação. Com isso, cadastro, estoque, preço e atualização do status são confirmados juntos.

```text
TB_JSON_RECEBIDO (PROCESSADO = N)
  -> OPENJSON
  -> TB_CADASTRO_PRODUTO
  -> TB_ESTOQUE_PRODUTO
  -> TB_PRECO_PRODUTO
  -> TB_JSON_RECEBIDO (PROCESSADO = S)
```

## Próximas etapas

- Evoluir validações e respostas da API.
- Criar testes de controller, serviço, persistência e processamento de integração.
- Registrar detalhes de falhas de processamento para permitir análise e reprocessamento.
- Criar telas de consulta de produtos e histórico de integrações com Vaadin.
- Adicionar perfis de ambiente e Docker Compose para a aplicação e o SQL Server.

## Princípios do projeto

- Evoluir gradualmente e manter a solução simples.
- Usar DTOs para a comunicação da API e entidades para persistência.
- Evitar regras de negócio nos controllers.
- Preservar o dado de origem antes de transformá-lo.
- Explicar e avaliar o impacto antes de mudanças estruturais.
