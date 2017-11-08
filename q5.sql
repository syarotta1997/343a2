-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
create view past_cabinet_parties as
select cabinet.country_id as cid, cabinet.id
from cabinet
where extract(year from start_date) >= '1996' and extract(year from start_date) <= '2016' and
           cabinet.country_id is not null;

create view in_cab as
select cp.party_id as pid, p.cid
from past_canbinet_parties as p join cabinet_party as cp on p.id = cp.cabinet_id
where cp.party_id is not null;

create view failed_party as
select party.id as pid
from party join country on party.country_id = country.id
where party.id not in (select in_cab.pid from in_cab where party.country_id = in_cab.cid);

create view all_cab_party_id as
(select pid from in_cab)
except
(select pid from failed _party)

select * from all_cab_party_id;








-- the answer to the query 
-- insert into q5 
