# ---------------------------------------------------------------------------------------------------------------------------
#
# Makefile: actions to watch delta between BAN/RAN dbs
#
# ---------------------------------------------------------------------------------------------------------------------------

# OS's env
dir_tmp=/data/tmp
dir_dump=/data/tmp
dir_sql=~/devel/check-init-of-BAN/sql
dir_log=~/devel/check-init-of-BAN/tmp

# DB's env
pg_host=db.ban.local
pg_port=5432
pg_dbname=ban
pg_user=ban
pg_pwd=ban
pg_jobs=3
pg_dump=ban20160824-noversion.dump
pg_table=###TAB

pg_psql="env PGPASSWORD=$(pg_pwd) PGOPTIONS='-c client_min_messages=ERROR' psql --host $(pg_host) --port $(pg_port) --username $(pg_user) --dbname $(pg_dbname) --variable ON_ERROR_STOP=1 --no-password"

# -[restore]-----------------------------------------------------------------------------------------------------------------

list:
	@if [ ! -e $(dir_tmp)/$(pg_dump).list ]; then\
		pg_restore -l $(dir_dump)/$(pg_dump) > $(dir_tmp)/$(pg_dump).list;\
	fi

list2:
	F_EXISTS=$(shell [ -e $(dir_tmp)/$(pg_dump).list ] && echo 1 || echo 0)
	ifeq ($(F_EXISTS), 0)
		$(info Build list of dump)
		@pg_restore -l $(dir_dump)/$(pg_dump) > $(dir_tmp)/$(pg_dump).list
	endif

restore_table: list
	$(info $(pg_table))
	$(info extract DDL from dump)
	@#  be careful w/ tablename (add a space before)
	@grep ' $(pg_table)' $(dir_tmp)/$(pg_dump).list | grep -E 'TABLE|SEQUENCE' > $(dir_tmp)/$(pg_dump).$(pg_table).data.list
	@grep ' $(pg_table)' $(dir_tmp)/$(pg_dump).list | grep -vE 'TABLE|SEQUENCE|CONSTRAINT' > $(dir_tmp)/$(pg_dump).$(pg_table).index.list
	@grep ' $(pg_table)' $(dir_tmp)/$(pg_dump).list | grep -vE 'TABLE|SEQUENCE|INDEX' > $(dir_tmp)/$(pg_dump).$(pg_table).constr.list
	@#
	@#eval $(pg_psql) --command "'drop table $(pg_table) cascade;'"
	$(info drop table)
	@PGPASSWORD=$(pg_pwd) psql --host $(pg_host) --port $(pg_port) --username $(pg_user) --dbname $(pg_dbname) --variable ON_ERROR_STOP=1 --no-password --command "drop table $(pg_table) cascade;"
	@#
	$(info restore table+data, index & constr)
	@PGPASSWORD=$(pg_pwd) pg_restore -h db.ban.local -U ban -d ban -j $(pg_jobs) -L $(dir_tmp)/$(pg_dump).$(pg_table).data.list $(dir_tmp)/$(pg_dump)
	@PGPASSWORD=$(pg_pwd) pg_restore -h db.ban.local -U ban -d ban -j $(pg_jobs) -L $(dir_tmp)/$(pg_dump).$(pg_table).index.list $(dir_tmp)/$(pg_dump)
	@PGPASSWORD=$(pg_pwd) pg_restore -h db.ban.local -U ban -d ban -j $(pg_jobs) -L $(dir_tmp)/$(pg_dump).$(pg_table).constr.list $(dir_tmp)/$(pg_dump)

restore_list:
	@make restore_table pg_table=session
	@make restore_table pg_table=municipality
	@make restore_table pg_table=postcode
	@make restore_table pg_table=public.group
	@make restore_table pg_table=housenumber
	@make restore_table pg_table=position

restore_default: list
	@grep 'DEFAULT' $(dir_tmp)/$(pg_dump).list > $(dir_tmp)/$(pg_dump).default.list
	@PGPASSWORD=$(pg_pwd) pg_restore -h db.ban.local -U ban -d ban -j $(pg_jobs) -L $(dir_tmp)/$(pg_dump).default.list $(dir_tmp)/$(pg_dump)

clean:
	@rm $(dir_tmp)/$(pg_dump)*.list

# -[delta]-------------------------------------------------------------------------------------------------------------------

eval_delta_municipality:
	@eval $(pg_psql) --file $(dir_sql)/eval_delta_municipality.sql --output $(dir_log)/work.log

eval_delta_postcode:
	@eval $(pg_psql) --file $(dir_sql)/eval_delta_postcode.sql --output $(dir_log)/work.log

eval_delta_group:
	@eval $(pg_psql) --file $(dir_sql)/eval_delta_group_by_id.sql --output $(dir_log)/work.log

eval_delta_housenumber:
	@eval $(pg_psql) --file $(dir_sql)/eval_delta_housenumber_by_cea.sql --output $(dir_log)/work.log

eval_delta: eval_delta_municipality eval_delta_postcode eval_delta_group eval_delta_housenumber

print_delta_municipality:
	@eval $(pg_psql) --file $(dir_sql)/print_delta_municipality.sql --output $(dir_log)/print_delta_municipality.txt

print_delta_postcode:
	@eval $(pg_psql) --file $(dir_sql)/print_delta_postcode.sql --output $(dir_log)/print_delta_postcode.txt

print_delta_group:
	@eval $(pg_psql) --file $(dir_sql)/print_delta_group_by_id.sql --output $(dir_log)/print_delta_group.txt

print_delta_housenumber:
	@eval $(pg_psql) --file $(dir_sql)/print_delta_housenumber_by_cea.sql --output $(dir_log)/print_delta_housenumber.txt

print_delta: print_delta_municipality print_delta_postcode print_delta_group print_delta_housenumber

print_dup_group:
	@eval $(pg_psql) --file $(dir_sql)/print_duplicate_group.sql --output $(dir_log)/print_duplicate_group.txt

print_globals:
	@eval $(pg_psql) --file $(dir_sql)/print_globals.sql --output $(dir_log)/print_globals.txt

# -[test]--------------------------------------------------------------------------------------------------------------------

test2:
	@var2=$(shell whoami)
	@echo $(var2)
	@var=DATA2
	@echo $(var)

echo:
	@echo ' $(pg_var)'

echo_v:
	-@override pg_var=TAB1

echo_c: echo_v echo
