-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT, 
        alliedPartyId1 INT, 
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS alliances_in_a_country CASCADE;
DROP VIEW IF EXISTS alliances CASCADE;

-- Define views for your intermediate steps here.

create view alliances_in_a_country as
select election.id as eid, election_result.id as leaderid, party_id, alliance_id, country_id
from election join election_result on election.id = election_result.election_id
where country_id is not null and alliance_id is not null
order by election.id, party_id;



create view alliances as
select e1.party_id as pid1, e2.party_id as pid2
from election_result as e1 join election_result as e2
where e1.alliance_id is not null and
          e1.alliance_id = e2.id and
          e1. party_id < e2.party_id
order by e1.party_id;

select * from alliances;

-- the answer to the query 
--insert into q7 
