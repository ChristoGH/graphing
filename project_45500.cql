
// = The 45500 project =================================================================================================
// In  this project we only look at merchants belonging to the subclass_id = 45500 (fuel station).
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
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:45500}) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY franchisename;

MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:45500}) 
WITH oldm,count(client) as rels, collect(client) as clients
// WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY rels ASC;

MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:45500}) 
WITH oldm,count(client) as rels, collect(client) as clients
// WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY franchisename ASC;

// Detach delete merchants with only one transaction...
MATCH (merchant0:Merchant {subclass_id:45500})
WHERE merchant0.totaltransactioncount=1
RETURN (COUNT(merchant0));

MATCH (merchant0:Merchant {subclass_id:45500})
WHERE merchant0.totaltransactioncount=1
DETACH DELETE merchant0;

CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)-[mfl:MERCHANT_FEET_LINK_45500]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [45500] AND 
merchant1.subclass_id IN [45500] 
RETURN mfl;
", "DELETE mfl", {batchSize:10000, iterateList:true})
yield batches, total return batches, total;


CALL apoc.periodic.iterate('MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.subclass_id IN [45500] AND 
merchant1.subclass_id IN [45500] 
RETURN merchant0, merchant1, t0, t1;
', "MERGE (merchant0)-[link:MERCHANT_FEET_LINK_45500]-(merchant1)
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


MATCH (merchant0:Merchant)-[tmfl:MERCHANT_FEET_LINK_45500]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [45500] AND 
merchant1.subclass_id IN [45500] 
//AND tmfl.count=1
RETURN merchant0.franchisename, merchant1.franchisename, tmfl.count AS count
ORDER BY count ASC;

MATCH (n:Merchant {subclass_id:45500})
WHERE n.franchisename =~ '(?i).*Checkers.*'
RETURN n.franchisename, n.companyname;

MATCH (n:Merchant {subclass_id:45500})
WHERE n.franchisename =~ '(?i).*sasolb.*'
DETACH DELETE n;

MATCH (n:Merchant {subclass_id:45500})
WHERE n.franchisename =~ '(?i).*checkers.*'
DETACH DELETE n;


MATCH (merchant0:Merchant {subclass_id:45500})-[mfl:MERCHANT_FEET_LINK_45500]-(merchant1:Merchant {subclass_id:45500})
WHERE mfl.count=1 AND ID(merchant0)<ID(merchant1)
DELETE mfl;

MATCH (m0:Merchant {subclass_id:45500})-[mfl0:MERCHANT_FEET_LINK_45500]-(m1:Merchant {subclass_id:45500}),
(m1:Merchant {subclass_id:45500})-[mfl1:MERCHANT_FEET_LINK_45500]-(m2:Merchant {subclass_id:45500}),
 (m0:Merchant {subclass_id:45500})-[mfl2:MERCHANT_FEET_LINK_45500]-(m2:Merchant {subclass_id:45500})
WHERE ID(m0)<ID(m1) AND ID(m1)<ID(m2) AND
m0.subclass_id IN [45500] AND 
m1.subclass_id IN [45500] AND 
m2.subclass_id IN [45500] 
MERGE (m0)-[tmfl0:TRIADIC_MERCHANT_FEET_LINK_45500]-(m1)
ON CREATE 
SET tmfl0=mfl0
MERGE (m1)-[tmfl1:TRIADIC_MERCHANT_FEET_LINK_45500]-(m2)
ON CREATE 
SET tmfl1=mfl1
MERGE (m1)-[tmfl2:TRIADIC_MERCHANT_FEET_LINK_45500]-(m2)
ON CREATE 
SET tmfl2=mfl2
RETURN m0.franchisename as franchisename0, mfl0.count as count0,
m1.franchisename as franchisename1,mfl1.count as count1,
m2.franchisename as franchisename2, mfl2.count as count2;


// Here we CORRECT the MERCHANT_LINK_FEET direction, which way did feet move
MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK_45500]-(m1:Merchant)
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
    MERGE (m0)-[newrel:TRIADIC_MERCHANT_FEET_LINK_45500]->(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:TRIADIC_MERCHANT_FEET_LINK_45500]-(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);

// Check that all directions match:
MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK_45500]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactioncount0<=rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, m0.franchisename as franchisename1,
m1.franchisename as franchisename2, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;

// 
CALL gds.graph.drop('triadic_45500_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'triadic_45500_graph',
    'MATCH (m0:Merchant {subclass_id:45500}) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK_45500]->(m1:Merchant) RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('triadic_45500_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_45500_community)
REMOVE m.triadic_45500_community
RETURN m;

CALL gds.louvain.write('triadic_45500_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'triadic_45500_community' })
YIELD communityCount, modularity, modularities

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_45500_community)
RETURN m
LIMIT 25


MATCH (m:Merchant {subclass_id:45500})
RETURN COUNT(m.triadic_45500_community) as membercount, m.triadic_45500_community as triadic_45500_community
ORDER BY membercount ASC;

MATCH (n:Merchant) WHERE n.triadic_45500_community = 11808 RETURN n LIMIT 25

| 118                 | 10695                   |
| 476                 | 12146                   |
| 549                 | 10398                   |
| 766                 | 5314                    |
| 815                 | 12310                   |
| 940                 | 12292                   |
| 1046                | 3716                    |
| 1113                | 1056                    |
| 1142                | 11808                   |
| 1244                | 2013       