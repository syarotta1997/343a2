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
create view alliances as
select election.country_id as cid, e1.party_id as pid1, e2.party_id as pid2, count(election.id) as counts
from election_result as e1 join election_result as e2 on e1.alliance_id = e2.id
         join election on e1.election_id = election.id
group by election.country_id, e1.party_id, e2.party_id
order by e1.party_id;

select * from alliances;


-- the answer to the query 
--insert into q7 
