# Ingestão com Embulk

## Instalação Embulk

Inicialmente é necessário fazer a instalação do embulk, pode-se consultar o tutorial [aqui](https://www.embulk.org/).
Para agilizar o processo de instalação, é possível fazê-lo utilizando os comandos abaixo:
```
make setup
make install_plugins
```

## Uso do Embulk Nativo

Para utilizar o embulk localmente, é necessário primeiramente fornecer uma configuração.
Inicialmente é possível criar um arquivo simples de configuração e conferir o seu funcionamento, seguindo os seguintes passos:
```bash
embulk example ./try1
embulk guess ./try1/seed.yml -o config.yml
embulk preview config.yml
embulk run config.yml
```

Embulk é uma ferramenta *open-source* e é mantido de maneira comunitária, de forma que para cada fonte/destino definido é utilizado um *plugin*, existem plugins das seguintes categorias:

1. **input**;
2. **output**;
3. **filter**;
4. *formatter*;
5. *parser*;
6. *encoder*;
7. *decoder*;

Os plugins de 1 a 3, são plugins essenciais para qualquer execução. Plugins das categorias 4 a 7 são plugins que auxiliam na execução, atuando de modo mais específico nas interpretação e transição de dados entre os processos de entrada e saída.

## Uso do Embulk com Docker

É possível utilizar embulk com docker, o que na prática acontece em ambientes de produção. O isolamento obtido com o uso de docker é essencial na execução de replicação de bancos de dados.

```
docker run techindicium/embulk:1.0
```

## Modelo de Replicação

A replicação será de um banco fonte **northwind** para um **data-warehouse**, utilizando um **data-lake** intermediário.

### Plugins utilizados

Para realizar a ingestão serão utilizados os seguintes plugins:
- embulk-input-postgresql [docs](https://github.com/embulk/embulk-input-jdbc/tree/master/embulk-input-postgresql);
- embulk-output-postgresql [docs](https://github.com/embulk/embulk-output-jdbc/tree/master/embulk-output-postgresql);

## Consultas

Conexão com o northwind:
```
PGPASSWORD=$PG_SOURCE_PASSWORD psql --host=$PG_SOURCE_HOST --port=$PG_SOURCE_PORT --user=$PG_SOURCE_USER northwind
```

Conexão com o data-warehouse:
```
PGPASSWORD=$DW_PASSWORD psql --host=$DW_HOST --port=$DW_PORT --user=$DW_USER dw
```