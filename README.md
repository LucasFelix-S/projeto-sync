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

## Próximas etapas sugeridas

### 1. Consolidar o recebimento

- Alinhar a versão configurada do Java com um compilador JDK compatível para que o projeto compile e os testes possam ser executados.
- Validar os campos obrigatórios e os limites de tamanho do payload.
- Garantir que a coluna de conteúdo comporte JSONs grandes (por exemplo, `nvarchar(max)` no SQL Server, se apropriado ao schema).
- Definir respostas HTTP mais expressivas e tratamento padronizado de erros.

### 2. Criar o modelo de produtos

- Criar a tabela e a entidade de produtos com campos como código ERP, descrição, categoria, estoque, preço e status.
- Definir a chave de negócio (por exemplo, `codigoErp`) e a regra para inserção ou atualização de produtos já existentes.
- Manter a separação entre a tabela de histórico de integração e a tabela de dados de negócio.

### 3. Processar os JSONs recebidos

Há duas abordagens possíveis, que podem inclusive coexistir:

- **Java:** ler os registros pendentes, desserializar `conteudo` com Jackson e salvar os produtos por JPA. É uma boa opção para centralizar regras de negócio na aplicação.
- **SQL Server / T-SQL:** usar `OPENJSON` para transformar o conteúdo da tabela de histórico em registros relacionais. É útil para praticar recursos do SQL Server e para cenários de carga orientados ao banco.

Antes da implementação, vale definir o status do processamento no histórico, por exemplo: `PENDENTE`, `PROCESSADO` e `ERRO`, além de registrar a mensagem de erro e a data de processamento. Isso permite reprocessar integrações com segurança.

### 4. Adicionar uma interface com Vaadin

O Vaadin pode ser incluído depois que a API e a persistência de produtos estiverem estáveis. Uma primeira versão simples poderia conter:

- uma tela com grade paginada de produtos;
- filtros por código, descrição, categoria e status;
- uma tela ou modal para visualizar o JSON bruto associado a uma integração;
- uma grade de histórico mostrando tipo, data de recebimento e status do processamento;
- uma ação de reprocessamento para registros que falharam.

Para manter a arquitetura simples, as views do Vaadin devem chamar serviços da aplicação; elas não devem acessar repositórios diretamente. Assim, regras utilizadas pela API e pela interface continuam no mesmo lugar.

### 5. Qualidade e operação

- Criar testes de controller, serviço e persistência usando uma configuração de banco isolada para testes.
- Documentar o endpoint e exemplos no Swagger/OpenAPI.
- Adicionar logs de integração com um identificador de correlação.
- Criar perfis de configuração para desenvolvimento, teste e produção.
- Adicionar Docker Compose com SQL Server quando a aplicação estiver funcional localmente.
- Avaliar autenticação e controle de acesso antes de expor a API fora de uma rede confiável.

## Princípios do projeto

- Evoluir gradualmente e manter a solução simples.
- Usar DTOs para a comunicação da API e entidades para persistência.
- Evitar regras de negócio nos controllers.
- Preservar o dado de origem antes de transformá-lo.
- Explicar e avaliar o impacto antes de mudanças estruturais.

