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
DROP VIEW IF EXISTS elections_results CASCADE;
DROP VIEW IF EXISTS alliances CASCADE;
DROP VIEW IF EXISTS alliances_reci CASCADE;
DROP VIEW IF EXISTS total_ally_count CASCADE;
DROP VIEW IF EXISTS total_election CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.
create view elections_results as
select country_id as cid, e1.id as eid, e2.id as rid, e2.party_id as pid, e2.alliance_id as aid
from election as e1 join election_result as e2 on e1.id = e2.election_id
where country_id is not null;

create view alliances as
select e1.cid, e1.pid as pid1, e2.pid as pid2, count(*) as counts
from elections_results as e1 join elections_results as e2 on e1.aid = e2.rid
where e1.pid < e2.pid
group by e1.cid, e1.pid, e2.pid
order by e1.pid;

create view alliances_reci as
select e1.cid, e2.pid as pid1, e1.pid as pid2, count(*) as counts
from elections_results as e1 join elections_results as e2 on e1.aid = e2.rid
where e1.pid > e2.pid
group by e1.cid, e1.pid, e2.pid
order by e1.pid;

create view total_ally_count as
select a1.cid, a1.pid1, a1.pid2, sum(a1.counts) as counts
from (select * from alliances union all select * from alliances_reci) as a1
group by a1.cid, a1.pid1, a1.pid2;

create view total_election as
select country.id as cid, count(election.id) as total
from country join election on country.id = election.country_id
group by country.id;

select * from total_election;

create view answer as
select a.cid as countryId, a.pid1 as alliedPartyId1,a.pid2 as alliedPartyId2
from total_ally_count as a join total_election on a.cid = total_election.cid
where a.counts >=  0.3 * total_election.total as numeric;

-- the answer to the query 
insert into q7 (select * from answer);
