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
// seg_l3_num = [312,313,321,322,323,324,325,333,336]

./cypher-shell -u neo4j -p newPassword

// https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-18-04/
// https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
// CLEAR swap space: swapoff -a && swapon -a

CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;
CREATE CONSTRAINT ON (s:Segment) ASSERT s.seg_l3_num IS UNIQUE;

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

CALL apoc.periodic.iterate("MATCH (c:Client) RETURN c", "DETACH DELETE c", {batchSize:500})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:500})
yield batches, total return batches, total;

MATCH (m:Merchant)
DETACH DELETE m;

// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.seg_l3_num=toInteger(row.Seg_L3_Num),
c.seg_l3_str=row.Seg_L3_STR,
c.seg_l2_num=toInteger(row.Seg_L2_Num),
c.seg_l2_str=row.Seg_L2_STR,
c.period=row.period
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
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
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
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



// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 2 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_2]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 3 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_3]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 4 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_4]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 5 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_5]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 6 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_6]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 7 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_7]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);


// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///woolworths_benmore.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
FOREACH(ignoreMe IN CASE WHEN toInteger(row.universaldate) = 7 THEN [1] ELSE [] END|
    MERGE (c)-[r:TRANSACTED_ON_UD_7]->(m) 
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount)
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
);

// <!-- Delete TRANSACTED_AT relationships:-->
CALL apoc.periodic.iterate("MATCH (m0:Merchant)-[r:SAME_DAY_MERCHANT_LINK]-(m1:Merchant) WHERE ID(m0)<>ID(m1) RETURN r", "DELETE r", {batchSize:100})
yield batches, total return batches, total;



CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_2]-(client:Client)-[t1:TRANSACTED_ON_UD_2]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_3]-(client:Client)-[t1:TRANSACTED_ON_UD_3]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_4]-(client:Client)-[t1:TRANSACTED_ON_UD_4]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_5]-(client:Client)-[t1:TRANSACTED_ON_UD_5]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_6]-(client:Client)-[t1:TRANSACTED_ON_UD_6]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)<-[t0:TRANSACTED_ON_UD_7]-(client:Client)-[t1:TRANSACTED_ON_UD_7]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
RETURN merchant0, merchant1,t0,t1",
"MERGE (merchant0)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1)
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


MATCH (merchant0:Merchant)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1:Merchant)
WHERE ID(merchant0)<>ID(merchant1)
RETURN merchant0.franchisename as franchisename0, merchant1.franchisename as franchisename1, link.count as same_day_transactions
ORDER BY same_day_transactions;


MATCH (merchant0:Merchant)-[link:SAME_DAY_MERCHANT_LINK]-(merchant1:Merchant)
WHERE ID(merchant0)<>ID(merchant1)
RETURN merchant0.franchisename as franchisename0, merchant1.franchisename as franchisename1, link.count as same_day_transactions
ORDER BY franchisename0;

