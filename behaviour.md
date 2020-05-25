
sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003_neo4j.csv /var/lib/neo4j/
sudo cp /var/lib/neo4j/import/clientswipes_202003_neo4j.csv /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/import/
clientswipes_202003_neo4j.csv"

cd /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/



sudo /usr/bin/cypher-shell -u neo4j -p newPassword

sudo systemctl status neo4j
sudo systemctl start neo4j
sudo systemctl stop neo4j

journalctl -e -u neo4j

cd /usr/local/data
sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins


CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;

MATCH (c:Client)
DETACH DELETE c;
MATCH (m:Merchant)
DETACH DELETE m;


USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_neo4j.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.transactionamount = toFloat(row.TransactionAmount),
c.transactioncount = 1
ON MATCH SET c.transactioncount = c.transactioncount + 1, 
c.transactionamount=c.transactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_neo4j.csv' AS row
MERGE (m:Merchant {franchisename:coalesce(row.franchisename, "Unknown")})
ON CREATE SET m.companyindex = coalesce(row.companyindex,"Unknown"),
m.companyname = coalesce(row.companyname,"Unknown"), 
m.transactioncount = 1,
m.transactionamount=toFloat(row.TransactionAmount),
m.discretionary = coalesce(toInt(row.discretionary),"Unknown"),
m.channel = coalesce(toInt(row.channel),"Unknown"),
m.class_id = coalesce(toInt(row.class_id),"Unknown"),
m.division_id = coalesce(toInt(row.division_id),"Unknown"),
m.group_id = coalesce(toInt(row.group_id),"Unknown"),
m.subclass_id = coalesce(toInt(row.subclass_id),"Unknown"),
ON MATCH SET m.transactioncount = m.transactioncount + 1, 
m.transactionamount=m.transactionamount+toFloat(row.TransactionAmount)
RETURN count(m);

<!-- Delete TRANSACTED_AT transactions ======================================================== -->

CALL apoc.periodic.iterate("MATCH (c:Client)-[r:TRANSACTED_AT]->(m:Merchant) RETURN r", "DELETE r", {batchSize:1000})
yield batches, total return batches, total;

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: row.franchisename})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON CREATE SET r.transaction_date = [datetime(replace(row.TransactionDate,' ','T'))],
r.universaldate = toInt(row.universaldate),
r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount)
ON MATCH SET r.transactiondate = r.transactiondate + datetime(replace(row.TransactionDate,' ','T')),
r.transactioncount = r.transactioncount + 1
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
RETURN count(*);
<!-- ========================================================================================== -->

MATCH (m0:Merchant)-[r:MERCHANT_LINK]->(m1:Merchant)  
WHERE m0<>m1
DELETE r;

MATCH (merchant0:Merchant {companyname: 'DISCHEM'})<-[:TRANSACTED_AT]-(client:Client)-[:TRANSACTED_AT]->(merchant1:Merchant {companyname: 'DISCHEM'})
WHERE merchant0.franchisename<>merchant1.franchisename 
MERGE (merchant0)-[link:MERCHANT_LINK]-(merchant1)
ON CREATE SET link.count = 1
ON MATCH SET link.count = link.count + 1
RETURN merchant0, merchant1;

<!-- ========================================================================================== -->

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