-- choose one to copy

CREATE TABLE books_fdw_partition_1
(
    id UUID DEFAULT gen_random_uuid (),
    title    character varying,
    year     int     NOT NULL,
    category int     NOT NULL
);


CREATE TABLE books_fdw_partition_2
(
    id UUID DEFAULT gen_random_uuid (),
    title    character varying,
    year     int     NOT NULL,
    category int     NOT NULL
);



create index books_fdw_partition_year_idx on books_fdw_partition_1 (year);
create index books_fdw_partition_category_idx on books_fdw_partition_1 (category);

create index books_fdw_partition_year_idx on books_fdw_partition_2 (year);
create index books_fdw_partition_category_idx on books_fdw_partition_2 (category);