-- Test Queries
CREATE DATABASE Lok_Sabha_Elections;
USE Lok_Sabha_Elections;
SELECT COUNT(*) FROM constituency_wise_results_2014;
SELECT DISTINCT category FROM constituency_wise_results_2014;
SELECT DISTINCT category FROM constituency_wise_results_2019;
CREATE TABLE Elections_2014_2019 AS
SELECT * FROM constituency_wise_results_2014
UNION ALL
SELECT * FROM constituency_wise_results_2019;
SELECT COUNT(*) FROM Elections_2014_2019;

-- Query to find the two major national parties
SELECT party,SUM(total_votes)
FROM elections_2014_2019
GROUP BY 1
ORDER BY 2 DESC
LIMIT 2;

-- Data Cleaning
/* -- SELECT * FROM dim_states_codes;    
-- ALTER TABLE dim_states_codes
-- RENAME COLUMN ï»¿state_name TO state_name;
-- SELECT DISTINCT pc_name from Elections_2014_2019
-- WHERE election_year="2014"; */

-- PRIMARY INSIGHTS
/* 1. List top 5 / bottom 5 constituencies of 2014 and 2019 in terms of voter turnout ratio */
-- Top 5 Contituencies
WITH constituencies_2014 AS
(
SELECT DISTINCT pc_name,state,sum(total_votes) AS Total_votes,total_electors,
CAST((SUM(total_votes)*1.0/total_electors)*100 AS DECIMAL(10,2)) AS voter_turnout_ratio_2014
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state, pc_name,total_electors
ORDER BY 5 DESC
LIMIT 5
),
constituencies_2019 AS 
(
SELECT DISTINCT pc_name,state,sum(total_votes) AS Total_votes,total_electors,
CAST((SUM(total_votes)*1.0/total_electors)*100 AS DECIMAL(10,2)) AS voter_turnout_ratio_2019
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state, pc_name,total_electors
ORDER BY 5 DESC
LIMIT 5
)
SELECT pc_name, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM constituencies_2014
LEFT JOIN constituencies_2019 USING (pc_name)
UNION
SELECT pc_name, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM constituencies_2019
LEFT JOIN constituencies_2014 USING (pc_name);

-- Bottom 5 constituencies
WITH constituencies_2014 AS
(
SELECT state, pc_name, ROUND((SUM(total_votes)/MAX(total_electors))*100,2) AS voter_turnout_ratio_2014
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state, pc_name
ORDER BY 3 ASC
LIMIT 5
),
constituencies_2019 AS 
(
SELECT state, pc_name, ROUND((SUM(total_votes)/MAX(total_electors))*100,2) AS voter_turnout_ratio_2019
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state, pc_name
ORDER BY 3 ASC
LIMIT 5
)
SELECT pc_name, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM constituencies_2014
LEFT JOIN constituencies_2019 USING (pc_name)
UNION
SELECT pc_name, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM constituencies_2019
LEFT JOIN constituencies_2014 USING (pc_name);

/* 2. List top 5 / bottom 5 states of 2014 and 2019 in terms of voter turnout ratio? */
-- Top 5 States
WITH electors_per_constituency_2014 AS
(
SELECT state, pc_name, MAX(total_electors) AS electors_per_constituency
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state, pc_name
), total_electors_per_state_2014 AS
(
SELECT state, SUM(electors_per_constituency) as electors_per_state
FROM electors_per_constituency_2014
GROUP BY 1
), voter_turnout_ratio_2014 AS 
(
SELECT state, ROUND((SUM(total_votes)/total_electors_per_state_2014.electors_per_state)*100,2) AS voter_turnout_ratio_2014
FROM Elections_2014_2019
JOIN total_electors_per_state_2014 USING (state)
WHERE election_year="2014"
GROUP BY state
ORDER BY 2 DESC
LIMIT 5
), electors_per_constituency_2019 AS
(
SELECT state, pc_name, MAX(total_electors) AS electors_per_constituency
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state,pc_name
), total_electors_per_state_2019 AS
(
SELECT state, SUM(electors_per_constituency) as electors_per_state
FROM electors_per_constituency_2019
GROUP BY 1
), voter_turnout_ratio_2019 AS 
(
SELECT state, ROUND((SUM(total_votes)/total_electors_per_state_2019.electors_per_state)*100,2) AS voter_turnout_ratio_2019
FROM Elections_2014_2019
JOIN total_electors_per_state_2019 USING (state)
WHERE election_year="2019"
GROUP BY state
ORDER BY 2 DESC
LIMIT 5
)
SELECT state, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM voter_turnout_ratio_2014
LEFT JOIN voter_turnout_ratio_2019 USING (state)
UNION
SELECT state, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM voter_turnout_ratio_2019
LEFT JOIN voter_turnout_ratio_2014 USING (state);

-- Bottom 5 States
WITH electors_per_constituency_2014 AS
(
SELECT state, pc_name, MAX(total_electors) AS electors_per_constituency
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state,pc_name
), total_electors_per_state_2014 AS
(
SELECT state, SUM(electors_per_constituency) as electors_per_state
FROM electors_per_constituency_2014
GROUP BY 1
), voter_turnout_ratio_2014 AS 
(
SELECT state, ROUND((SUM(total_votes)/total_electors_per_state_2014.electors_per_state)*100,2) AS voter_turnout_ratio_2014
FROM Elections_2014_2019
JOIN total_electors_per_state_2014 USING (state)
WHERE election_year="2014"
GROUP BY state
ORDER BY 2 ASC
LIMIT 5
), electors_per_constituency_2019 AS
(
SELECT state, pc_name, MAX(total_electors) AS electors_per_constituency
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state,pc_name
), total_electors_per_state_2019 AS
(
SELECT state, SUM(electors_per_constituency) as electors_per_state
FROM electors_per_constituency_2019
GROUP BY 1
), voter_turnout_ratio_2019 AS 
(
SELECT state, ROUND((SUM(total_votes)/total_electors_per_state_2019.electors_per_state)*100,2) AS voter_turnout_ratio_2019
FROM Elections_2014_2019
JOIN total_electors_per_state_2019 USING (state)
WHERE election_year="2019"
GROUP BY state
ORDER BY 2 ASC
LIMIT 5
)
SELECT state, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM voter_turnout_ratio_2014
LEFT JOIN voter_turnout_ratio_2019 USING (state)
UNION
SELECT state, voter_turnout_ratio_2014, voter_turnout_ratio_2019
FROM voter_turnout_ratio_2019
LEFT JOIN voter_turnout_ratio_2014 USING (state);

/* 3. Which constituencies have elected the same party for two consecutive elections, rank them by % of votes to that winning party
in 2019 */
WITH cte1 AS(
SELECT DISTINCT pc_name,state,party,SUM(total_votes) AS total_votes_14,total_electors,
ROW_NUMBER() OVER (PARTITION BY pc_name ORDER BY SUM(total_votes) DESC) AS rnk
FROM Elections_2014_2019
WHERE election_year = '2014'	
GROUP BY pc_name,state,party,total_electors
),
cte2 AS(
SELECT DISTINCT pc_name,state,party,sum(total_votes)as total_votes_19,total_electors,
ROW_NUMBER() OVER (PARTITION BY pc_name ORDER BY SUM(total_votes) DESC) AS rnk
FROM Elections_2014_2019
WHERE election_year = '2019'
GROUP BY pc_name,state,party,total_electors
),
total_votes_19 AS(
SELECT DISTINCT pc_name,sum(total_votes) AS total_vote_of_PC_19
FROM Elections_2014_2019
WHERE election_year = '2019'
GROUP BY pc_name
),
result AS(
SELECT a.pc_name as constituency,a.state AS state, b.party as party,
CAST((total_votes_19*1.0/total_vote_of_PC_19)*100 AS DECIMAL (10,2)) AS win_percentage_votes_in_2019,
ROW_NUMBER() OVER (PARTITION BY a.pc_name ORDER BY CAST((total_votes_19*1.0/total_vote_of_PC_19)*100 AS DECIMAL (10,2)) DESC) AS rnk1
FROM cte1 a
INNER JOIN cte2 b ON a.pc_name=b.pc_name AND a.state=b.state AND a.party=b.party
INNER JOIN total_votes_19 c ON a.pc_name=c.pc_name
WHERE a.rnk=1 AND b.rnk=1
ORDER BY win_percentage_votes_in_2019 DESC,a.pc_name
)
SELECT constituency,state,party,win_percentage_votes_in_2019
FROM result WHERE rnk1=1 ORDER BY win_percentage_votes_in_2019 DESC,constituency
LIMIT 5;

/* 4. Which constituencies have voted for different parties in two elections (list top 10 based on difference (2019-2014) in winner
vote percentage in two elections) */
WITH cte1 AS(
SELECT DISTINCT pc_name,state,party,SUM(total_votes) AS total_votes_14,total_electors,
ROW_NUMBER() OVER (PARTITION BY pc_name ORDER BY SUM(total_votes) DESC) AS rnk
FROM Elections_2014_2019
WHERE election_year = '2014'	
GROUP BY pc_name,state,party,total_electors
),
cte2 AS(
SELECT DISTINCT pc_name,state,party,SUM(total_votes) AS total_votes_19,total_electors,
ROW_NUMBER() OVER (PARTITION BY pc_name ORDER BY SUM(total_votes) DESC) AS rnk
FROM Elections_2014_2019
WHERE election_year = '2019'	
GROUP BY pc_name,state,party,total_electors
),
total_votes_14 as(
SELECT DISTINCT pc_name,sum(total_votes) AS total_vote_of_PC_14
FROM Elections_2014_2019
WHERE election_year = '2014' 
GROUP BY pc_name
),
total_votes_19 AS(
SELECT DISTINCT pc_name,sum(total_votes) AS total_vote_of_PC_19
FROM Elections_2014_2019
WHERE election_year = '2019' 
GROUP BY pc_name
),
results AS(
SELECT a.pc_name AS constituency,a.state AS state, a.party AS party_in_2014,b.party AS party_in_2019,
cast((total_votes_19*1.0/total_vote_of_PC_19)*100 AS DECIMAL(10,2)) AS win_percentage_votes_in_2019,
cast((total_votes_14*1.0/total_vote_of_PC_14)*100 AS DECIMAL(10,2)) AS win_percentage_votes_in_2014,
(cast((total_votes_19*1.0/total_vote_of_PC_19)*100 AS DECIMAL(10,2))-
cast((total_votes_14*1.0/total_vote_of_PC_14)*100 AS DECIMAL(10,2))) as diff,
ROW_NUMBER() OVER (PARTITION BY a.pc_name ORDER BY (CAST((total_votes_19*1.0/total_vote_of_PC_19)*100 AS DECIMAL(10,2))-
CAST((total_votes_14*1.0/total_vote_of_PC_14)*100 AS DECIMAL(10,2))) DESC) AS rnk1
FROM cte1 a
INNER JOIN cte2 b ON a.pc_name=b.pc_name AND a.state=b.state AND a.party<>b.party
INNER JOIN total_votes_19 c ON a.pc_name=c.pc_name
INNER JOIN total_votes_14 d ON a.pc_name=d.pc_name
WHERE a.rnk=1 AND b.rnk=1
)
SELECT constituency,state, party_in_2014,party_in_2019,win_percentage_votes_in_2014,
win_percentage_votes_in_2019 ,diff
FROM results WHERE rnk1=1 
ORDER BY diff DESC,constituency
LIMIT 10;

/* 5. Top 5 candidates based on margin difference with runners in 2014 and 2019 */
-- 2014
WITH candidate_margins AS (
    SELECT 
        pc_name, candidate, election_year, total_votes,
        ROW_NUMBER() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS rrank,
        CASE
            WHEN total_votes = MAX(total_votes) OVER(PARTITION BY pc_name) THEN
                MAX(total_votes) OVER(PARTITION BY pc_name) -
                COALESCE(LEAD(total_votes) OVER(PARTITION BY pc_name ORDER BY total_votes DESC), 0)
			WHEN total_votes = MIN(total_votes) OVER(PARTITION BY pc_name) THEN
                total_votes - total_votes
            ELSE
                total_votes -
                COALESCE(LEAD(total_votes) OVER(PARTITION BY pc_name ORDER BY total_votes DESC), 0)
        END AS margin_difference
    FROM Elections_2014_2019
    WHERE election_year = '2014'
)
SELECT candidate, total_votes, margin_difference
FROM candidate_margins
WHERE rrank = 1
ORDER BY margin_difference DESC
LIMIT 5;
-- 2019
WITH candidate_margins AS (
    SELECT 
        pc_name, candidate, election_year, total_votes,
        ROW_NUMBER() OVER(PARTITION BY pc_name ORDER BY total_votes DESC) AS rrank,
        CASE
            WHEN total_votes = MAX(total_votes) OVER(PARTITION BY pc_name) THEN
                MAX(total_votes) OVER(PARTITION BY pc_name) -
                COALESCE(LEAD(total_votes) OVER(PARTITION BY pc_name ORDER BY total_votes DESC), 0)
			WHEN total_votes = MIN(total_votes) OVER(PARTITION BY pc_name) THEN
                total_votes - total_votes
            ELSE
                total_votes -
                COALESCE(LEAD(total_votes) OVER(PARTITION BY pc_name ORDER BY total_votes DESC), 0)
        END AS margin_difference
    FROM Elections_2014_2019
    WHERE election_year = '2019'
)
SELECT candidate, total_votes, margin_difference
FROM candidate_margins
WHERE rrank = 1
ORDER BY margin_difference DESC
LIMIT 5;

/* 6. % Split of votes of parties between 2014 vs 2019 at national level */
WITH total_votes_2014 AS
(
SELECT  election_year, SUM(total_votes) as te
FROM elections_2014_2019
WHERE election_year="2014"
GROUP BY 1
),
party_votes_2014 AS
(
SELECT election_year, party, SUM(total_votes) AS tv
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY 1,2
), 
total_votes_2019 AS 
(
SELECT  election_year, SUM(total_votes) as te
FROM elections_2014_2019
WHERE election_year="2019"
GROUP BY 1
),
party_votes_2019 AS
(
SELECT election_year, party, SUM(total_votes) AS tv
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY 1,2
)
SELECT COALESCE(pv_2014.party,pv_2019.party) AS party, ROUND((pv_2014.tv/tv_2014.te)*100,2) AS split_pct_2014, ROUND((pv_2019.tv/tv_2019.te)*100,2) AS split_pct_2019
FROM party_votes_2014 pv_2014
LEFT JOIN total_votes_2014 tv_2014 USING (election_year)
LEFT JOIN party_votes_2019 pv_2019 ON pv_2014.party = pv_2019.party
LEFT JOIN total_votes_2019 tv_2019 ON pv_2019.election_year = tv_2019.election_year
ORDER BY 2 DESC;

/* 7. % split of votes of parties between 2014 vs 2019 at state level */
WITH total_votes_2014 AS
(
SELECT  state, SUM(total_votes) as te
FROM elections_2014_2019
WHERE election_year="2014"
GROUP BY 1
),
party_votes_2014 AS
(
SELECT state, party, SUM(total_votes) AS tv
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY 1,2
), 
total_votes_2019 AS 
(
SELECT  state, SUM(total_votes) as te
FROM elections_2014_2019
WHERE election_year="2019"
GROUP BY 1
),
party_votes_2019 AS
(
SELECT state, party, SUM(total_votes) AS tv
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY 1,2
)
SELECT   COALESCE(pv_2014.state, pv_2019.state) AS state, COALESCE(pv_2014.party, pv_2019.party) AS party,
ROUND((pv_2014.tv/tv_2014.te)*100,2) AS split_pct_2014, ROUND((pv_2019.tv/tv_2019.te)*100,2) AS split_pct_2019
FROM party_votes_2014 pv_2014
LEFT JOIN total_votes_2014 tv_2014 USING (state)
LEFT JOIN party_votes_2019 pv_2019 ON pv_2014.state = pv_2019.state AND pv_2014.party = pv_2019.party
LEFT JOIN total_votes_2019 tv_2019 ON pv_2019.state = tv_2019.state
UNION
SELECT   COALESCE(pv_2014.state, pv_2019.state) AS state, COALESCE(pv_2014.party, pv_2019.party) AS party,
ROUND((pv_2014.tv/tv_2014.te)*100,2) AS split_pct_2014, ROUND((pv_2019.tv/tv_2019.te)*100,2) AS split_pct_2019
FROM party_votes_2019 pv_2019
LEFT JOIN total_votes_2019 tv_2019 USING (state)
LEFT JOIN party_votes_2014 pv_2014 ON pv_2014.state = pv_2019.state AND pv_2014.party = pv_2019.party
LEFT JOIN total_votes_2014 tv_2014 ON pv_2014.state = tv_2014.state
ORDER BY 1,2;

/* 8. List top 5 constituencies for two major national parties where they have gained vote share in 2019 as compared to 2014 */
-- BJP
WITH pc_total_14 AS(
SELECT DISTINCT pc_name,state,SUM(total_votes) AS  total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY pc_name,state
)
,pc_total_19 AS(
SELECT DISTINCT pc_name,state,sum(total_votes) AS total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY pc_name,state
)
,party_total_14 AS(
SELECT DISTINCT party,pc_name,sum(total_votes) AS total_party_votes
FROM Elections_2014_2019
WHERE election_year="2014" AND party='BJP'
GROUP BY party,pc_name
),
party_total_19 AS(
SELECT DISTINCT party,pc_name, sum(total_votes) as total_party_votes
FROM Elections_2014_2019
WHERE election_year="2019" AND party='BJP' 
GROUP BY party,pc_name
),
result AS(
SELECT a.pc_name AS constituency ,a.state AS state,d.party AS party,
CAST((c.total_party_votes)*1.0/a.total_votes_of_pc *100  AS DECIMAL(10,2)) AS result_14,
CAST((d.total_party_votes)*1.0/b.total_votes_of_pc *100 AS DECIMAL(10,2)) AS result_19
FROM pc_total_14 a
INNER JOIN pc_total_19 b ON a.pc_name=b.pc_name AND a.state=b.state
INNER JOIN party_total_14 c ON a.pc_name=c.pc_name
INNER JOIN party_total_19 d ON d.pc_name=b.pc_name
)
SELECT state,constituency,party,(result_19-result_14) AS gain_in_vote_share
FROM result
ORDER BY gain_in_vote_share DESC
LIMIT 5;
-- INC
WITH pc_total_14 AS(
SELECT DISTINCT pc_name,state,SUM(total_votes) AS  total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY pc_name,state
)
,pc_total_19 AS(
SELECT DISTINCT pc_name,state,sum(total_votes) AS total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY pc_name,state
)
,party_total_14 AS(
SELECT DISTINCT party,pc_name,sum(total_votes) AS total_party_votes
FROM Elections_2014_2019
WHERE election_year="2014" AND party='INC'
GROUP BY party,pc_name
),
party_total_19 AS(
SELECT DISTINCT party,pc_name, sum(total_votes) as total_party_votes
FROM Elections_2014_2019
WHERE election_year="2019" AND party='INC' 
GROUP BY party,pc_name
),
result AS(
SELECT a.pc_name AS constituency ,a.state AS state,d.party AS party,
CAST((c.total_party_votes)*1.0/a.total_votes_of_pc *100  AS DECIMAL(10,2)) AS result_14,
CAST((d.total_party_votes)*1.0/b.total_votes_of_pc *100 AS DECIMAL(10,2)) AS result_19
FROM pc_total_14 a
INNER JOIN pc_total_19 b ON a.pc_name=b.pc_name AND a.state=b.state
INNER JOIN party_total_14 c ON a.pc_name=c.pc_name
INNER JOIN party_total_19 d ON d.pc_name=b.pc_name
)
SELECT state,constituency,party,(result_19-result_14) AS gain_in_vote_share
FROM result
ORDER BY gain_in_vote_share DESC
LIMIT 5;

/* 9. List top 5 constituencies for two major national parties where they have lost vote share in 2019 as compared to 2014 */
-- BJP
WITH pc_total_14 AS(
SELECT DISTINCT pc_name,state,SUM(total_votes) AS  total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY pc_name,state
)
,pc_total_19 AS(
SELECT DISTINCT pc_name,state,sum(total_votes) AS total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY pc_name,state
)
,party_total_14 AS(
SELECT DISTINCT party,pc_name,sum(total_votes) AS total_party_votes
FROM Elections_2014_2019
WHERE election_year="2014" AND party='BJP'
GROUP BY party,pc_name
),
party_total_19 AS(
SELECT DISTINCT party,pc_name, sum(total_votes) as total_party_votes
FROM Elections_2014_2019
WHERE election_year="2019" AND party='BJP' 
GROUP BY party,pc_name
),
result AS(
SELECT a.pc_name AS constituency ,a.state AS state,d.party AS party,
CAST((c.total_party_votes)*1.0/a.total_votes_of_pc *100  AS DECIMAL(10,2)) AS result_14,
CAST((d.total_party_votes)*1.0/b.total_votes_of_pc *100 AS DECIMAL(10,2)) AS result_19
FROM pc_total_14 a
INNER JOIN pc_total_19 b ON a.pc_name=b.pc_name AND a.state=b.state
INNER JOIN party_total_14 c ON a.pc_name=c.pc_name
INNER JOIN party_total_19 d ON d.pc_name=b.pc_name
),
abs_value AS (
SELECT state,constituency,party,(result_19-result_14) AS loss_in_vote_share
FROM result)
SELECT state,constituency,party, ABS(loss_in_vote_share)
FROM abs_value
ORDER BY loss_in_vote_share
LIMIT 5;
-- INC
WITH pc_total_14 AS(
SELECT DISTINCT pc_name,state,SUM(total_votes) AS  total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2014" 
GROUP BY pc_name,state
)
,pc_total_19 AS(
SELECT DISTINCT pc_name,state,sum(total_votes) AS total_votes_of_pc
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY pc_name,state
)
,party_total_14 AS(
SELECT DISTINCT state,pc_name,party,sum(total_votes) AS total_party_votes
FROM Elections_2014_2019
WHERE election_year="2014" AND party='INC' -- and pc_name='Aurangabad'
GROUP BY party,state,pc_name
),
party_total_19 AS(
SELECT DISTINCT state,pc_name,party,sum(total_votes) as total_party_votes
FROM Elections_2014_2019
WHERE election_year="2019" AND party= 'INC' -- AND pc_name='Aurangabad'
GROUP BY party,state,pc_name
),
result AS(
SELECT a.pc_name AS constituency ,a.state AS state,d.party AS party,
CAST((c.total_party_votes)*1.0/a.total_votes_of_pc *100  AS DECIMAL(10,2)) AS result_14,
CAST((d.total_party_votes)*1.0/b.total_votes_of_pc *100 AS DECIMAL(10,2)) AS result_19
FROM pc_total_14 a
inner JOIN pc_total_19 b ON a.pc_name=b.pc_name AND a.state=b.state
inner JOIN party_total_14 c ON a.pc_name=c.pc_name AND a.state=c.state
inner JOIN party_total_19 d ON b.pc_name=d.pc_name AND b.state=d.state
),
abs_value AS (
SELECT state,constituency,party, (result_19-result_14) AS loss_in_vote_share
FROM result
)
SELECT state,constituency,party, ABS(loss_in_vote_share)
FROM abs_value
ORDER BY loss_in_vote_share
LIMIT 5;

/* 10. Which constituency has voted the most for NOTA? */
WITH cte1 AS
(
SELECT pc_name, SUM(total_votes) as votes_2014
FROM elections_2014_2019
WHERE election_year ="2014" AND party="NOTA"
GROUP BY pc_name
ORDER BY votes_2014 DESC
LIMIT 1
),
cte2 AS(
SELECT pc_name, SUM(total_votes) as votes_2019
FROM elections_2014_2019
WHERE election_year ="2019" AND party="NOTA"
GROUP BY pc_name
ORDER BY votes_2019 DESC
LIMIT 1
)
SELECT "2014" AS election_year,
cte1.pc_name, cte1.votes_2014 AS votes
FROM cte1
UNION ALL
SELECT "2019" AS election_year,
cte2.pc_name, cte2.votes_2019 AS votes
FROM cte2;
-- OR 
WITH ranked_votes AS (
SELECT election_year, pc_name, SUM(total_votes) AS votes,
ROW_NUMBER() OVER (PARTITION BY election_year ORDER BY SUM(total_votes) DESC) AS rn
FROM elections_2014_2019
WHERE party = "NOTA"
GROUP BY election_year, pc_name
)
SELECT election_year, pc_name, votes
FROM ranked_votes
WHERE rn = 1;

/* 11. Which constituencies have elected candidates whose party has less than 10% vote share at state level in 2019? */
WITH winner_candidate AS(
SELECT DISTINCT state,pc_name,party,candidate, SUM(total_votes) AS total_votes_for_candidates,
DENSE_RANK() OVER (PARTITION BY pc_name ORDER BY SUM(total_votes) DESC) AS rnk
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY pc_name,candidate,party,state
),
total_state_votes AS(
-- to get total votes for induvidual state
SELECT DISTINCT state,SUM(total_votes) AS total_votes_of_state
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state
),
total_party_votes AS(
-- to get total votes for induvidual party for each state
SELECT DISTINCT state,party,SUM(total_votes) AS total_votes_party
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY party,state
),
result AS(
SELECT DISTINCT a.state,a.pc_name,a.candidate,c.party,a.rnk,
CAST((c.total_votes_party*1.0)/b.total_votes_of_state*100 AS DECIMAL(10,2)) AS vote_percentage
FROM Elections_2014_2019 e 
INNER JOIN winner_candidate a ON a.pc_name=e.pc_name AND a.state=e.state AND a.party=e.party AND a.candidate=e.candidate
INNER JOIN total_state_votes b ON e.state=b.state
INNER JOIN total_party_votes c ON  c.party=e.party AND b.state=c.state
WHERE rnk=1 AND e.election_year="2019"
)
SELECT * FROM result WHERE vote_percentage<10
ORDER BY state;

-- SECONDARY INSIGHTS
/* 1. Is there  a correlation between postal votes % and voter turnout % */
-- voter turnout %
WITH 
total_electors_votes_constituency  AS
(
SELECT state, pc_name, MAX(total_electors) AS te
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state, pc_name
), total_electors_votes_states AS
(
SELECT state, SUM(te) AS tevs
FROM total_electors_votes_constituency
GROUP BY state
),
voter_turnout_2019 AS
(
    SELECT e.state, ROUND((SUM(total_votes) / MAX(t.tevs)) * 100, 2) AS voter_turnout_ratio_2019
    FROM Elections_2014_2019 e
    JOIN total_electors_votes_states t ON e.state=t.state
    WHERE election_year = '2019'
    GROUP BY e.state
)
SELECT state, voter_turnout_ratio_2019
FROM voter_turnout_2019
ORDER BY 2 DESC
LIMIT 10;
-- postal votes %
WITH total_electors_votes_constituency  AS
(
SELECT state, pc_name, MAX(total_electors) AS te
FROM Elections_2014_2019
WHERE election_year="2019"
GROUP BY state, pc_name
), total_electors_votes_states AS
(
SELECT state, SUM(te) AS tevs
FROM total_electors_votes_constituency
GROUP BY state
),
postal_votes_ratio_2019 AS (
    SELECT e.state, 
	ROUND((SUM(postal_votes) /MAX(t.tevs)) * 100, 2) AS postal_votes_ratio_2019
    FROM Elections_2014_2019 e
    JOIN total_electors_votes_states t ON  e.state=t.state
    WHERE election_year = '2019'
    GROUP BY e.state
)
SELECT state, postal_votes_ratio_2019
FROM postal_votes_ratio_2019
ORDER BY 2 DESC
LIMIT 10;

/* 3. Is there any correlation between literacy % of a state and voter turnout % ? */
-- High Voter Turnout States
WITH 
total_electors_votes_constituency  AS
(
SELECT state, pc_name, MAX(total_electors) AS te
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state, pc_name
), total_electors_votes_states AS
(
SELECT state, SUM(te) AS tevs
FROM total_electors_votes_constituency
GROUP BY state
),
voter_turnout_2014 AS
(
    SELECT e.state, ROUND((SUM(total_votes) / MAX(t.tevs)) * 100, 2) AS voter_turnout_ratio_2014
    FROM Elections_2014_2019 e
    JOIN total_electors_votes_states t ON e.state=t.state
    WHERE election_year = '2014'
    GROUP BY e.state
)
SELECT state, voter_turnout_ratio_2014
FROM voter_turnout_2014
ORDER BY 2 DESC
LIMIT 10;
-- Low Voter Turnout States
WITH 
total_electors_votes_constituency  AS
(
SELECT state, pc_name, MAX(total_electors) AS te
FROM Elections_2014_2019
WHERE election_year="2014"
GROUP BY state, pc_name
), total_electors_votes_states AS
(
SELECT state, SUM(te) AS tevs
FROM total_electors_votes_constituency
GROUP BY state
),
voter_turnout_2014 AS
(
    SELECT e.state, ROUND((SUM(total_votes) / MAX(t.tevs)) * 100, 2) AS voter_turnout_ratio_2014
    FROM Elections_2014_2019 e
    JOIN total_electors_votes_states t ON e.state=t.state
    WHERE election_year = '2014'
    GROUP BY e.state
)
SELECT state, voter_turnout_ratio_2014
FROM voter_turnout_2014
ORDER BY 2 ASC
LIMIT 10;
