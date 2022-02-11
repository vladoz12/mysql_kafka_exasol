# mysql_kafka_exasol

---
* This case describes a problem that occurred while attempting to use the `exasol-sink connector` to replicate data into `Exasol`. Opened an [issue](https://github.com/exasol/kafka-connect-jdbc-exasol/issues/23).
* The `Too few parameters` error occurs when the `delete_enabled` flag is set to `true` in the `exasol-sink connector` config. The error occurs even if only the `INSERT` command was executed in MySQL:
  * connector's log:
    ```
    java.sql.SQLException: Too few parameters for statement. (Session: 1723650265780461529)
    ```
  * exasol's log (_EXA_STATISTICS_):
    * _(additionally)_ enable logging in Exasol - [Enabling Auditing in a Docker-based Exasol system](https://community.exasol.com/t5/environment-management/enabling-auditing-in-a-docker-based-exasol-system/ta-p/2578)

    | SESSION_ID          | STMT_ID | COMMAND_NAME  | START_TIME          |EXECUTION_MODE| SQL_TEXT | ERROR_TEXT |
    |:------------------- | -------:|:------------- |:------------------- |:-------------|:-------- |:---------- |
    | 1723650265780461529 | 1       | CREATE TABLE  | 2022-02-02 12:23:09 |EXECUTE       | CREATE TABLE "OLD_TABLE" ("id" DECIMAL(19,0) NOT NULL, "name" CLOB NULL, "email" CLOB NULL, "department" CLOB NULL, PRIMARY KEY("id")) | NULL |
    | 1723650265780461529 | 2       | MERGE         | 2022-02-02 12:23:09 |PREPARE       | MERGE INTO "OLD_TABLE" AS target USING (SELECT ? AS "id", ? AS "name", ? AS "email", ? AS "department") AS incoming ON (target."id"=incoming."id") WHEN MATCHED THEN UPDATE SET "name"=incoming."name","email"=incoming."email","department"=incoming."department" WHEN NOT MATCHED THEN INSERT ("name","email","department","id") VALUES (incoming."name",incoming."email",incoming."department",incoming."id") | NULL |
    | 1723650265780461529 | 3       | DELETE        | 2022-02-02 12:23:09 |PREPARE       | DELETE FROM "OLD_TABLE" WHERE "id" = ? | NULL |
    | 1723650265780461529 | 4       | MERGE         | 2022-02-02 12:23:09 |EXECUTE       | MERGE INTO "OLD_TABLE" AS target USING (SELECT ? AS "id", ? AS "name", ? AS "email", ? AS "department") AS incoming ON (target."id"=incoming."id") WHEN MATCHED THEN UPDATE SET "name"=incoming."name","email"=incoming."email","department"=incoming."department" WHEN NOT MATCHED THEN INSERT ("name","email","department","id") VALUES (incoming."name",incoming."email",incoming."department",incoming."id") | NULL |
    | 1723650265780461529 | 5       | NOT SPECIFIED | 2022-02-02 12:23:09 |EXECUTE       | NULL | Too few parameters for statement. |
    | 1723650265780461529 | 6       | ROLLBACK      | 2022-02-02 12:23:09 |EXECUTE       | ROLLBACK | NULL |

* In this project `delete_enabled` flag is set to `true`. `docker-compose` should be installed on the host to run this project. Execute the command `docker-compose up -d` to run. The project can be fully started in 1-2 minutes.
* Creation of the table `OLD_TABLE` in `connect_test` database in MySQL, configuration MySQL, creation of the schema `CONNECT_TEST` in Exasol, and creation connectors are done in the `setup` service, which is the last one to start.
* MySQL port - `3306`, user - `root`, password - `rootpass`. Exasol port - `9573`, user - `sys`, password - `exasol`. (To connect outside docker-compose)
* The table `OLD_TABLE` in MySQL:
  ```sql
  CREATE TABLE IF NOT EXISTS OLD_TABLE (
      id serial NOT NULL PRIMARY KEY,
      name varchar(100),
      email varchar(200),
      department varchar(200)
  );
  ```
* When all services are running - then you can execute the `INSERT` command in MySQL, for example:
  ```sql
  INSERT INTO OLD_TABLE (name, email, department) VALUES ('alice', 'alice@abc.com', 'engineering');
  ```
* There will be data in the `OLD_TABLE` kafka topic, but the error (described above) occurs in `exasol-sink connector` and in Exasol.
* If you recreate `exasol-sink connector` (delete current, change `delete_enabled` flag to `false`, create with new config)
```bash
curl -X POST -H "Content-Type: application/json"  <kafka-connect>:8083/connectors --data @connectors/exasol-sink.json
```
, then there will be data in Exasol (in `CONNECT_TEST.OLD_TABLE`), and the error will not occur.
* You can monitor the work of connectors and topics by ports:
  * `8003` _kafka-connect-ui_ 
  * `8090` _kowl_

