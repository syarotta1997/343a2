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
DROP VIEW IF EXISTS all_past_cab CASCADE;
DROP VIEW IF EXISTS in_cab CASCADE;
DROP VIEW IF EXISTS all_cab_all_party CASCADE;
DROP VIEW IF EXISTS failed_party CASCADE;
DROP VIEW IF EXISTS all_cab_party_id CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.
create view all_past_cab as
select cabinet.country_id as cid, cabinet.id
from cabinet
where extract(year from start_date) >= '1996' and extract(year from start_date) <= '2016' and
           cabinet.country_id is not null;


create view in_cab as
select cp.id, cp.party_id as pid, p.cid
from all_past_cab as p join cabinet_party as cp on p.id = cp.cabinet_id
where cp.party_id is not null;

select * from in_cab order by cid,id;

create view all_cab_all_party as
select all_past_cab.id, party.id as pid
from party join all_past_cab on party.country_id = all_past_cab.cid;

create view failed_party as
select distinct pid
from (select * from all_cab_all_party except select id,pid from in_cab) as result;

create view all_cab_party_id as
(select pid from in_cab)
except
(select pid from failed_party);

create view answer as
select country.name as countryName, party.name as partyName, party_family.family as partyFamily, 
              party_position.state_market as stateMarket
from all_cab_party_id as a join party on a.pid = party.id
                                        join country on party.country_id = country.id
                                        left join party_family on a.pid = party_family.party_id
                                        left join party_position on a.pid = party_position.party_id;

-- the answer to the query 
insert into q5 (select * from answer);
