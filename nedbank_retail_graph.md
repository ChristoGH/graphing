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
// cd /home/lnr-ai/.config/Neo4j\ Desktop/Application/neo4jDatabases/database-c8878123-c937-4a52-9271-227eec393f53/installation-4.0.3/
// <!-- check consistency: -->
// sudo unzip /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202008_PBCVM.zip -d /var/lib/neo4j/import/
// sudo unzip /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202007_PBCVM.zip -d /var/lib/neo4j/import/
// sudo unzip /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202009_PBCVM.zip -d /var/lib/neo4j/import/

// sudo mv /var/lib/neo4j/import/home/christo/data/clientswipes_202007_PBCVM.csv /var/lib/neo4j/import/
// sudo mv /var/lib/neo4j/import/home/christo/data/clientswipes_202008_PBCVM.csv /var/lib/neo4j/import/
// sudo mv /var/lib/neo4j/import/home/christo/data/clientswipes_202009_PBCVM.csv /var/lib/neo4j/import/

// sudo mv /var/lib/neo4j/import/clientswipes_202007_PBCVM.csv /media/lnr-ai/christo/github_repos/graphing/data/
// sudo mv /var/lib/neo4j/import/clientswipes_202008_PBCVM.csv /media/lnr-ai/christo/github_repos/graphing/data/
// sudo mv /var/lib/neo4j/import/clientswipes_202009_PBCVM.csv /media/lnr-ai/christo/github_repos/graphing/data/
// sudo mv /var/lib/neo4j/import/clientswipes_202003.csv /media/lnr-ai/christo/github_repos/graphing/data/

// sudo mv /var/lib/neo4j/import/clientswipes_202003_PBCVM.csv /media/lnr-ai/christo/github_repos/graphing/data/
// sudo mv /var/lib/neo4j/import/clientswipes_202003_neo4j.csv /media/lnr-ai/christo/github_repos/graphing/data/
// sudo mv /var/lib/neo4j/import/clientswipes_202008_PBCVM.csv /media/lnr-ai/christo/github_repos/graphing/data/

// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202007_PBCVM.csv /var/lib/neo4j/import/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202008_PBCVM.csv /var/lib/neo4j/import/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202009_PBCVM.csv /var/lib/neo4j/import/

// sudo /usr/bin/neo4j-admin check-consistency --database=clientswipes_202003.db --report-dir=/media/lnr-ai/neo4j/ --verbose=true
// sudo /usr/bin/neo4j console
// sudo /usr/bin/cypher-shell -u neo4j -p newPassword

// sudo systemctl status neo4j
// sudo systemctl start neo4j
// sudo systemctl stop neo4j

// dbms.active_database=clientswipes_202003.db
// dbms.directories.data=/usr/local/data

// :SERVER change-password

// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data
// seg_l3_num = [312,313,321,322,323,324,325,333,336]

// ./cypher-shell -u neo4j -p newPassword


CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;
// CREATE CONSTRAINT ON (s:Segment) ASSERT s.seg_l3_num IS UNIQUE;
CREATE CONSTRAINT ON (c:Company) ASSERT c.companyname IS UNIQUE;

CALL apoc.periodic.iterate("MATCH (c:Client) RETURN c", "DETACH DELETE c", {batchSize:2000, iterateList:true})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:2000, iterateList:true})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (c:Client)-[t:TRANSACTED_AT]-(m:Merchant) RETURN t", "DELETE t", {batchSize:2000, iterateList:true})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:2000, iterateList:true})
yield batches, total return batches, total;

// 1. =202007============================================================================================================================
// <!-- Create the 202007 Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202007_PBCVM.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.period=row.period,
c:client_202007 
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount),
c.period_202007=1,
c:client_202007 
RETURN count(c);

// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202007_PBCVM.csv' AS row
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
m.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown"),
m.period_202007=1,
m:merchant_202007
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount),
m.period_202007=1,
m:merchant_202007
RETURN count(m);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202007_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix,
r.period_202007=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount),
r.period_202007=1
RETURN count(*);

MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN COUNT(m)
CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN m", "DETACH DELETE m", 
{batchSize:100, iterateList:true})
yield batches, total return batches, total;

MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN COUNT(m)
CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.totaltransactioncount=1 RETURN m", "DETACH DELETE m", 
{batchSize:100, iterateList:true})
yield batches, total return batches, total;

// <!-- Create the TRANSACTED_202007_AT relationships here for the period under consideratio, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202007_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_202007_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
// r.period_202008=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
// r.period_202008=1
RETURN count(*);


// 2. =202008============================================================================================================================
// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202008_PBCVM.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.period=row.period,
c:client_202008
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount),
c.period_202008=1,
c:client_202008
RETURN count(c);


// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202008_PBCVM.csv' AS row
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
m.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown"),
m.period_202008=1,
m:merchant_202008
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount),
m.period_202008=1,
m:merchant_202008
RETURN count(m);

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202008_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix,
r.period_202008=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount),
r.period_202008=1
RETURN count(*);


// MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN COUNT(m)
CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN m", "DETACH DELETE m", 
{batchSize:5000, iterateList:true})
yield batches, total return batches, total;

// MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN COUNT(m)
CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.totaltransactioncount=1 RETURN m", "DETACH DELETE m", 
{batchSize:5000, iterateList:true})
yield batches, total return batches, total;


// <!-- Create the TRANSACTED_202008_AT relationships here for the period under consideratio, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202008_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_202008_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
// r.period_202008=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
// r.period_202008=1
RETURN count(*);


// =202009============================================================================================================================
// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202009_PBCVM.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.period=row.period,
c:client_202009
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount),
c.period_202009=1,
c:client_202009
RETURN count(c);


// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202009_PBCVM.csv' AS row
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
m.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown"),
m.period_202009=1,
m:merchant_202009
ON MATCH SET m.totaltransactioncount = m.totaltransactioncount + 1, 
m.totaltransactionamount=m.totaltransactionamount+toFloat(row.TransactionAmount),
m.period_202009=1,
m:merchant_202009
RETURN count(m);


MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN COUNT(m)
CALL apoc.periodic.iterate("MATCH (m:Merchant) WHERE m.companyname='Unknown' RETURN m", "DETACH DELETE m", 
{batchSize:100, iterateList:true})
yield batches, total return batches, total;

// Detach delete merchants with only one transaction...
MATCH (merchant0:Merchant)
WHERE merchant0.totaltransactioncount=1
RETURN (COUNT(merchant0));

// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202009_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
// r.period = row.period,
// r.db=row.db,
// r.dbprefix=row.dbprefix,
r.period_202009=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount),
r.period_202009=1
RETURN count(*);


// <!-- Create the TRANSACTED_202008_AT relationships here for the period under consideratio, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202009_PBCVM.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
MERGE (c)-[r:TRANSACTED_202009_AT]->(m)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
// r.period_202008=1
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
// r.period_202008=1
RETURN count(*);
