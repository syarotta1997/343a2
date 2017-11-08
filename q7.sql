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
DROP VIEW IF EXISTS alliances CASCADE;
DROP VIEW IF EXISTS sum_alliances CASCADE;

-- Define views for your intermediate steps here.
create view alliances as
select election.country_id as cid, e1.party_id as pid1, e2.party_id as pid2, count(election.id) as counts
from election_result as e1 join election_result as e2 on e1.alliance_id = e2.id
         join election on e1.election_id = election.id
group by election.country_id, e1.party_id, e2.party_id
order by e1.party_id;

select * from alliances;


create view sum_alliances as
select a1.cid,  a1.pid1, a1.pid2, (a1.count + a2.count) as sums
from alliances as a1, alliances as a2
where a1.pid1 = a2.pid2 and a1.pid2 = a2.pid1
group by a1.cid, a1.pid1, a1.pid2
order by a1.pid1;


-- the answer to the query 
--insert into q7 
