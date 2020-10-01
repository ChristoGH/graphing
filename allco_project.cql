// = The allco project =================================================================================================
// In  this project we look at ALL merchants.
// The goal is to investigate the quality of community detection using the Louvain algorithm in the Neo4j db
// Can we cluster these into discernible hubs, how many would here be  and does it separate clients on the same basis?
// we need to remove merchant nodes with only one transaction pointing to it...  Careful.  This may include all the franchsies 
// of some companies.  Such as FlySafAir
// Some merchant nodes are ubiquitous and span the entire merchant network, such as online purchases etc.  Also
// the ins funds merchants
// Deleting nodes may delete valuable information.  
// cd bin
// ./cypher-shell -u neo4j -p newPassword

// Find one transaction nodes:

// Count the number of merchant nodes with only one relationship:

// 0. Here we DELETE  the ALLCO_MERCHANT_FEET_LINK direction.
CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)-[mfl:ALLCO_MERCHANT_FEET_LINK]-(merchant1:Merchant)
RETURN mfl;
", "DELETE mfl", {batchSize:10000, iterateList:true})
yield batches, total return batches, total;

// 1. Here we CREATE  the ALLCO_MERCHANT_FEET_LINK direction.
CALL apoc.periodic.iterate('MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
t0.transactioncount>3 AND
t1.transactioncount>3 AND
merchant0.channel IN [0,1] AND
merchant1.channel IN [0,1] 
RETURN merchant0, merchant1, t0, t1;
', "MERGE (merchant0)-[link:ALLCO_MERCHANT_FEET_LINK]-(merchant1)
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


// 2. Here we CORRECT the ALLCO_MERCHANT_FEET_LINK direction, which way did feet move
MATCH (m0:Merchant)-[rel:ALLCO_MERCHANT_FEET_LINK]-(m1:Merchant)
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
    MERGE (m0)-[newrel:ALLCO_MERCHANT_FEET_LINK]->(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:ALLCO_MERCHANT_FEET_LINK]-(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);


// 3. Here we CHECK that all ALLCO_MERCHANT_FEET_LINK directions match:
MATCH (m0:Merchant)-[rel:ALLCO_MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactioncount0<=rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, m0.franchisename as franchisename1,
m1.franchisename as franchisename2, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;


// =================================================================================================================================
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


MATCH (m:Merchant)
RETURN COUNT(m.allco_merchant_community) as membercount, m.allco_merchant_community as allco_merchant_community
ORDER BY membercount ASC;

| 18                  | 65733                    |
| 18                  | 59251                    |
| 18                  | 1531                     |
| 18                  | 61119                    |
| 18                  | 58316                    |
| 19                  | 10357                    |
| 20                  | 66085                    |
| 21                  | 66055                    |
| 21                  | 62836                    |
| 21                  | 58193                    |
| 21                  | 62003                    |
| 22                  | 59889                    |
| 22                  | 64214                    |
| 23                  | 62417                    |
| 26                  | 2444                     |
| 30                  | 59252                    |
| 32                  | 58523                    |
| 34                  | 66600                    |
| 35                  | 4959                     |
| 35                  | 59833                    |
| 37                  | 57865                    |
| 37                  | 69205                    |
| 38                  | 57765                    |
| 39                  | 61028                    |
| 40                  | 59302                    |
| 41                  | 1241                     |
| 42                  | 59948                    |
| 42                  | 57746                    |
| 42                  | 61767                    |
| 44                  | 62135                    |
| 50                  | 59753                    |
| 55                  | 67183                    |
| 56                  | 60141                    |
| 69                  | 64663                    |
| 69                  | 59335                    |
| 72                  | 59150                    |
| 93                  | 70702                    |
| 95                  | 58913                    |
| 101                 | 57978                    |
| 103                 | 62569                    |
| 116                 | 57636                    |
| 793                 | 6988                     |
+------------------------------------------------+


MATCH (m:Merchant {allco_merchant_community:57636})
RETURN m.franchisename as franchisename
ORDER BY franchisename;


MATCH (m:Merchant)
WITH COUNT(m.allco_merchant_community) as membercount, m.allco_merchant_community as allco_merchant_community
WHERE membercount>10
MATCH path=(merchant0:Merchant {allco_merchant_community:allco_merchant_community})-[mfl:ALLCO_MERCHANT_FEET_LINK]->(merchant1:Merchant {allco_merchant_community:allco_merchant_community})
with collect(path) as paths
call apoc.gephi.add(null,'allco_merchant_graph', paths, 'count', ['companyname', 'franchisename', 'allco_merchant_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;
