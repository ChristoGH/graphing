// CALL gds.graph.list()
// YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
//       nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime;
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003_neo4j.csv /var/lib/neo4j/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/clientswipes_202003.csv /var/lib/neo4j/
// sudo mv /media/lnr-ai/downloads/clientswipes_202003.csv /var/lib/neo4j/
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

MATCH (c:Segment)
DETACH DELETE c;

CALL apoc.periodic.iterate("MATCH (c:Client) RETURN c", "DETACH DELETE c", {batchSize:500})
yield batches, total return batches, total;

CALL apoc.periodic.iterate("MATCH (m:Merchant) RETURN m", "DETACH DELETE m", {batchSize:500})
yield batches, total return batches, total;

MATCH (m:Merchant)
DETACH DELETE m;
// <!-- Create transaction relationships here, between Client and Merchant: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003.csv' AS row
CASE toInteger(row.universaldate)
 WHEN 1 THEN 
    MATCH (c:Client {dedupestatic: row.Dedupegroup})
    MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
    MERGE (c)-[r:TRANSACTED_ON_UD_1]->(m)
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount),
    r.period = row.period,
    r.db=row.db,
    r.dbprefix=row.dbprefix
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
 WHEN 2 THEN 
    MATCH (c:Client {dedupestatic: row.Dedupegroup})
    MATCH (m:Merchant {franchisename: coalesce(row.franchisename, "Unknown")})
    MERGE (c)-[r:TRANSACTED_ON_UD_2]->(m)
    ON CREATE SET r.transactioncount = 1,
    r.transactionamount = toFloat(row.TransactionAmount),
    r.period = row.period,
    r.db=row.db,
    r.dbprefix=row.dbprefix
    ON MATCH SET r.transactioncount = r.transactioncount + 1,
    r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount) 
END
RETURN count(*);

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

RETURN count(*);