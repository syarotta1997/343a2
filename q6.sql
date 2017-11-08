-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT, 
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS cabinets_null  CASCADE;
DROP VIEW IF EXISTS cabinets_notnull  CASCADE;
DROP VIEW IF EXISTS answer  CASCADE;

-- Define views for your intermediate steps here.
create view cabinets_null as
select (select min(start_date) from cabinet as c2 where c1.start_date < c2.start_date 
                                                                             and c1.country_id = c2.country_id) as endDate,
          c1.start_date as startDate,
          c1.id as cabinetId,
          null as pmParty;
from cabinet as c1 join country on c1.country_id = country.id
                             join cabinet_party on c1.id = cabinet_party.cabinet.id
where cabinet_party.pm = 0;

create view cabinets_notnull as
select (select min(start_date) from cabinet as c2 where c1.start_date < c2.start_date 
                                                                             and c1.country_id = c2.country_id ) as endDate,
          c1.start_date as startDate,
          c1.id as cabinetId,
          party.name as pmParty;
from cabinet as c1 join country on c1.country_id = country.id
                             join cabinet_party as cp on c1.id = cp.cabinet.id
                             join party on cp.party_id = party.id 
where cabinet_party.pm = 1;

create view answer as
(select * from cabinets_null)
union
(select * from cabinets_notnull)
order by countryName desc, startDate asc;

select * from answer; 


-- the answer to the query 
-- insert into q6 
