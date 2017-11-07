-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS elections_results CASCADE;
DROP VIEW IF EXISTS below_five CASCADE;
DROP VIEW IF EXISTS five_to_ten CASCADE;
DROP VIEW IF EXISTS ten_to_twenty CASCADE;
DROP VIEW IF EXISTS twenty_thirty CASCADE;
DROP VIEW IF EXISTS thirty_fourty CASCADE;
DROP VIEW IF EXISTS above_fourty CASCADE;

-- Define views for your intermediate steps here.

-- selects all year from 1996 to 2016 inclusive, with elections held during the years and paritipant countries
CREATE VIEW elections_results AS
    select extract( year from e_date) as year, election.id, country_id, party_id, avg(votes / votes_valid) as percent 
    from election join election_result on election.id == election_result.election_id
    where extract (year from e_date) >= 1996 and extract (year from e_date) <= 2016
               and country_id <> NULL and party_id <> NULL and votes_valid <> NULL and votes <> NULL
    group by extract( year from e_date), country_id, party_id;

create view below_five as
    select year, country.name as countryName, '(0-5]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent > 0.0 and percent <= 5.0;

create view five_to_ten as
    select year, country.name as countryName, '(5-10]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent > 5.0 and percent <= 10.0;

create view ten_to_twenty as
    select year, country.name as countryName, '(10-20]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent > 10.0 and percent <= 20.0;

create view twenty_thirty as
    select year, country.name as countryName, '(20-30]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent > 20.0 and percent <= 30.0;

create view thirty_fourty as
    select year, country.name as countryName, '(30-40]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent >30.0 and percent <= 40.0;

create view above_fourty as
    select year, country.name as countryName, '(40-100]' as voteRange, party.name
    from elections_results join country on elections_results.country_id == country.id
    where percent > 40.0 and percent <= 100.0;

-- the answer to the query 
insert into q1
    select *
    from below_five union five_to_ten union ten_to_twenty union twenty_thirty union thirty_fourty union above_fourty;
    

