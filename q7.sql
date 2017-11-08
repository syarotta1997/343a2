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

-- Define views for your intermediate steps here.

create view alliances_in_a_country as
select election.id, election_result.id, party_id, alliance_id, country_id
from election join election_result on election.id = election_result.election_id
where country_id is not null and alliance_id is not null
order by election.id, party_id;

select * from alliances_in_a_country;




-- the answer to the query 
--insert into q7 
