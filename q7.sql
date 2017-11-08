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
DROP VIEW IF EXISTS alliances_reci CASCADE;
DROP VIEW IF EXISTS total_ally_count CASCADE;
DROP VIEW IF EXISTS total_election CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.
create view alliances as
select election.country_id as cid, e1.party_id as pid1, e2.party_id as pid2, count(election.id) as counts
from election_result as e1 join election_result as e2 on e1.alliance_id = e2.id
         join election on e1.election_id = election.id
where e1.party_id < e2.party_id
group by election.country_id, e1.party_id, e2.party_id
order by e1.party_id;

create view alliances_reci as
select election.country_id as cid, e2.party_id as pid1, e1.party_id as pid2, count(election.id) as counts
from election_result as e1 join election_result as e2 on e1.alliance_id = e2.id
         join election on e1.election_id = election.id
where e1.party_id > e2.party_id
group by election.country_id, e1.party_id, e2.party_id
order by e1.party_id;

create view total_ally_count as
select a1.cid, a1.pid1,a1.pid2, sum(counts) as counts
from (select * from alliances union select * from alliances_reci) as a1 
group by a1.cid,a1.pid1,a1.pid2
order by a1.pid1;

create view total_election as
select country.id as cid, count(election.id) as total
from country join election on country.id = election.country_id
group by country.id;

create view answer as
select a.cid as countryId, a.pid1 as alliedPartyId1,a.pid2 as alliedPartyId2
from total_ally_count as a join total_election on a.cid = total_election.cid
where a.counts >= 0.3 * total_election.total;

select * from answer;



-- the answer to the query 
--insert into q7 
