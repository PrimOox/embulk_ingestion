export SHELL:=/bin/bash
export SHELLOPTS:=$(if $(SHELLOPTS),$(SHELLOPTS):)pipefail:errexit

.ONESHELL:

setup:
	curl --create-dirs -o ~/.embulk/bin/embulk -L "https://dl.embulk.org/embulk-latest.jar"
	chmod +x ~/.embulk/bin/embulk
	echo 'export PATH="$$HOME/.embulk/bin:$$PATH"' >> ~/.bashrc
	source ~/.bashrc

install_plugins:
	embulk gem install embulk-input-postgresql
	embulk gem install embulk-output-postgresql

build_postgres:
	docker rm -f pg-northwind || true
	docker run --name pg-northwind --network=bridge \
	 -e POSTGRES_USER=$(PG_SOURCE_USER) \
	 -e POSTGRES_PASSWORD=$(PG_SOURCE_PASSWORD) \
	 -e POSTGRES_HOST=$(PG_SOURCE_HOST) \
	 -e POSTGRES_HOST_AUTH_METHOD=md5 \
	 -e POSTGRES_DB="northwind" \
	 -e PGDATA=/var/lib/postgresql/data/pgdata \
     -v $(PWD)/database/postgres_data:/var/lib/postgresql/data \
	 -p $(PG_SOURCE_PORT):5432 \
	 -d postgres:10

build_dw:
	docker rm -f data-warehouse || true
	docker run --name data-warehouse --network=bridge \
	 -e POSTGRES_USER=$(DW_USER) \
	 -e POSTGRES_PASSWORD=$(DW_PASSWORD) \
	 -e POSTGRES_DB="dw" \
	 -e PGDATA=/var/lib/postgresql/data/pgdata \
     -v $(PWD)/database/dw_data:/var/lib/postgresql/data \
	 -p $(DW_PORT):5432 \
	 -d postgres:10

load_postgres_source: build_postgres
	sleep 5
	cd database/postgres_source_data
	PGPASSWORD=$(PG_SOURCE_PASSWORD) psql --host=$(PG_SOURCE_HOST) --port=$(PG_SOURCE_PORT) --user=$(PG_SOURCE_USER) northwind < northwind.sql

load_dw: build_dw
	sleep 5
	cd database/dw_source_data
	PGPASSWORD=$(DW_PASSWORD) psql --host=$(DW_HOST) --port=$(DW_PORT) --user=$(DW_USER) dw < schemas.sql

full_setup: load_postgres_source load_dw

build_setup: build_postgres build_dw