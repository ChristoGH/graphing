// CALL gds.graph.list()
// YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
//       nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime;
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003_neo4j.csv /var/lib/neo4j/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/woolworths_benmore.csv /var/lib/neo4j/import/
// sudo mv /var/lib/neo4j/clientswipes_202003.csv /var/lib/neo4j/import/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003.csv /var/lib/neo4j/import/
// sudo cp /var/lib/neo4j/import/clientswipes_202003_neo4j.csv /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/import/
// clientswipes_202003_neo4j.csv"
// sudo mv /media/lnr-ai/downloads/home/christo/data/clientswipes_202003_PBCVM.csv /var/lib/neo4j/import/
// sudo unzip wetransfer-186086.zip -d /media/lnr-ai/christo/github_repos/logistics/data/
// sudo unzip /media/lnr-ai/downloads/wetransfer-a7b903.zip -d /media/lnr-ai/christo/github_repos/logistics/data/
// sudo unzip /media/lnr-ai/downloads/nedbankresignation.zip -d /media/lnr-ai/christo/nedbankresignation/
// cd /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/
// <!-- check consistency: -->
// sudo unzip /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202008_PBCVM.zip -d /var/lib/neo4j/import/
// ---------------------------------------------------------------------------------------------------------------------------
// sudo unzip /media/lnr-ai/christo/github_repos/money_personalities/data/clientdb_catchall_aggregated.zip -d /media/lnr-ai/christo/github_repos/money_personalities/data/
// ---------------------------------------------------------------------------------------------------------------------------
// sudo /usr/bin/neo4j-admin check-consistency --database=clientswipes_202003.db --report-dir=/media/lnr-ai/neo4j/ --verbose=true
// sudo /usr/bin/neo4j console
// sudo /usr/bin/cypher-shell -u neo4j -p newPassword

// sudo systemctl status neo4j
// sudo systemctl start neo4j
// sudo systemctl stop neo4j

// dbms.active_database=clientswipes_202003.db
// dbms.directories.data=/usr/local/data

// :SERVER change-password
// Logon credentials for the local neo4j terminal
cypher-shell -u neo4j -p NewPassword
C:\Users\christo.strydom\AppData\Local\Neo4j\Relate\Data\dbmss\dbms-dfc91feb-eeb1-4c1c-bb5b-c3a01a117a31\import
// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data
// seg_l3_num = [312,313,321,322,323,324,325,333,336]

// ./cypher-shell -u neo4j -p newPassword

// https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-18-04/
// https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
// CLEAR swap space: swapoff -a && swapon -a

CREATE CONSTRAINT ON (c:Condition) ASSERT c.icd10_fk IS UNIQUE;
CREATE CONSTRAINT ON (p:Practice) ASSERT p.practice_no IS UNIQUE;
CREATE CONSTRAINT ON (p:Patient) ASSERT p.ms_fk_id IS UNIQUE;
CREATE CONSTRAINT ON (m:Member) ASSERT m.ms_fk IS UNIQUE;

MATCH (c:Client)
WHERE NOT c.seg_l3_num IN [312,313,321,322,323,324,325,333,336]
DETACH DELETE c;

CALL apoc.periodic.iterate("MATCH (c:Client)
WHERE NOT c.seg_l3_num IN [312,313,321,322,323,324,325,333,336] RETURN c", "DETACH DELETE c", {batchSize:500})
yield batches, total return batches, total;


MATCH (c:Client)
DETACH DELETE c;


MATCH (c:Segment)
DETACH DELETE c;

CALL apoc.periodic.iterate("MATCH (p:Patient) RETURN p", "DETACH DELETE p", {batchSize:500})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:500})
yield batches, total return batches, total;

MATCH (m:Merchant)
DETACH DELETE m;

// -Condition-------------------------------------------------------------------------------------------------------
CALL apoc.periodic.iterate("MATCH (c:Condition) RETURN c", "DETACH DELETE c", {batchSize:500})
yield batches, total return batches, total;

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MERGE (c:Condition {icd10_fk: row.icd10_fk})
ON CREATE SET c.icd10_descr = row.icd10_descr,
c.icd10_group_description = row.icd10_group_description,
c.claimed_amount = toFloat(row.claimed_amount),
c.occurence = 1
ON MATCH SET c.occurence = c.occurence + 1,
c.claimed_amount = c.claimed_amount + toFloat(row.claimed_amount)
RETURN count(c);

// -Patient-------------------------------------------------------------------------------------------------
CALL apoc.periodic.iterate("MATCH (p:Patient) RETURN p", "DETACH DELETE p", {batchSize:500})
yield batches, total return batches, total;

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MERGE (p:Patient {ms_fk_id: row.ms_fk_id})
ON CREATE SET p.dependent_no = row.dependent_no,
p.dep_type = row.dep_type,
p.gender = row.gender,
p.first_name=row.first_name,
p.surname=row.surname,
p.birth_date=row.birth_date,
p.occurence=1,
p.claimed_amount = toFloat(row.claimed_amount)
ON MATCH SET p.occurence = p.occurence + 1,
p.claimed_amount = p.claimed_amount + toFloat(row.claimed_amount)
RETURN count(p);

// -Practice----------------------------------------------------------------------------------------------------
CALL apoc.periodic.iterate("MATCH (p:Practice) RETURN p", "DETACH DELETE p", {batchSize:500})
yield batches, total return batches, total;

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MERGE (p:Practice {practice_no: row.practice_no})
ON CREATE SET p.pr_type = row.pr_type,
p.pr_type_descr = row.pr_type_descr,
p.pr_group_descr = row.pr_group_descr,
p.occurence=1,
p.claimed_amount = toFloat(row.claimed_amount)
ON MATCH SET p.occurence = p.occurence + 1,
p.claimed_amount =  p.claimed_amount + toFloat(row.claimed_amount)
RETURN count(p);

// -PRESENTED_IDC10----------------------------------------------------------------------------------------------------

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MATCH (c:Condition {icd10_fk: row.icd10_fk})
MATCH (p:Patient {ms_fk_id: row.ms_fk_id})
MERGE (p)-[r:PRESENTED_IDC10]->(c)
ON CREATE SET r.presentation_count = 1,
r.claimed_amount = toFloat(row.claimed_amount)
ON MATCH SET r.presentation_count = r.presentation_count + 1,
r.claimed_amount = r.claimed_amount + toFloat(row.claimed_amount)
RETURN count(*);

// -DIAGNOSED_IDC10----------------------------------------------------------------------------------------------------

CALL apoc.periodic.iterate("MATCH ()-[t:DIAGNOSED_IDC10]->() RETURN t", "DELETE t", {batchSize:500})
yield batches, total return batches, total;


USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MATCH (c:Condition {icd10_fk: row.icd10_fk})
MATCH (p:Practice {practice_no: row.practice_no})
MERGE (p)-[r:DIAGNOSED_IDC10]->(c)
ON CREATE SET r.diagnosis_count = 1,
r.claimed_amount = toFloat(row.claimed_amount)
ON MATCH SET r.diagnosis_count = r.diagnosis_count + 1,
r.claimed_amount = r.claimed_amount + toFloat(row.claimed_amount)
RETURN count(*);

// -VISITED----------------------------------------------------------------------------------------------------

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///icd10_fk_df.csv' AS row
MATCH (c:Patient {ms_fk_id: row.ms_fk_id})
MATCH (p:Practice {practice_no: row.practice_no})
MERGE (c)-[r:VISITED]->(p)
ON CREATE SET r.visit_count = 1,
r.claimed_amount = toFloat(row.claimed_amount)
ON MATCH SET r.visit_count = r.visit_count + 1,
r.claimed_amount = r.claimed_amount + toFloat(row.claimed_amount)
RETURN count(*);

// ---------------------------------------------------------------------------------------------------------


// 1. Here we CREATE  the SHARED_PATIENT relationship between two idc10 conditions.
CALL apoc.periodic.iterate('MATCH (condition0:Condition)<-[p0:PRESENTED_IDC10]-(patient:Patient)-[p1:PRESENTED_IDC10]->(condition1:Condition)
WHERE ID(condition0) < ID(condition1)
RETURN condition0, condition1, p0, p1;
', "MERGE (condition0)-[link:SHARED_PATIENT]-(condition1)
ON CREATE SET link.count = 1,
link.count0 = p0.presentation_count,
link.count1 = p1.presentation_count, 
link.ID0 = ID(condition0),
link.ID1 = ID(condition1),
link.claimed_amount0 = p0.claimed_amount,
link.claimed_amount1 = p1.claimed_amount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+p0.presentation_count,
link.count1 = link.count1+p1.presentation_count,
link.claimed_amount0 = link.claimed_amount0+p0.claimed_amount,
link.claimed_amount1 = link.claimed_amount1+p1.claimed_amount", {batchSize:10000, iterateList:true, retries:5})
yield batches, total return batches, total;

// Here we CORRECT the SHARED_PATIENT direction, which way did conditions go
MATCH (condition0:Condition)-[spl:SHARED_PATIENT]-(condition1:Condition)
WHERE ID(condition0)=spl.ID0 AND ID(condition1)=spl.ID1
WITH spl.count0<spl.count1 AS mustpointright, 
spl.count0>spl.count1 AS mustpointleft,
NOT (startNode(spl) = condition0) as pointsleft,
spl as relationship,(startNode(spl) = condition0) as pointsright,condition0,condition1,spl,
spl.count0 as count0,
spl.count1 as count1, spl.ID0 as ID0, spl.ID1 as ID1, spl.count as count, 
ID(spl) as rel_id
FOREACH (p IN CASE WHEN (mustpointright AND pointsleft) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (condition0)-[newrel:SHARED_PATIENT]->(condition1)
        ON CREATE SET newrel.count0 = count0,
        newrel.count1=count1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (condition0)<-[newrel:SHARED_PATIENT]-(condition1)
        ON CREATE SET newrel.count0 = count0,
        newrel.count1=count1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);

// Check that all directions match:
MATCH (c0:Condition)-[rel:SHARED_PATIENT]-(c1:Condition)
WHERE ID(c0)=rel.ID0 AND ID(c1)=rel.ID1
WITH c0,c1,rel, rel.count0<=rel.count1 AS mustpointright, 
rel.count0>rel.count1 AS mustpointleft,
NOT (startNode(rel) = c0) as pointsleft,
(startNode(rel) = c0) as pointsright
RETURN ID(c0) as IDc0, ID(c1) as IDc1, c0.icd10_descr as c0_icd10_descr,
c1.icd10_descr as c1_icd10_descr, rel.count0 as count0,
rel.count0 as count1,
mustpointright, pointsright, mustpointleft, pointsleft;


// =ICD-10 subgraph with Louvain clustering ================================================================================================================================
CALL gds.graph.drop('icd10_subgraph') YIELD graphName;

CALL gds.graph.create.cypher(
    'icd10_subgraph',
    'MATCH (c0:Condition) RETURN id(c0) AS id,  c0.occurence as occurence',
    'MATCH (c0:Condition)-[rel:SHARED_PATIENT]->(c1:Condition) WHERE rel.count>3 RETURN ID(c0) AS source, 
    ID(c1) AS target, 
    rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('icd10_subgraph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).icd10_descr AS icd10_descr, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

CALL gds.louvain.stream('icd10_subgraph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN communityId, COUNT(gds.util.asNode(nodeId).icd10_descr) as count
ORDER BY count DESC;

MATCH (condition:Condition)
WHERE EXISTS(condition.icd10_community)
REMOVE condition.icd10_community
RETURN condition.icd10_descr as icd10_descr, condition.icd10_community as icd10_community;

CALL gds.louvain.write('icd10_subgraph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'icd10_community' })
YIELD communityCount, modularity, modularities;





MATCH path=(condition0:Condition )-[spl:SHARED_PATIENT]->(condition1:Condition )
with collect(path) as paths
call apoc.gephi.add(null,'icd10_subgraph', paths, 'count', ['icd10_fk', 'icd10_descr', 'icd10_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;

MATCH (c0:Condition)
RETURN c0.icd10_descr AS icd10_descr, 
c0.occurence AS occurence, 
c0.claimed_amount AS claimed_amount, c0.claimed_amount/c0.occurence AS average_claimed_amount
ORDER BY occurence ASC;


MATCH (c0:Condition)-[s:SHARED_PATIENT]-(c1:Condition)
WHERE s.count>10
RETURN COUNT(c0) as icd10_community_count,c0.icd10_community as icd10_community,
SUM(c0.icd10_community)
ORDER BY icd10_community_count ASC;

Probabilities
MATCH (c0:Condition)-[s:SHARED_PATIENT]-(c1:Condition)
WHERE s.count>10 AND 
ID(c0) < ID(c1) AND
ID(c0) <> 10 AND
ID(c1) <> 10
RETURN c0.icd10_descr AS c0_icd10_descr
,c1.icd10_descr AS c1_icd10_descr
,100*(toFloat(s.count)/toFloat(c0.occurence)) AS c1_given_c0
,100*(toFloat(s.count)/toFloat(c1.occurence)) AS c0_given_c1
,s.count  AS shared_count
ORDER BY shared_count ASC;

MATCH (c0:Condition)-[s:SHARED_PATIENT]-(c1:Condition)
WHERE s.count>10
RETURN c0.icd10_descr AS c0_icd10_descr
,c1.icd10_descr AS c1_icd10_descr
,c0.occurence AS c1_given_c0
,c1.occurence AS c0_given_c1
,s.count  AS shared_count
ORDER BY shared_count ASC;


MATCH (c0:Condition)-[s:SHARED_PATIENT]-(c1:Condition)
WHERE s.count>10
RETURN c0.icd10_descr AS c0_icd10_descr, 
c0.occurence AS c0_occurence, 
s.count AS shared_count,
c1.icd10_descr AS c1_icd10_descr, 
c1.occurence AS c1_occurence
ORDER BY shared_count ASC;





// ======================================================================================================

MATCH (c:Client)
SET c.totaltransactionamount = apoc.number.format(toFloat(c.totaltransactionamount), "###,###.00")
RETURN c

CALL apoc.periodic.iterate("MATCH (c:Client)  RETURN c", 
"SET c.totaltransactionamount = apoc.number.format(toFloat(c.totaltransactionamount), '###,###.00')", 
{batchSize:100})
yield batches, total return batches, total;


// <!-- Create the Segment node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (s:Segment {seg_l3_num: toInteger(row.Seg_L3_Num)})
ON CREATE SET s.totaltransactionamount = toFloat(row.TransactionAmount),
s.totaltransactioncount = 1,
s.seg_l3_str=row.Seg_L3_STR,
s.period=row.period
ON MATCH SET s.totaltransactioncount = s.totaltransactioncount + 1, 
s.totaltransactionamount=s.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(s);


CALL apoc.periodic.iterate("MATCH (s:Segment)  RETURN s", 
"SET s.totaltransactionamount = apoc.number.format(toFloat(s.totaltransactionamount), '###,###.00')", 
{batchSize:100})
yield batches, total return batches, total;


// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (m:Merchant {franchisename:coalesce(row.franchisename, "Unknown")})
ON CREATE SET m.companyindex = coalesce(toInteger(row.companyindex),"Unknown"),
m.companyname = coalesce(row.companyname,"Unknown"), 
m.totaltransactioncount = 1,
m.totaltransactionamount=toFloat(row.TransactionAmount),
m.period = row.period, 
m.discretionary = coalesce(toInteger(row.discretionary),"Unknown"),
m.class_id = coalesce(toInteger(row.class_id),"Unknown"),
m.division_id = coalesce(toInteger(row.division_id),"Unknown"),
m.group_id = coalesce(toInteger(row.group_id),"Unknown"),
m.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown")
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(m);

CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN m", "DELETE m", 
{batchSize:500})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant)  RETURN m", 
"SET m.totaltransactionamount = apoc.number.format(toFloat(m.totaltransactionamount), '###,###.00')",
 {batchSize:100})
yield batches, total return batches, total;

// <!-- Delete TRANSACTED_AT relationships:-->
CALL apoc.periodic.iterate("MATCH (c:Client)-[r:TRANSACTED_AT]->(m:Merchant) RETURN r", "DELETE r", {batchSize:100})
yield batches, total return batches, total;

// <!-- Delete TRANSACTED_AT relationships:-->
CALL apoc.periodic.iterate("MATCH (m0:Merchant)-[merchant_link:MERCHANT_LINK]->(m1:Merchant) RETURN merchant_link", "DELETE merchant_link", {batchSize:100})
yield batches, total return batches, total;

// <!-- Create the Company node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (c:Company {companyname:coalesce(row.companyname, "Unknown")})
ON CREATE SET c.companyindex = coalesce(toInteger(row.companyindex),"Unknown"),
c.totaltransactioncount = 1,
c.totaltransactionamount=toFloat(row.TransactionAmount),
c.period = row.period, 
c.discretionary = coalesce(toInteger(row.discretionary),"Unknown"),
c.class_id = coalesce(toInteger(row.class_id),"Unknown"),
c.division_id = coalesce(toInteger(row.division_id),"Unknown"),
c.group_id = coalesce(toInteger(row.group_id),"Unknown"),
c.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown")
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

// <!-- ADD the channel value Company node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (m:Merchant {franchisename:coalesce(row.franchisename, "Unknown")})
SET m.channel = coalesce(toInteger(row.channel),"Unknown")
RETURN count(m);


// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
RETURN count(*);


// <!-- Create COMPANY transaction relationships here, between Client and Company: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_PBCVM.csv' AS row
MATCH (client:Client {dedupestatic: row.Dedupegroup})
MATCH (company:Company {companyname: coalesce(row.companyname, "Unknown")})
MERGE (client)-[r:COMPANY_TRANSACTED_AT]->(company)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
RETURN count(*);

// DELETE the 'UNKNOWN' Company super node
CALL apoc.periodic.iterate("MATCH (company:Company {companyname:'Unknown'}) RETURN company", "DETACH DELETE company", {batchSize:100})
yield batches, total return batches, total;


// r.universaldatelist = r.universaldatelist + toInteger(row.universaldate),
// r.transactiondatelist = r.transactiondatelist + datetime(replace(row.TransactionDate,' ','T'))
// r.transactiondatelist = [datetime(replace(row.TransactionDate,' ','T'))],
// r.universaldatelist = [toInteger(row.universaldate)],
// fix transactionamount 
// Set to 0
MERGE (c)-[r:TRANSACTED_AT]->(m)
SET t.transactionamount=0
RETURN c

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON MATCH SET r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
RETURN count(*);

// r.transactiondatelist = [datetime(replace(row.TransactionDate,' ','T'))],
// <!-- FOREACH(x in CASE WHEN toInt(row.universaldate) in r.universaldatelist THEN [] ELSE [1] END | 
//    SET r.universaldatelist = r.universaldatelist + toInt(row.universaldate)
// )
// FOREACH(x in CASE WHEN datetime(replace(row.TransactionDate,' ','T')) in r.transactiondatelist THEN [] ELSE [1] END | 
//    SET r.transactiondatelist = r.transactiondatelist + datetime(replace(row.TransactionDate,' ','T'))
// ) -->

// <!-- ========================================================================================== -->

MATCH (m0:Merchant)-[r:MERCHANT_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

ON CREATE SET m.companyindex = coalesce(toInteger(row.companyindex),"Unknown"),
m.companyname = coalesce(row.companyname,"Unknown"), 
m.totaltransactioncount = 1,
m.totaltransactionamount=toFloat(row.TransactionAmount),
m.period = row.period, 
m.discretionary = coalesce(toInteger(row.discretionary),"Unknown"),
m.class_id = coalesce(toInteger(row.class_id),"Unknown"),
m.division_id = coalesce(toInteger(row.division_id),"Unknown"),
m.group_id = coalesce(toInteger(row.group_id),"Unknown"),
m.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown")
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount)

MATCH ()-[t:TRANSACTED_AT]->(merchant:Merchant {companyname:"DISCHEM"})
WITH merchant,t, count(t) AS count
WHERE count=1
RETURN merchant.franchisename as merchant, merchant.companyname as company, count(t) as count;

// Count the number of merchant nodes with only one relationship:
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels = 2
RETURN oldm,clients, rels;

MERGE (m:Merchant {franchisename:'onetransaction_franchise'})
DETACH DELETE m

MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels = 1
MATCH (client:Client)-[oldt:TRANSACTED_AT]->(oldm)
WITH oldm,oldt,client, oldm.companyname as companyname
MERGE (newm:Merchant {companyname:companyname,franchisename:'onetransaction_franchise'})
ON CREATE
SET newm.companyindex=oldm.companyindex,
newm.companyname=oldm.companyname, 
newm.totaltransactioncount=oldm.totaltransactioncount,
newm.totaltransactionamount=oldm.totaltransactionamount,
newm.period=oldm.period, 
newm.discretionary=oldm.discretionary,
newm.class_id=oldm.class_id,
newm.division_id=oldm.division_id,
newm.group_id=oldm.group_id,
newm.subclass_id=oldm.subclass_id
ON MATCH SET newm.totaltransactioncount=newm.totaltransactioncount+oldm.totaltransactioncount, 
newm.totaltransactionamount=newm.totaltransactionamount+oldm.totaltransactionamount
MERGE (client)-[newt:TRANSACTED_AT]->(newm)
ON CREATE SET newt.transactioncount = oldt.transactioncount,
newt.transactionamount = oldt.transactionamount,
newt.period = oldt.period,
newt.db=oldt.db,
newt.dbprefix=oldt.dbprefix
ON MATCH SET newt.transactioncount = newt.transactioncount + oldt.transactioncount,
newt.transactionamount = newt.transactionamount + oldt.transactionamount
DETACH DELETE oldm
RETURN newm, oldm;

:param minimum_count=>2
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels <= $minimum_count and oldm.companyname<>'Unknown'
RETURN count(oldm) as node_count;

// Delete ALL Merchants with only 1 transaction leading to it:
// First check how many nodes in total:
MATCH (n)
RETURN COUNT(n) AS n_nodes

:param minimum_count=>2
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant) 
WITH oldm,count(client) as rels
WHERE rels <= $minimum_count and oldm.companyname='Unknown'
DETACH DELETE oldm;

CALL apoc.periodic.iterate("MATCH (m:Merchant)
WHERE m.companyname<>'Unknown'
RETURN m","DETACH DELETE m",{batchSize:100})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels = 2
MATCH (client:Client)-[oldt:TRANSACTED_AT]->(oldm)
MERGE (newm:Merchant {companyname:oldm.companyname,franchisename:oldm.companyname+'_'+ 'onetransaction_franchise'})
ON CREATE
SET newm.companyindex=oldm.companyindex,
newm.companyname=oldm.companyname, 
newm.totaltransactioncount=oldm.totaltransactioncount,
newm.totaltransactionamount=oldm.totaltransactionamount,
newm.period=oldm.period, 
newm.discretionary=oldm.discretionary,
newm.class_id=oldm.class_id,
newm.division_id=oldm.division_id,
newm.group_id=oldm.group_id,
newm.subclass_id=oldm.subclass_id
ON MATCH SET newm.totaltransactioncount=newm.totaltransactioncount+oldm.totaltransactioncount, 
newm.totaltransactionamount=newm.totaltransactionamount+oldm.totaltransactionamount
MERGE (client)-[newt:TRANSACTED_AT]->(newm)
ON CREATE SET newt.transactioncount = oldt.transactioncount,
newt.transactionamount = oldt.transactionamount,
newt.period = oldt.period,
newt.db=oldt.db,
newt.dbprefix=oldt.dbprefix
ON MATCH SET newt.transactioncount = newt.transactioncount + oldt.transactioncount,
newt.transactionamount = newt.transactionamount + oldt.transactionamount
DETACH DELETE oldm","RETURN oldm", {batchSize:100})
yield batches, total return batches, total;


MATCH ()-[t:TRANSACTED_AT]->(m:Merchant)
WITH m,t, count(t) AS t
WHERE count=1
RETURN m.franchisename as merchant, m.companyname as company, count(t) as count;

CALL apoc.periodic.iterate("MATCH (c0:Company)-[ctt:COMPANY_TRANSACTED_AT]-(c1:Company)
WHERE ID(c0)<ID(c1)
RETURN ctt","DELETE ctt",{batchSize:100})
yield batches, total return batches, total;


CALL apoc.periodic.iterate("MATCH (c0:Company)-[ctt:COMPANY_LINK]-(c1:Company)
WHERE ID(c0)<ID(c1)
RETURN ctt","DELETE ctt",{batchSize:100})
yield batches, total return batches, total;


// For COMPANIES:
CALL apoc.periodic.iterate("MATCH (company0:Company)<-[ctt0:COMPANY_TRANSACTED_AT]-(client:Client)-[ctt1:COMPANY_TRANSACTED_AT]->(company1:Company)
WHERE ID(company0) < ID(company1)
RETURN company0, company1, ctt0, ctt1",
"MERGE (company0)-[link:COMPANY_LINK]-(company1)
ON CREATE SET link.count = 1,
link.count0 = ctt0.count,
link.count1= ctt1.count, 
link.ID0=ID(company0),
link.ID1=ID(company1),
link.transactioncount0 = ctt0.transactioncount,
link.transactioncount1 = ctt1.transactioncount,
link.transactionamount0 = ctt0.transactionamount,
link.transactionamount1 = ctt1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+ctt0.count,
link.count1 = link.count1+ctt1.count,
link.transactioncount0 = link.transactioncount0+ctt0.transactioncount,
link.transactioncount1 = link.transactioncount1+ctt1.transactioncount,
link.transactionamount0 = link.transactionamount0+ctt0.transactionamount,
link.transactionamount1 = link.transactionamount1+ctt1.transactionamount
RETURN link", {batchSize:10, iterateList:true, parallel:true})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (c:Company)
WHERE c.companyname='Unknown'
RETURN c","DETACH DELETE c",{batchSize:100})
yield batches, total return batches, total;

// For MERCHANTS:
CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1",
"MERGE (merchant0)-[link:MERCHANT_LINK]-(merchant1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(merchant0),
link.ID1=ID(merchant1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+t0.count,
link.count1 = link.count1+t1.count,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN link", {batchSize:100})
yield batches, total return batches, total;

// This is only for DISCHEM and CLICKS:
CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND merchant0.companyname IN ['DISCHEM', 'CLICKS'] AND merchant1.companyname IN ['DISCHEM', 'CLICKS']
RETURN merchant0, merchant1, t0, t1","
MERGE (merchant0)-[link:MERCHANT_LINK]-(merchant1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(merchant0),
link.ID1=ID(merchant1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+t0.count,
link.count1 = link.count1+t1.count,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN link", {batchSize:100})
yield batches, total return batches, total;

MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.companyname IN ['DISCHEM', 'CLICKS'] AND 
merchant1.companyname IN ['DISCHEM', 'CLICKS']
MERGE (merchant0)-[link:MERCHANT_LINK]-(merchant1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(merchant0),
link.ID1=ID(merchant1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+t0.count,
link.count1 = link.count1+t1.count,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN count(link);

// 
MATCH p=(m0:Merchant)-[rel:MERCHANT_LINK]-(m1:Merchant)
WHERE m0.companyname = 'DISCHEM' AND m1.companyname='CLICKS'
RETURN m0.franchisename as dischem_branch, 
apoc.number.format(toFloat(m0.totaltransactionamount), "###,###.00") as dischem_branch_amount,
m1.franchisename as clicks_branch,
m1.totaltransactionamount as clicks_branch_amount,
rel.transactionamount0 as m0_value_contribution, 
rel.transactionamount1 as m1_value_contribution, 
rel.count as feet
ORDER BY feet DESC;


// =The FEET edge========================================================================================= -->

MATCH (m0:Merchant)-[rel:MERCHANT_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
RETURN ID(m0) as ID_m0, ID(m1) as ID_m1

MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

// Here we CREATE MERCHANT_FEET_LINK:
MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.companyname IN ['NANDOS'] AND 
merchant1.companyname IN ['NANDOS']
MERGE (merchant0)-[link:MERCHANT_FEET_LINK]-(merchant1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(merchant0),
link.ID1=ID(merchant1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+t0.count,
link.count1 = link.count1+t1.count,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN count(link);

// Count relationships:
MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]-(m1:Merchant)  
WHERE ID(m0)<ID(m1)
RETURN COUNT(r) as count;
// =258,060

// Here we CORRECT the MERCHANT_LINK_FEET direction, which way did feet move
MATCH (m0:Merchant)-[rel:MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH rel.transactioncount0<rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
rel as relationship,(startNode(rel) = m0) as pointsright,m0,m1,rel,
rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1, rel.ID0 as ID0, rel.ID1 as ID1, rel.count as count, 
ID(rel) as rel_id
FOREACH (p IN CASE WHEN (mustpointright AND pointsleft) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)-[newrel:MERCHANT_FEET_LINK]->(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:MERCHANT_FEET_LINK]-(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);

// Count relationships:
MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]-(m1:Merchant)  
WHERE ID(m0)<ID(m1)
RETURN COUNT(r) as count;
// = 258,060

// Check that all directions match:
MATCH (m0:Merchant)-[rel:MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactioncount0<=rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, m0.franchisename as franchisename1,
m1.franchisename as franchisename2, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;

MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

MATCH (m0:Merchant)-[mfl:MERCHANT_FEET_LINK]->(m1:Merchant {franchisename:"DISCHEM WORCESTER"}) 
RETURN m0.franchisename as franchisename, mfl.count as count, m1.franchisename as target
ORDER BY count ASC

:param minimum_count=>1
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {companyname:"CLICKS"}) 
WITH oldm,count(client) as rels
WHERE rels <= $minimum_count 
DETACH DELETE oldm;

:param minimum_count=>1
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {companyname:"DISCHEM"}) 
WITH oldm,count(client) as rels
WHERE rels <= $minimum_count 
DETACH DELETE oldm;

:param minimum_count=>1
MATCH (m0:Merchant)-[mfl:MERCHANT_FEET_LINK]-(m1:Merchant) 
WHERE ID(m0)<ID(m1) AND mfl.count=1
DELETE mfl;
RETURN m0.franchisename as franchisename0, m1.franchisename as franchisename1, mfl.count as count;


:param minimum_count=1
MATCH (m0:Merchant)-[mfl:MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)<ID(m1)
RETURN m0.franchisename as franchisename0, m1.franchisename as franchisename1, mfl.count as count
// WITH oldm,count(client) as rels
// WHERE rels <= $minimum_count and oldm.companyname='Unknown'
// DETACH DELETE oldm;

// Create graph:
CALL gds.graph.create(
    'DischemClicksFeetGraph',
    'Merchant',
    'MERCHANT_FEET_LINK',
    {
        relationshipProperties: 'count'
    }
);

// verify graph existence:
CALL gds.graph.list()
YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
      nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime;

CALL gds.pageRank.stream('DischemClicksFeetGraph', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;



// =The VALUE edge========================================================================================= -->

MATCH (m0:Merchant)-[rel:MERCHANT_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
RETURN ID(m0) as ID_m0, ID(m1) as ID_m1

MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]->(m1:Merchant)  
DELETE r;

// Here we CREATE MERCHANT_VALUE_LINK:
MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.companyname IN ['DISCHEM', 'CLICKS'] AND 
merchant1.companyname IN ['DISCHEM', 'CLICKS']
MERGE (merchant0)-[link:MERCHANT_VALUE_LINK]-(merchant1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(merchant0),
link.ID1=ID(merchant1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.count0 = link.count0+t0.count,
link.count1 = link.count1+t1.count,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN count(link);

// Count relationships:
MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]-(m1:Merchant)  
WHERE ID(m0)<ID(m1)
RETURN COUNT(r) as count;
// =258,060

// Here we CORRECT the MERCHANT_LINK_FEET direction, which way did feet move
MATCH (m0:Merchant)-[rel:MERCHANT_VALUE_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH rel.transactionamount0>rel.transactionamount1 AS mustpointright, 
rel.transactionamount0<rel.transactionamount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
rel as relationship,(startNode(rel) = m0) as pointsright,m0,m1,rel,
rel.transactionamount0 as transactionamount0,
rel.transactionamount1 as transactionamount1, rel.ID0 as ID0, rel.ID1 as ID1, rel.count as count, 
ID(rel) as rel_id
FOREACH (p IN CASE WHEN (mustpointright AND pointsleft) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)-[newrel:MERCHANT_VALUE_LINK]->(m1)
        ON CREATE SET newrel.transactionamount0 = transactionamount0,
        newrel.transactionamount1=transactionamount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:MERCHANT_VALUE_LINK]-(m1)
        ON CREATE SET newrel.transactionamount0 = transactionamount0,
        newrel.transactionamount1=transactionamount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);

// Count relationships:
MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]-(m1:Merchant)  
WHERE ID(m0)<ID(m1)
RETURN COUNT(r) as count;
// = 258,060

// Check that all directions match:
MATCH (m0:Merchant)-[rel:MERCHANT_VALUE_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactionamount0>=rel.transactionamount1 AS mustpointright, 
rel.transactionamount0<rel.transactionamount1 AS mustpointleft,
(startNode(rel) = m1) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, rel.transactionamount0 as transactionamount0,
rel.transactionamount1 as transactionamount1,
mustpointright, pointsright, mustpointleft, pointsleft;

MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

// The VALUE edge =THIS IS NOW REDUNDANT!!!=================================================================================
// Create the TEMP_MERCHANT_LINK_VALUE edge:
// MATCH (m0:Merchant)-[r:MERCHANT_LINK_VALUE]->(m1:Merchant)  
// DELETE r;

// MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]->(m1:Merchant)  
// DELETE r;

// MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
// WHERE ID(merchant0) < ID(merchant1) AND 
// merchant0.companyname IN ['DISCHEM', 'CLICKS'] AND 
// merchant1.companyname IN ['DISCHEM', 'CLICKS']
// MERGE (merchant0)-[link:MERCHANT_VALUE_LINK]-(merchant1)
// ON CREATE SET link.count = 1,
// link.count0 = t0.count,
// link.count1= t1.count, 
// link.ID0=ID(merchant0),
// link.ID1=ID(merchant1),
// link.transactioncount0 = t0.transactioncount,
// link.transactioncount1 = t1.transactioncount,
// link.transactionamount0 = t0.transactionamount,
// link.transactionamount1 = t1.transactionamount
// ON MATCH SET link.count = link.count + 1,
// link.count0 = link.count0+t0.count,
// link.count1 = link.count1+t1.count,
// link.transactioncount0 = link.transactioncount0+t0.transactioncount,
// link.transactioncount1 = link.transactioncount1+t1.transactioncount,
// link.transactionamount0 = link.transactionamount0+t0.transactionamount,
// link.transactionamount1 = link.transactionamount1+t1.transactionamount
// RETURN count(link);

// // Correct the direction 
// MATCH (m0:Merchant)-[rel:MERCHANT_LINK_VALUE]-(m1:Merchant)
// WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
// WITH rel.transactionamount0>rel.transactionamount1 AS mustpointright, 
// rel.transactionamount0<rel.transactionamount1 AS mustpointleft,
// rel as relationship,(startNode(rel) = m0) as isright,m0,m1,rel,
// NOT (startNode(rel) = m0) as isleft,
// rel.transactionamount0 as transactionamount0,
// rel.transactionamount1 as transactionamount1, rel.ID0 as ID0, rel.ID1 as ID1, rel.count as count, 
// ID(rel) as rel_id
// FOREACH (p IN CASE WHEN (mustpointright AND isleft) THEN [1] ELSE [] END |
//     MERGE (m0)-[newrel:MERCHANT_LINK_VALUE]->(m1)
//         ON CREATE SET newrel.transactionamount0 = transactionamount0,
//         newrel.transactionamount1=transactionamount1,
//         newrel.ID0=ID0,
//         newrel.ID1=ID1,
//         newrel.count=count
//         DELETE rel
// )
// FOREACH (p IN CASE WHEN (mustpointleft and isright) THEN [1] ELSE [] END |
//     MERGE (m0)<-[newrel:MERCHANT_LINK_VALUE]-(m1)
//         ON CREATE SET newrel.transactionamount0 = transactionamount0,
//         newrel.transactionamount1=transactionamount1,
//         newrel.ID0=ID0,
//         newrel.ID1=ID1, 
//         newrel.count=count
//         DELETE rel
// );


// // Check 
// MATCH (m0:Merchant)-[rel:MERCHANT_LINK]-(m1:Merchant)
// WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
// WITH rel.transactioncount0<rel.transactioncount1 AS pointright, 
// rel as relationship,(startNode(rel) = m0) as isright,m0,m1,
// rel.transactioncount0 as count0,rel.transactioncount1 as count1, rel.ID0 as ID0, rel.ID1 as ID1, rel.count as count, 
// ID(rel) as rel_id
// RETURN pointright, isright, NOT isright AS isleft ;


// // 
// MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]->(m1:Merchant)  
// WHERE m0<>m1
// DELETE r;

// DELETE all MERCHANT_LINKS ====================================================================
CALL apoc.periodic.iterate("MATCH (m0:Merchant)-[r:MERCHANT_LINK]-(m1:Merchant)
WHERE ID(m0)<ID(m1) 
RETURN r","DELETE r",{batchSize:100})
yield batches, total return batches, total;


MATCH (merchant0:Merchant {companyname: 'DISCHEM'})<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant {companyname: 'DISCHEM'})
WHERE merchant0.franchisename<>merchant1.franchisename 
WITH t0.transaction_count as tc0, merchant1, merchant0,
t1.transaction_count as tc1
CASE
WHEN tc0>tc1
THEN 1
WHEN n.age < 40
THEN 2
ELSE 3 END AS result
MERGE (merchant0)-[link:MERCHANT_VALUE_LINK]-(merchant1)
ON CREATE SET link.count = 1
ON MATCH SET link.count = link.count + 1
RETURN merchant0, merchant1;

CASE
WHEN n.eyes = 'blue'
THEN 1
WHEN n.age < 40
THEN 2
ELSE 3 END AS result


<!-- https://neo4j.com/docs/graph-data-science/current/algorithms/page-rank/ -->
CALL gds.graph.create(
    'DischemClicksGraph',
    'Merchant',
    'MERCHANT_LINK_FEET',
    {
        relationshipProperties: 'count'
    }
);
// CALL gds.algo.pageRank.stream('my-native-graph') YIELD nodeId, score;
CALL gds.pageRank.stream('DischemClicksGraph', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;


CALL gds.pageRank.stream('DischemClicksGraph', {
  maxIterations: 20,
  dampingFactor: 0.85,
  relationshipWeightProperty: 'count'
})
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;



CALL gds.pageRank.write('DischemGraph', {
  maxIterations: 20,
  dampingFactor: 0.85,
  writeProperty: 'pagerank',
  relationshipWeightProperty: 'count'
})
YIELD nodePropertiesWritten AS writtenProperties, ranIterations;

MATCH (client:Client)-[:TRANSACTED_AT]-(m:Merchant) 
WHERE m.franchisename IN ['PNP CRP DEINFERN SQUAR','WOOLWORTHS MAROUN SQ','Spar Broadacres Spar','Clicks Dairnfern']
WHERE NOT (client)-[:TRANSACTED_AT]-(m:Merchant {franchisename:'DIS-CHEM DAINFERN'})
RETURN client

// = The 56101 project =================================================================================================
// In  this project we only look at merchants belonging to the subclass_id = 56101 (fast foods).
// The goal is to investigate the quality of community detection using the Louvain algorithm in the Neo4j db
// Can we cluster these into discernible hubs, how many would here be  and does it separate clients on the same basis?

MATCH (n:Merchant {subclass_id:56101}) WHERE NOTRETURN n LIMIT 25


// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 2 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_2]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

CALL apoc.periodic.iterate("USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, 'Unknown')}) 
RETURN row, c, m",
"FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 2 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_2]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
)",{batchSize:100})
yield batches, total return batches, total;


// =ICD-10 subgraph with Louvain clustering ================================================================================================================================
CALL gds.graph.drop('allco_merchant_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'allco_merchant_graph',
    'MATCH (m0:Merchant) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:ALLCO_MERCHANT_FEET_LINK]->(m1:Merchant) WHERE rel.count>3 RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('allco_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

CALL gds.louvain.stream('allco_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN communityId, COUNT(gds.util.asNode(nodeId).franchisename) as count
ORDER BY count DESC;

MATCH (merchant:Merchant)
WHERE EXISTS(merchant.allco_merchant_community)
REMOVE merchant.allco_merchant_community
RETURN merchant.franchisename as franchisename, merchant.allco_merchant_community as allco_merchant_community;

CALL gds.louvain.write('allco_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'allco_merchant_community' })
YIELD communityCount, modularity, modularities;

// connect and push to gephi =======================================================================================================
MATCH (m:Merchant)
RETURN COUNT(m.allco_merchant_community) as membercount, m.allco_merchant_community as allco_merchant_community
ORDER BY membercount ASC;

MATCH (m:Merchant)
WITH COUNT(m.allco_merchant_community) as membercount, m.allco_merchant_community as allco_merchant_community
WHERE membercount>10
MATCH path=(merchant0:Merchant {allco_merchant_community:allco_merchant_community})-[mfl:ALLCO_MERCHANT_FEET_LINK]->(merchant1:Merchant {allco_merchant_community:allco_merchant_community})
with collect(path) as paths
call apoc.gephi.add(null,'allco_merchant_graph', paths, 'count', ['companyname', 'franchisename', 'allco_merchant_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;



