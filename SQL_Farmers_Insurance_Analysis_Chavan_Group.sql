/* SQL Farmers Insurance Analysis
   Group: Gaurav Chavan, Anthony Agnel Nadar, Soumyajit Ghosh, Prakhar Pareek
   Assignment ID: SQL/02 */

/* I. SELECT Queries */
-- 1. Retrieve the names of all states
SELECT DISTINCT srcStateName
FROM pmfby_data;

-- 2. Retrieve TotalFarmersCovered and SumInsured for each state, ordered descending by TotalFarmersCovered
SELECT srcStateName, TotalFarmersCovered, SumInsured
FROM pmfby_data
GROUP BY srcStateName
ORDER BY TotalFarmersCovered DESC;

/* II. Filtering Data (WHERE) */
-- 3. Retrieve records where Year is 2020
SELECT *
FROM pmfby_data
WHERE Year = 2020;

-- 4. Retrieve records where TotalPopulationRural > 10,00,000 and srcStateName = 'HIMACHAL PRADESH'
SELECT *
FROM pmfby_data
WHERE TotalPopulationRural > 1000000
AND srcStateName = 'HIMACHAL PRADESH';

-- 5. Retrieve srcStateName, srcDistrictName, and sum of FarmersPremiumAmount for each district in 2018
SELECT srcStateName, srcDistrictName, SUM(FarmersPremiumAmount) AS TotalPremium
FROM pmfby_data
WHERE Year = 2018
GROUP BY srcStateName, srcDistrictName
ORDER BY TotalPremium ASC;

-- 6. Retrieve total farmers covered and sum of gross premium for each state where InsuredLandArea > 5.0 in 2018
SELECT srcStateName, TotalFarmersCovered, SUM(FarmersPremiumAmount + COALESCE(StatePremiumAmount, 0) + COALESCE(CentralPremiumAmount, 0)) AS GrossPremium
FROM pmfby_data
WHERE InsuredLandArea > 5.0
AND Year = 2018
GROUP BY srcStateName;

/* III. Aggregation (GROUP BY) */
-- 7. Calculate average InsuredLandArea for each year
SELECT Year, AVG(COALESCE(InsuredLandArea, 0)) AS AvgInsuredLandArea
FROM pmfby_data
GROUP BY Year;

-- 8. Calculate TotalFarmersCovered for each district where InsuranceUnits > 0
SELECT srcStateName, srcDistrictName, TotalFarmersCovered
FROM pmfby_data
WHERE InsuranceUnits > 0
GROUP BY srcStateName, srcDistrictName;

-- 9. Calculate total premiums and TotalFarmersCovered for each state where SumInsured > 5,00,000
SELECT srcStateName, SUM(FarmersPremiumAmount + COALESCE(StatePremiumAmount, 0) + COALESCE(CentralPremiumAmount, 0)) AS TotalPremiums, TotalFarmersCovered
FROM pmfby_data
WHERE SumInsured > 500000
GROUP BY srcStateName;

/* IV. Sorting Data (ORDER BY) */
-- 10. Retrieve top 5 districts with highest total population in 2020
SELECT srcStateName, srcDistrictName, TotalPopulation
FROM pmfby_data
WHERE Year = 2020
ORDER BY TotalPopulation DESC
LIMIT 5;

-- 11. Retrieve srcStateName, srcDistrictName, and SumInsured for 10 districts with lowest non-zero FarmersPremiumAmount
SELECT srcStateName, srcDistrictName, SumInsured
FROM pmfby_data
WHERE FarmersPremiumAmount > 0
ORDER BY FarmersPremiumAmount ASC, SumInsured ASC
LIMIT 10;

-- 12. Retrieve top 3 states for each year with highest insured farmers to total population ratio
SELECT Year, srcStateName, (TotalFarmersCovered / NULLIF(TotalPopulation, 0)) AS FarmerPopulationRatio
FROM pmfby_data
WHERE TotalPopulation > 0
ORDER BY Year, FarmerPopulationRatio DESC
LIMIT 3;

/* V. String Functions */
-- 13. Retrieve first 3 characters of srcStateName
SELECT srcStateName, LEFT(srcStateName, 3) AS StateShortName
FROM pmfby_data;

-- 14. Retrieve srcDistrictName where district name starts with 'B'
SELECT srcDistrictName
FROM pmfby_data
WHERE srcDistrictName LIKE 'B%';

-- 15. Retrieve srcStateName and srcDistrictName where district name ends with 'pur'
SELECT srcStateName, srcDistrictName
FROM pmfby_data
WHERE srcDistrictName LIKE '%pur';

/* VI. Joins */
-- 16. INNER JOIN to retrieve aggregated FarmersPremiumAmount where InsuranceUnits > 10
SELECT p1.srcStateName, p1.srcDistrictName, SUM(p1.FarmersPremiumAmount) AS TotalPremium
FROM pmfby_data p1
INNER JOIN pmfby_data p2 ON p1.srcStateName = p2.srcStateName AND p1.srcDistrictName = p2.srcDistrictName
WHERE p1.InsuranceUnits > 10
GROUP BY p1.srcStateName, p1.srcDistrictName;

-- 17. Retrieve srcStateName, srcDistrictName, Year, TotalPopulation with highest FarmersPremiumAmount > 20 crores
SELECT p.srcStateName, p.srcDistrictName, p.Year, p.TotalPopulation
FROM pmfby_data p
INNER JOIN (
    SELECT srcStateName, srcDistrictName, MAX(FarmersPremiumAmount) AS MaxPremium
    FROM pmfby_data
    GROUP BY srcStateName, srcDistrictName
    HAVING MaxPremium > 200000000
) max_premium ON p.srcStateName = max_premium.srcStateName AND p.srcDistrictName = max_premium.srcDistrictName
WHERE p.FarmersPremiumAmount = max_premium.MaxPremium;

-- 18. LEFT JOIN to combine total population with farmers’ data, total premium > 100 crores
SELECT p.srcStateName, p.srcDistrictName, SUM(p.FarmersPremiumAmount + COALESCE(p.StatePremiumAmount, 0) + COALESCE(p.CentralPremiumAmount, 0)) AS TotalPremium, AVG(p.TotalPopulation) AS AvgPopulation
FROM pmfby_data p
LEFT JOIN pmfby_data p2 ON p.srcStateName = p2.srcStateName AND p.srcDistrictName = p2.srcDistrictName
GROUP BY p.srcStateName, p.srcDistrictName
HAVING TotalPremium > 1000000000
ORDER BY TotalPremium DESC;

/* VII. Subqueries */
-- 19. Find districts where TotalFarmersCovered > average TotalFarmersCovered
SELECT srcStateName, srcDistrictName, TotalFarmersCovered
FROM pmfby_data
WHERE TotalFarmersCovered > (
    SELECT AVG(TotalFarmersCovered)
    FROM pmfby_data
);

-- 20. Find srcStateName where SumInsured > highest FarmersPremiumAmount district
SELECT srcStateName
FROM pmfby_data
WHERE SumInsured > (
    SELECT MAX(FarmersPremiumAmount)
    FROM pmfby_data
);

-- 21. Find srcDistrictName where FarmersPremiumAmount > average of state with highest TotalPopulation
SELECT srcDistrictName
FROM pmfby_data p
WHERE FarmersPremiumAmount > (
    SELECT AVG(FarmersPremiumAmount)
    FROM pmfby_data
    WHERE srcStateName = (
        SELECT srcStateName
        FROM pmfby_data
        ORDER BY TotalPopulation DESC
        LIMIT 1
    )
);

/* VIII. Advanced SQL Functions (Window Functions) */
-- 22. Use ROW_NUMBER() to rank records by TotalFarmersCovered
SELECT srcStateName, srcDistrictName, TotalFarmersCovered,
       ROW_NUMBER() OVER (ORDER BY TotalFarmersCovered DESC) AS Rank
FROM pmfby_data;

-- 23. Use RANK() to rank districts based on SumInsured partitioned by srcStateName
SELECT srcStateName, srcDistrictName, SumInsured,
       RANK() OVER (PARTITION BY srcStateName ORDER BY SumInsured DESC) AS Rank
FROM pmfby_data;

-- 24. Use SUM() window function for cumulative FarmersPremiumAmount
SELECT srcStateName, srcDistrictName, FarmersPremiumAmount,
       SUM(FarmersPremiumAmount) OVER (PARTITION BY srcStateName, srcDistrictName) AS CumulativePremium
FROM pmfby_data;

/* IX. Data Integrity (Constraints, Foreign Keys) */
-- 25. Create districts and states tables
CREATE TABLE states (
    StateCode VARCHAR(10) PRIMARY KEY,
    StateName VARCHAR(100) NOT NULL
);

CREATE TABLE districts (
    DistrictCode VARCHAR(10) PRIMARY KEY,
    DistrictName VARCHAR(100) NOT NULL,
    StateCode VARCHAR(10),
    FOREIGN KEY (StateCode) REFERENCES states(StateCode)
);

-- 26. Foreign key constraint already added in districts table creation

/* X. UPDATE and DELETE */
-- 27. Update FarmersPremiumAmount to 500.0 where rowID = 1
UPDATE pmfby_data
SET FarmersPremiumAmount = 500.0
WHERE rowID = 1;

-- 28. Update Year to 2021 where srcStateName = 'HIMACHAL PRADESH'
UPDATE pmfby_data
SET Year = 2021
WHERE srcStateName = 'HIMACHAL PRADESH';

-- 29. Delete records where TotalFarmersCovered < 10,000 and Year = 2020
DELETE FROM pmfby_data
WHERE TotalFarmersCovered < 10000
AND Year = 2020;