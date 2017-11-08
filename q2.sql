-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS party_results CASCADE;
DROP VIEW IF EXISTS party_wins CASCADE;
DROP VIEW IF EXISTS win_w_recent CASCADE;
DROP VIEW IF EXISTS party_win_count CASCADE;
DROP VIEW IF EXISTS won_gr_three CASCADE;
-- for each country, avg num of winning 
-- Define views for your intermediate steps here.

-- party_result(eid,cid,pid,percentage)
create view party_results as
select election.id as eid, e_date, election.country_id as cid, party_id as pid, ((votes+0.0)/votes_valid) as percentage
from election join election_result on election.id = election_result.election_id
where votes_valid is not null and party_id is not null and votes is not null and country_id is not null;


create view party_wins as
select p1.cid, p1.pid, party.name as name, p1.eid, p1.e_date
from party_results as p1 join party on p1.pid = party.id
where p1.percentage >= (select max(percentage)
                                         from party_results as p2
                                         where p1.eid = p2.eid and p1.pid <> p2.pid);

create view win_w_recent as 
select p1.pid, p1.eid,  extract(year from p1.e_date) as year
from party_wins as p1
where p1.e_date >= ( select max(p2.e_date)
                                    from party_wins as p2
                                    where p1.pid = p2.pid);

create view party_win_count as
select pw.cid, pw.pid, pw.name, wwr.eid, wwr.year, count(*) as wonElection
from party_wins as pw join win_w_recent as wwr on pw.pid = wwr.pid
group by pw.cid, pw.pid, pw.name, wwr.eid, wwr.year;

create view won_gr_three as
select country.name as countryName, p1.name as partyName, party_family.family as partyFamily, 
          p1.wonElections, p1.eid as mostRecentlyWonElectionId ,p1.year as mostRecentlyWonElectionYear
from party_win_count as p1 join country join party_family on p1.cid = country.id and p1.pid = party_family.party_id
where wonElections > 3 * avg( select count(wonElections) 
                                                  from party_win_count as p2
                                                  where p1.cid = p2.cid and p1.pid <> p2.pid);
select * from won_gr_three;
-- the answer to the query 
insert into q2 (select * from won_gr_three);


