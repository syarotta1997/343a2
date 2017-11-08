-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS parties_in_country CASCADE;
DROP VIEW IF EXISTS r0_2 CASCADE;
DROP VIEW IF EXISTS r2_4 CASCADE;
DROP VIEW IF EXISTS r4_6 CASCADE;
DROP VIEW IF EXISTS r6_8 CASCADE;
DROP VIEW IF EXISTS r8_10 CASCADE;
DROP VIEW IF EXISTS histogram CASCADE;
DROP VIEW IF EXISTS answer CASCADE;

-- Define views for your intermediate steps here.
create view parties_in_country as
select country.id as cid, party.id as pid, party_position.left_right as position
from party join country on party.country_id = country.id 
                 join party_position on party.id = party_position.party_id
where party_position.left_right is not null;

create view r0_2 as
select cid,pid
from parties_in_country as p
where p.position >= 0 and p.position < 2;

create view r2_4 as
select cid,pid
from parties_in_country as p
where p.position >= 2 and p.position < 4;

create view r4_6 as
select cid,pid
from parties_in_country as p
where p.position >= 4 and p.position < 6;

create view r6_8 as
select cid,pid
from parties_in_country as p
where p.position >= 6 and p.position < 8;

create view r8_10 as
select cid,pid
from parties_in_country as p
where p.position >= 8 and p.position < 10;

create view histogram as
select r0_2.cid, count(r0_2.pid) as r0_2, count(r2_4.pid) as r2_4,
                       count(r4_6.pid) as r4_6,count(r6_8.pid) as r6_8,count(r8_10.pid) as r8_10
from r0_2, r2_4, r4_6, r6_8, r8_10
where r0_2.cid = r2_4.cid and r2_4.cid = r4_6.cid and r4_6.cid = r6_8.cid and r6_8.cid = r8_10.cid
group by r0_2.cid;

create view answer as
select country.name as countryName, r0_2, r2_4, r4_6, r6_8, r8_10
from histogram join country on histogram.cid = country.id;

select * from answer;






-- the answer to the query 
INSERT INTO q4 (select * from answer);

