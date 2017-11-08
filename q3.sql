-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS participation_ratio CASCADE;
DROP VIEW IF EXISTS not_increasing CASCADE;
DROP VIEW IF EXISTS increasing CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.

--selects country with at least one election and calculates its participation ratio in year 2001 - 2016 inclusive
CREATE VIEW participation_ratio AS
    select extract(year from e_date) as year, country_id as cid, cast(avg( (votes_cast+0.0) /electorate) as numeric) as ratio
    from election
    where extract(year from e_date) >= '2001' and extract(year from e_date) <= '2016'
                -- this line below will eliminate any country who do not hold election during above years
                -- need to enforce not-null on votes cast since it could be null, however electorate is already
                -- restrainted to be not null thus we can use without doubt. 
               and country_id is not NULL and votes_cast is not NULL
    group by extract( year from e_date), country_id;

select * from participation_ratio order by year desc;

-- choose countries
create view not_increasing as
select p1.cid, p1.year, p1.ratio
from participation_ratio as p1
where p1.ratio > any( select p2.ratio 
                                  from participation_ratio as p2 
                                  where p1.year < p2. year and p1.cid = p2.cid);

create view increasing as
 (select distinct cid from participation_ratio) except (select distinct cid from not_increasing);

create view answer as
select increasing.cid, country.name as countryName, p.year as year, p.ratio as participationRatio
from increasing join participation_ratio as p on increasing.cid = p.cid
                         join country on increasing.cid = country.id;

select * from answer order by countryName desc, year desc;

-- the answer to the query 
insert into q3 (select countryName, year,participationRatio  from answer);

