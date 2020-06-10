// CALL gds.graph.list()
// YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
//       nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime;
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003_neo4j.csv /var/lib/neo4j/
// sudo cp /var/lib/neo4j/import/clientswipes_202003_neo4j.csv /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/import/
// clientswipes_202003_neo4j.csv"

// cd /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/
// <!-- check consistency: -->

// sudo /usr/bin/neo4j-admin check-consistency --database=clientswipes_202003.db --report-dir=/media/lnr-ai/neo4j/ --verbose=true
// sudo /usr/bin/neo4j console
// sudo /usr/bin/cypher-shell -u neo4j -p newPassword

// sudo systemctl status neo4j
// sudo systemctl start neo4j
// sudo systemctl stop neo4j

// dbms.active_database=clientswipes_202003.db
// dbms.directories.data=/usr/local/data

// :SERVER change-password
// ./cypher-shell -u neo4j -p newPassword
./cypher-shell -u neo4j -p neo4j
// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data
./cypher-shell -u neo4j -p newPassword

// https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-18-04/
// https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
// CLEAR swap space: swapoff -a && swapon -a

CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;
CREATE CONSTRAINT ON (s:Segment) ASSERT s.seg_l3_num IS UNIQUE;

MATCH (c:Client)
DETACH DELETE c;

MATCH (m:Merchant)
DETACH DELETE m;

MATCH (c:Segment)
DETACH DELETE c;

CALL apoc.periodic.iterate("MATCH (c:Client) RETURN c", "DETACH DELETE c", {batchSize:500})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:500})
yield batches, total return batches, total;

// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.seg_l3_num=toInteger(row.Seg_L3_Num),
c.seg_l3_str=row.Seg_L3_STR,
c.period=row.period
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

MATCH (c:Client)
SET c.totaltransactionamount = apoc.number.format(toFloat(c.totaltransactionamount), "###,###.00")
RETURN c


CALL apoc.periodic.iterate("MATCH (c:Client)  RETURN c", 
"SET c.totaltransactionamount = apoc.number.format(toFloat(c.totaltransactionamount), '###,###.00')", 
{batchSize:100})
yield batches, total return batches, total;


// <!-- Create the Segment node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
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
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
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
{batchSize:100})
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
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
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


// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
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
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_sandbox.csv' AS row
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
WHERE ID(merchant0) < ID(merchant1) 
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
RETURN ID(m0) as IDm0, ID(m1) as IDm1, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;

MATCH (m0:Merchant)-[r:MERCHANT_FEET_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

// Create graph:
CALL gds.graph.create(
    'merchant_feet_link_graph',
    'Merchant',
    'MERCHANT_FEET_LINK',
    {
        relationshipProperties: 'transactioncount'
    }
);

// verify graph existence:
CALL gds.graph.list()
YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
      nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime;

CALL gds.pageRank.stream('merchant_feet_link_graph', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

// =Community detection===================================================================================

CALL gds.graph.create(
    'myGraph',
    'Merchant',
    {
        MERCHANT_FEET_LINK: {
            orientation: 'NATURAL'
        }
    },
    {
        nodeProperties: 'totaltransactioncount',
        relationshipProperties: 'count'
    }
);


CALL gds.louvain.stream('merchant_feet_link_graph')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY franchisename ASC;
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