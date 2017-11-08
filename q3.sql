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

-- Define views for your intermediate steps here.

--selects country with at least one election and calculates its participation ratio in year 2001 - 2016 inclusive
CREATE VIEW participation_ratio AS
    select extract(year from e_date) as year, country_id as cid, avg( (votes_cast+0.0) /electorate) as ratio
    from election join election_result on election.id = election_result.election_id
    where extract(year from e_date) >= '2001' and extract(year from e_date) <= '2016'
               and country_id is not NULL and votes_cast is not NULL
    group by extract( year from e_date), country_id;

select * from participation_ratio order by year desc;

-- 
create view active_country as
select country.name as countryName, p1.year, p1.ratio
from participation_ratio as p1 join country on p1.cid = country.id
where p1.ratio <= all( select ratio 
                                  from participation_ratio as p2 
                                  where p1.year < p2. year and p1.cid = p2.cid);

select * from active_country order by year desc;

-- the answer to the query 
--insert into q3 

