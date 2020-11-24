
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
// sudo mv /media/lnr-ai/christo/graphing/data/CLM_GB_CUSTOMERS_BASE_REPORT_sandbox.csv /var/lib/neo4j/import/
sudo mv /media/lnr-ai/christo/graphing/data/CLM_GB_CUSTOMERS_BASE_REPORT.csv /var/lib/neo4j/import/
// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/CLM_GB_CUSTOMERS_BASE_REPORT_sandbox.csv /var/lib/neo4j/import/

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

// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data
// seg_l3_num = [312,313,321,322,323,324,325,333,336]

// sudo mv /media/lnr-ai/christo/github_repos/graphing/data/CLM_GB_CUSTOMERS_BASE_REPORT.csv /var/lib/neo4j/import/
// sudo cp /media/lnr-ai/christo/github_repos/money_personalities/data/mp_df.csv /var/lib/neo4j/import/

MATCH (m:money_personalities_client)
WHERE EXISTS(m.dedupestatic)
RETURN m
// DETACH DELETE c;

MATCH (m:money_personalities_client)
WHERE NOT EXISTS(m.dedupestatic)
RETURN m
// DETACH DELETE c;


USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///mp_df.csv' AS row
MATCH (client:Client {dedupestatic:toInteger(row.dedupestatic)})
SET client:money_personalities_client
RETURN COUNT(client)

MATCH (client:Client) WHERE client.dedupestatic='{dedupestatic}' 
        SET
        client:GreenBacks
        RETURN client LIMIT 25

// 1. Here we CREATE  the MP_MERCHANT_FEET_LINK direction.
CALL apoc.periodic.iterate('MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:money_personalities_client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
t0.transactioncount>3 AND
t1.transactioncount>3 AND
merchant0.channel IN [0,1] AND
merchant1.channel IN [0,1] 
RETURN merchant0, merchant1, t0, t1;
', "MERGE (merchant0)-[link:MP_MERCHANT_FEET_LINK]-(merchant1)
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
link.transactionamount1 = link.transactionamount1+t1.transactionamount", {batchSize:10000, iterateList:true, retries:5})
yield batches, total return batches, total;


MATCH (m0:Merchant)-[rel:MP_MERCHANT_FEET_LINK]-(m1:Merchant)
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
    MERGE (m0)-[newrel:MP_MERCHANT_FEET_LINK]->(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:MP_MERCHANT_FEET_LINK]-(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);


// 3. Here we CHECK that all MP_MERCHANT_FEET_LINK directions match:
MATCH (m0:Merchant)-[rel:MP_MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactioncount0<=rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, m0.franchisename as franchisename1,
m1.franchisename as franchisename2, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;


// 4. Here we CREATE a money personalities sub graph:
CALL gds.graph.drop('mp_merchant_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'mp_merchant_graph',
    'MATCH (m0:Merchant) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:MP_MERCHANT_FEET_LINK]->(m1:Merchant) RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('mp_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

CALL gds.louvain.stream('mp_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN communityId, COUNT(gds.util.asNode(nodeId).franchisename) as count
ORDER BY count DESC;

MATCH (merchant:Merchant)
WHERE EXISTS(merchant.mp_merchant_community)
REMOVE merchant.mp_merchant_community
RETURN merchant.franchisename as franchisename, merchant.mp_merchant_community as mp_merchant_community;

CALL gds.louvain.write('mp_merchant_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'mp_merchant_community' })
YIELD communityCount, modularity, modularities;


MATCH (m:Merchant)
RETURN COUNT(m.mp_merchant_community) as membercount, m.mp_merchant_community as mp_merchant_community
ORDER BY membercount ASC;

// ============================================================================================================


CALL apoc.periodic.iterate('MATCH (client0:money_personalities_client)-[t0:TRANSACTED_AT]->(merchant:Merchant)<-[t1:TRANSACTED_AT]-(client1:money_personalities_client)
WHERE ID(client0) < ID(client1) 
RETURN client0, client1, t0, t1;
', "MERGE (client0)-[link:MP_CLIENT_LINK]-(client1)
ON CREATE SET link.count = 1,
link.ID0=ID(client0),
link.ID1=ID(client1),
link.transactioncount0 = t0.transactioncount,
link.transactioncount1 = t1.transactioncount,
link.transactionamount0 = t0.transactionamount,
link.transactionamount1 = t1.transactionamount
ON MATCH SET link.count = link.count + 1,
link.transactioncount0 = link.transactioncount0+t0.transactioncount,
link.transactioncount1 = link.transactioncount1+t1.transactioncount,
link.transactionamount0 = link.transactionamount0+t0.transactionamount,
link.transactionamount1 = link.transactionamount1+t1.transactionamount;", {batchSize:100, iterateList:true, parallel:true})
yield batches, total return batches, total;



CALL gds.graph.drop('mp_link_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'mp_link_graph',
    'MATCH (c0:money_personalities_client) RETURN id(c0) AS id',
    'MATCH (c0:money_personalities_client)-[rel:MP_CLIENT_LINK]-(c1:money_personalities_client) RETURN id(c0) AS source, id(c1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('mp_link_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).dedupestatic AS dedupestatic, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

MATCH (client:money_personalities_client)
WHERE EXISTS(client.mp_link_community)
REMOVE client.mp_merchant_community
RETURN client;


CALL gds.louvain.write('mp_link_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'mp_link_community' })
YIELD communityCount, modularity, modularities;


MATCH (client:money_personalities_client)
RETURN client.mp_link_community AS mp_link_community, COUNT(client.mp_link_community) as membercount
ORDER BY membercount ASC;
| mp_link_community | count
| 76                | 2           |
| 101               | 2           |
| 150               | 4           |
| 165               | 6           |
| 153               | 10          |
| 89                | 10          |
| 149               | 12          |
| 124               | 15          |
+---------------------------------+


MATCH (n:money_personalities_client)  RETURN COUNT(n.mp_link_community), n.mp_link_community as mp_link_community LIMIT 25;

MATCH (client:money_personalities_client)
WHERE client.mp_link_community = 124
RETURN client