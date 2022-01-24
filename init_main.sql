CREATE TABLE books_fdw_partition
(
    id       UUID DEFAULT gen_random_uuid(),
    title    character varying,
    year     int NOT NULL,
    category int NOT NULL
) PARTITION BY RANGE (category);
create index books_fdw_partition_year_idx on books_fdw_partition (year);
create index books_fdw_partition_category_idx on books_fdw_partition (category);



CREATE TABLE books_local_partition
(
    id       UUID DEFAULT gen_random_uuid(),
    title    character varying,
    year     int NOT NULL,
    category int NOT NULL
) PARTITION BY RANGE (category);
create index books_local_partition_year_idx on books_local_partition (year);
create index books_local_partition_category_idx on books_local_partition (category);

CREATE TABLE books_local_solid
(
    id       UUID DEFAULT gen_random_uuid(),
    title    character varying,
    year     int NOT NULL,
    category int NOT NULL
);
create index books_local_solid_year_idx on books_local_solid (year);
create index books_local_solid_category_idx on books_local_solid (category);

CREATE
    EXTENSION postgres_fdw;


CREATE
    SERVER shard_1
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS ( host 'shard_1', port '5433', dbname 'postgres' );

CREATE
    SERVER shard_2
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS ( host 'shard_2', port '5434', dbname 'postgres' );

CREATE
    USER MAPPING FOR postgres
    SERVER shard_1
    OPTIONS (user 'postgres', password 'pass');

CREATE
    USER MAPPING FOR postgres
    SERVER shard_2
    OPTIONS (user 'postgres', password 'pass');

CREATE
    FOREIGN TABLE books_fdw_partition_1
    PARTITION OF books_fdw_partition
        FOR VALUES FROM (0) TO (100)
    SERVER shard_1;

CREATE
    FOREIGN TABLE books_fdw_partition_2
    PARTITION OF books_fdw_partition
        FOR VALUES FROM (100) TO (200)
    SERVER shard_2;


CREATE
    TABLE books_local_partition_1
    PARTITION OF books_local_partition
        FOR VALUES FROM (0) TO (100);


CREATE
    TABLE books_local_partition_2
    PARTITION OF books_local_partition
        FOR VALUES FROM (100) TO (200);


CREATE OR REPLACE FUNCTION random_between(low INT, high INT)
    RETURNS INT AS
$$
BEGIN
    RETURN floor(random() * (high - low + 1) + low);
END;
$$ language 'plpgsql' STRICT;

create or replace procedure populate(
    amount int,
    table_name varchar
)
    language plpgsql
as
$$
declare
    counter integer := 0;
BEGIN
    while counter < amount
        loop
            EXECUTE
                'INSERT INTO ' || table_name || ' VALUES ($1,$2,$3,$4)'
                USING gen_random_uuid(), 'Title' || counter, random_between(1900, 2020), cast(random() * 199 as int);
            counter := counter + 1;
        end loop;
    commit;
end
$$;

