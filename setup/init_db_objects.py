import pyexasol
import pymysql


with open('setup_sql/exasol.sql', 'r') as fd:
    queries = fd.read()

with pyexasol.connect(dsn='poc-exasol-db:8888', user='sys', password='exasol') as conn:
    for query in queries.split(';'):
        if query and not query.isspace():
            with conn.execute(query) as stmt:
                print(f'---------\nExecuted on EXASOL query: \n{query}\n---------')

with open('setup_sql/mysql.sql', 'r') as fd:
    queries = fd.read()

with pymysql.connect(host='mysqldb_host', port=3306, user='root', password='rootpass') as conn:
    with conn.cursor() as cursor:
        for query in queries.split(';'):
            if query and not query.isspace():
                cursor.execute(query)
                print(f'---------\nExecuted on MySQL query: \n{query}\n---------')
