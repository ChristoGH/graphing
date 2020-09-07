
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
// /usr/bin/cypher-shell -u neo4j -p newPassword
// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data

CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;
CREATE CONSTRAINT ON (s:Segment) ASSERT s.seg_l3_num IS UNIQUE;

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
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.seg_l3_num=toInt(row.Seg_L3_Num),
c.seg_l3_str=row.Seg_L3_STR,
c.period=row.period
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

// <!-- Create the Segment node here: -->
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (c:Segment {seg_l3_num: row.Seg_L3_Num})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.seg_l3_str=row.Seg_L3_STR,
c.period=row.period
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);


// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MERGE (m:Merchant {franchisename:coalesce(row.franchisename, "Unknown")})
ON CREATE SET m.companyindex = coalesce(toInt(row.companyindex),"Unknown"),
m.companyname = coalesce(row.companyname,"Unknown"), 
m.totaltransactioncount = 1,
m.totaltransactionamount=toFloat(row.TransactionAmount),
m.period = row.period, 
m.discretionary = coalesce(toInt(row.discretionary),"Unknown"),
m.class_id = coalesce(toInt(row.class_id),"Unknown"),
m.division_id = coalesce(toInt(row.division_id),"Unknown"),
m.group_id = coalesce(toInt(row.group_id),"Unknown"),
m.subclass_id = coalesce(toInt(row.subclass_id),"Unknown")
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(m);

// <!-- Delete TRANSACTED_AT relationships:-->
CALL apoc.periodic.iterate("MATCH (c:Client)-[r:TRANSACTED_AT]->(m:Merchant) RETURN r", "DELETE r", {batchSize:100})
yield batches, total return batches, total;

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
r.transactiondatelist = [datetime(replace(row.TransactionDate,' ','T'))],
r.universaldatelist = [toInt(row.universaldate)],
r.dbprefix=row.dbprefix
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount),
r.universaldatelist = r.universaldatelist + toInt(row.universaldate),
r.transactiondatelist = r.transactiondatelist + datetime(replace(row.TransactionDate,' ','T'))
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

MATCH (merchant0:Merchant)<-[:TRANSACTED_AT]-(client:Client)-[:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1)
MERGE (merchant0)-[link:MERCHANT_LINK]-(merchant1)
ON CREATE SET link.count = 1
mutual_shop.count0 = shopped0.count,
mutual_shop.count1=shopped1.count, mutual_shop.n = 1,
mutual_shop.ID0=ID(shop0),
mutual_shop.ID1=ID(shop1)

ON MATCH SET link.count = link.count + 1
RETURN merchant0, merchant1;

// <!-- ========================================================================================== -->

MATCH (m0:Merchant)-[r:MERCHANT_VALUE_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

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
    'DischemGraph',
    'Merchant',
    'MERCHANT_LINK',
    {
        relationshipProperties: 'count'
    }
);

CALL gds.pageRank.stream('DischemGraph', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;


CALL gds.pageRank.stream('DischemGraph', {
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