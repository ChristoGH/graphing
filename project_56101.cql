
// = The 56101 project =================================================================================================
// In  this project we only look at merchants belonging to the subclass_id = 56101 (fast foods).
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
MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:56101}) 
WITH oldm,count(client) as rels, collect(client) as clients
WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY franchisename;

// Rank  the number of merchant nodes with only one relationship:
MATCH (c0:Client)-[cl:CLIENT_LINK_7916]-(c1:Client) 
WHERE ID(c0)<ID(c1)
RETURN cl.count as count, COUNT(cl) as number
ORDER BY count ASC;

MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:56101}) 
WITH oldm,count(client) as rels, collect(client) as clients
// WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY rels ASC;

MATCH (client:Client)-[:TRANSACTED_AT]->(oldm:Merchant {subclass_id:56101}) 
WITH oldm,count(client) as rels, collect(client) as clients
// WHERE rels <=2
RETURN oldm.franchisename as franchisename,rels
ORDER BY franchisename ASC;

// Detach delete merchants with only one transaction...
MATCH (merchant0:Merchant {subclass_id:56101})
WHERE merchant0.totaltransactioncount=1
RETURN (COUNT(merchant0));

MATCH (merchant0:Merchant {subclass_id:56101})
WHERE merchant0.totaltransactioncount=1
DETACH DELETE merchant0;

// Count insufficient funds 'merchants'
MATCH (n:Merchant {subclass_id:56101}) WHERE n.franchisename =~ '(?i).*FUNDS.*' RETURN COUNT(n);
MATCH (n:Merchant {subclass_id:56101}) WHERE n.franchisename =~ '(?i).*FUNDS.*' DETACH DELETE n;

// Delete previous MERCHANT_FEET_LINKS:
MATCH (merchant0:Merchant)-[mfl:MERCHANT_FEET_LINK]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] 
RETURN mfl;

CALL apoc.periodic.iterate("MATCH (merchant0:Merchant)-[mfl:MERCHANT_FEET_LINK]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] 
RETURN mfl;
", "DELETE mfl", {batchSize:100})
yield batches, total return batches, total;


// Here we CREATE MERCHANT_FEET_LINK for subclass_id 561011:

CALL apoc.periodic.iterate('MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] AND 
NOT merchant0.franchisename  IN ["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] AND
NOT merchant1.franchisename IN ["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"]
RETURN merchant0, merchant1, t0, t1;
', "MERGE (merchant0)-[link:MERCHANT_FEET_LINK]-(merchant1)
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
link.transactionamount1 = link.transactionamount1+t1.transactionamount", {batchSize:100})
yield batches, total return batches, total;


MATCH (merchant0:Merchant)<-[t0:TRANSACTED_AT]-(client:Client)-[t1:TRANSACTED_AT]->(merchant1:Merchant)
WHERE ID(merchant0) < ID(merchant1) AND 
merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] AND 
NOT merchant0.franchisename =~ '(?i).*FUNDS.*' AND
NOT merchant1.franchisename =~ '(?i).*FUNDS.*'
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

MATCH (merchant0:Merchant)-[tmfl:MERCHANT_FEET_LINK]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] 
//AND tmfl.count=1
RETURN merchant0.franchisename, merchant1.franchisename, tmfl.count AS count
ORDER BY count ASC;

// ==============================================================================================================
// Do the distance property of the MERCHANT_FEET_LINK, the distance is the ratio of 
// the SUM of m0.totaltransactioncount and m1.totaltransactioncount to the MERCHANT_FEET_LINK count:
// The less the count the further the merchants, the higher the totaltransactioncount more
// significant the distance is.

MATCH (m0:Merchant)-[rel:MERCHANT_FEET_LINK]->(m1:Merchant)
// WHERE ID(m0)<ID(m1) 
WITH m0,m1,rel, 
  CASE WHEN m0.totaltransactioncount > m1.totaltransactioncount 
    THEN m0.totaltransactioncount 
    ELSE m1.totaltransactioncount 
  END AS totaltransactioncount 
RETURN m0.franchisename as start_franchisename, m0.totaltransactioncount as start_totaltransactioncount, 
m1.franchisename as end_franchisename, 
m1.totaltransactioncount as end_totaltransactioncount, 
rel.count as bridged, totaltransactioncount,
totaltransactioncount/rel.count as distance
ORDER BY distance ASC
LIMIT(10);


MATCH (merchant0:Merchant {subclass_id:56101})-[mfl:MERCHANT_FEET_LINK]-(merchant1:Merchant {subclass_id:56101})
WHERE mfl.count=1 AND ID(merchant0)<ID(merchant1)
DELETE mfl;

// ====================================================================================================================
MATCH (m0:Merchant {subclass_id:56101})-[rel0:MERCHANT_FEET_LINK]-(m1:Merchant {subclass_id:56101}),
(m1:Merchant {subclass_id:56101})-[rel1:MERCHANT_FEET_LINK]-(m2:Merchant {subclass_id:56101}),
 (m0:Merchant {subclass_id:56101})-[rel2:MERCHANT_FEET_LINK]-(m2:Merchant {subclass_id:56101})
WHERE ID(m0)<ID(m1) AND ID(m1)<ID(m2) AND
m0.subclass_id IN [56101] AND 
m1.subclass_id IN [56101] AND 
m2.subclass_id IN [56101] AND 
NOT m0.franchisename  IN ["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] AND
NOT m1.franchisename IN ["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] AND 
NOT m2.franchisename IN ["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] 
RETURN m0.franchisename as franchisename0, rel0.count as count0,
m1.franchisename as franchisename1,rel1.count as count1,
m2.franchisename as franchisename2, rel2.count as count2;

// =Create TRIADIC_MERCHANT_FEET_LINK============================================================================
// Delete previous MERCHANT_FEET_LINKS:
MATCH (merchant0:Merchant)-[tmfl:TRIADIC_MERCHANT_FEET_LINK]-(merchant1:Merchant)
WHERE merchant0.subclass_id IN [56101] AND 
merchant1.subclass_id IN [56101] 
DELETE tmfl;

MATCH (merchant0:Merchant)-[tmfl:MERCHANT_FEET_LINK]-(merchant1:Merchant)
WHERE tmfl.count=1 
DELETE tmfl;

MATCH (m0:Merchant {subclass_id:56101})-[mfl0:MERCHANT_FEET_LINK]-(m1:Merchant {subclass_id:56101}),
(m1:Merchant {subclass_id:56101})-[mfl1:MERCHANT_FEET_LINK]-(m2:Merchant {subclass_id:56101}),
 (m0:Merchant {subclass_id:56101})-[mfl2:MERCHANT_FEET_LINK]-(m2:Merchant {subclass_id:56101})
WHERE ID(m0)<ID(m1) AND ID(m1)<ID(m2) AND
m0.subclass_id IN [56101] AND 
m1.subclass_id IN [56101] AND 
m2.subclass_id IN [56101] AND 
NOT m0.franchisename  IN ["SAUSAGE","ROCOMAMAS","COLCACCHIOS",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] AND
NOT m1.franchisename IN ["SAUSAGE","ROCOMAMAS","COLCACCHIOS",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] AND 
NOT m2.franchisename IN ["SAUSAGE","ROCOMAMAS","COLCACCHIOS",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"] 
MERGE (m0)-[tmfl0:TRIADIC_MERCHANT_FEET_LINK]-(m1)
ON CREATE 
SET tmfl0=mfl0
MERGE (m1)-[tmfl1:TRIADIC_MERCHANT_FEET_LINK]-(m2)
ON CREATE 
SET tmfl1=mfl1
MERGE (m1)-[tmfl2:TRIADIC_MERCHANT_FEET_LINK]-(m2)
ON CREATE 
SET tmfl2=mfl2
RETURN m0.franchisename as franchisename0, mfl0.count as count0,
m1.franchisename as franchisename1,mfl1.count as count1,
m2.franchisename as franchisename2, mfl2.count as count2;


// Here we CORRECT the MERCHANT_LINK_FEET direction, which way did feet move
MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant)
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
    MERGE (m0)-[newrel:TRIADIC_MERCHANT_FEET_LINK]->(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.count=count
)
FOREACH (p IN CASE WHEN (mustpointleft AND pointsright) THEN [1] ELSE [] END |
    DELETE relationship
    MERGE (m0)<-[newrel:TRIADIC_MERCHANT_FEET_LINK]-(m1)
        ON CREATE SET newrel.transactioncount0 = transactioncount0,
        newrel.transactioncount1=transactioncount1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.count=count
);


// Check that all directions match:
MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant)
WHERE ID(m0)=rel.ID0 AND ID(m1)=rel.ID1
WITH m0,m1,rel, rel.transactioncount0<=rel.transactioncount1 AS mustpointright, 
rel.transactioncount0>rel.transactioncount1 AS mustpointleft,
NOT (startNode(rel) = m0) as pointsleft,
(startNode(rel) = m0) as pointsright
RETURN ID(m0) as IDm0, ID(m1) as IDm1, m0.franchisename as franchisename1,
m1.franchisename as franchisename2, rel.transactioncount0 as transactioncount0,
rel.transactioncount1 as transactioncount1,
mustpointright, pointsright, mustpointleft, pointsleft;


// Create triadic-graph on subclass_id:56101====================================================================================
CALL gds.graph.create.cypher(
    'triadic_graph',
    'MATCH (m0:Merchant {subclass_id:56101}) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]->(m1:Merchant) RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.labelPropagation.stream(
    'triadic_graph', {
        seedProperty: 'id',
        relationshipWeightProperty: 'count'
    }
);

// sandbox_graph
CALL gds.graph.drop('triadic_graph') YIELD graphName;

CALL gds.louvain.stream('triadic_graph')
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId ASC;

MATCH (m:Merchant)
WHERE EXISTS(m.community)
REMOVE m.community
RETURN m

CALL gds.louvain.write.estimate('triadic_graph', { writeProperty: 'community' })
YIELD nodeCount, relationshipCount, bytesMin, bytesMax, requiredMemory

CALL gds.louvain.stats('triadic_graph')
YIELD communityCount

CALL gds.algo.pageRank.stream('triadic_graph') YIELD nodeId, score;

CALL gds.louvain.stats(
  graphName: 'triadic_graph',
  configuration: Map
)
YIELD
  createMillis: Integer,
  computeMillis: Integer,
  postProcessingMillis: Integer,
  communityCount: Integer,
  ranLevels: Integer,
  modularity: Float,
  modularities: Integer[],
  communityDistribution: Map,
  configuration: Map

CALL gds.graph.list('triadic_graph')
YIELD graphName, nodeProjection, relationshipProjection, nodeQuery, relationshipQuery,
      nodeCount, relationshipCount, schema, degreeDistribution, creationTime, modificationTime, sizeInBytes, memoryUsage;

CALL gds.graph.create(
    'trigraph',
    'Merchant',
    {
        LINK: {
            orientation: 'TRIADIC_MERCHANT_FEET_LINK'
        }
    },
    {
        nodeProperties: 'seed',
        relationshipProperties: 'count'
    }
)
// The following gives good results:=========================================================================
CALL gds.graph.drop('triadic_56101_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'triadic_56101_graph',
    'MATCH (m0:Merchant {subclass_id:56101}) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]->(m1:Merchant) RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('triadic_56101_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_56101_community)
REMOVE m.triadic_56101_community
RETURN m;

CALL gds.louvain.write('triadic_56101_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'triadic_56101_community' })
YIELD communityCount, modularity, modularities

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_56101_community)
RETURN m
LIMIT 25


MATCH (m:Merchant {subclass_id:56101})
RETURN COUNT(m.triadic_56101_community) as membercount, m.triadic_56101_community as triadic_56101_community
ORDER BY membercount ASC;

// The following gives good results for TRIADIC_MERCHANT_FEET_LINK 
// on subclass_id=56101 and LIMITED to  count>1 ======================================
MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]->(m1:Merchant)
RETURN rel.count as count, count(rel.count)

CALL gds.graph.drop('triadic_56101_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'triadic_56101_graph',
    'MATCH (m0:Merchant {subclass_id:56101}) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:TRIADIC_MERCHANT_FEET_LINK]->(m1:Merchant) 
    WHERE rel.count>1 RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('triadic_56101_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_56101_community)
REMOVE m.triadic_56101_community
RETURN m;

CALL gds.louvain.write('triadic_56101_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'triadic_56101_community' })
YIELD communityCount, modularity, modularities

MATCH (m:Merchant)
WHERE EXISTS(m.triadic_56101_community)
RETURN m
LIMIT 25


MATCH (m:Merchant {subclass_id:56101})
RETURN COUNT(m.triadic_56101_community) as membercount, m.triadic_56101_community as triadic_56101_community
ORDER BY membercount ASC;




// =The subclass_id super nodes==============================================================================
["SAUSAGE",
"DOMINOS PIZZ","STEERS DINER","STEERS DEBONAI",
"WIMPY","DEBONAIRS","DEBONAIRS PIZZ","KRISPY KREME -",
"STEERS","DEBONAIRS PI","CHICKEN LICK","BURGER KING -","CHICKEN LICKEN"]

CALL gds.louvain.stream('Merchant', 'TRIADIC_MERCHANT_FEET_LINK',{})
YIELD nodeId, community;
MATCH (user:User) WHERE id(user) = nodeId
RETURN user.id AS user, community
ORDER BY community;

// ====================================================================================================================
// In what follows we cluster (subclass_id:56101) merchants based on client behaviour.  Clients purchase from one fast food outlet 
// and also from another - this creates a link between merchants.  Creating this edge between the merchants is referred
// to as triadic closure in graph-speak.
// Repeated closure strengthens the bond/link/edge between merchants ie the more times similar merchants get chosen.
// Merchants that are physically far away from each other are expected to have looser/weaker 'bonds'.
// It also reveals merchants that are in competition with each other and the severity of such competition and 
// their main/true competitors.

CALL gds.graph.drop('biadic_graph') YIELD graphName;

CALL gds.graph.create.cypher(
    'biadic_graph',
    'MATCH (m0:Merchant {subclass_id:56101}) RETURN id(m0) AS id, m0.totaltransactionamount as totaltransactionamount, m0.totaltransactioncount as totaltransactioncount',
    'MATCH (m0:Merchant)-[rel:MERCHANT_FEET_LINK]->(m1:Merchant) RETURN id(m0) AS source, id(m1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;


CALL gds.louvain.stream('biadic_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

CALL gds.louvain.write('biadic_graph', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'biadic_community' })
YIELD communityCount, modularity, modularities

MATCH (m:Merchant {subclass_id:56101})
RETURN m.franchisename as franchisename, m.biadic_community as biadic_community
ORDER BY community ASC;


MATCH (m:Merchant {subclass_id:56101})
RETURN COUNT(m.community) as membercount, m.biadic_community as biadic_community
ORDER BY membercount ASC;

// =CLIENT_LINK==========================================================================================
// triadic_56101_community=7916
MATCH (client0:Client)-[t0:TRANSACTED_AT]->(merchant:Merchant)<-[t1:TRANSACTED_AT]-(client1:Client)
WHERE ID(client0) < ID(client1) AND 
merchant.triadic_56101_community = 7916
SET client0.triadic_56101_community=7916, client1.triadic_56101_community=7916
MERGE (client0)-[link:CLIENT_LINK_7916]-(client1)
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
link.transactionamount1 = link.transactionamount1+t1.transactionamount
RETURN count(link);

MATCH (client0:Client)-[t0:TRANSACTED_AT]->(merchant:Merchant)<-[t1:TRANSACTED_AT]-(client1:Client)
WHERE ID(client0) < ID(client1) AND 
merchant.triadic_56101_community = 7916
SET client0.triadic_56101_community=7916, client1.triadic_56101_community=7916

CALL apoc.periodic.iterate('MATCH (client0:Client)-[t0:TRANSACTED_AT]->(merchant:Merchant)<-[t1:TRANSACTED_AT]-(client1:Client)
WHERE ID(client0) < ID(client1) AND 
merchant.triadic_56101_community = 7916 
RETURN client0, client1, t0, t1;
', "MERGE (client0)-[link:CLIENT_LINK_7916]-(client1)
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

MATCH (m:Merchant {subclass_id:56101}) 
RETURN COUNT(m.biadic_community) as biadic_community_count, m.biadic_community
ORDER BY biadic_community_count ASC;

CALL gds.graph.drop('client_link_graph_7916') YIELD graphName;

CALL gds.graph.create.cypher(
    'client_link_graph_7916',
    'MATCH (c0:Client) WHERE c0.triadic_56101_community = 7916 RETURN id(c0) AS id',
    'MATCH (c0:Client)-[rel:CLIENT_LINK_7916]-(c1:Client) RETURN id(c0) AS source, id(c1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.louvain.stream('client_link_graph_7916', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).dedupestatic AS dedupestatic, communityId, intermediateCommunityIds
ORDER BY communityId DESC;


CALL gds.louvain.write('client_link_graph_7916', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'client_link_community_7916' })
YIELD communityCount, modularity, modularities


MATCH (c:Client {subclass_id:56101})
RETURN COUNT(m.community) as membercount, m.biadic_community as biadic_community
ORDER BY membercount ASC;


// List client communities in merchant community 7916
MATCH (c:Client) 
WHERE EXISTS(c.client_link_community_7916) 
RETURN COUNT(c.client_link_community_7916) as count, c.client_link_community_7916 as client_link_community
ORDER BY count ASC

+-------------------------------+
| count | client_link_community |
+-------------------------------+
| 48    | 822                   |
| 108   | 232                   |
| 112   | 44                    |
| 146   | 86                    |
| 172   | 1415                  |
| 206   | 27                    |
| 237   | 220                   |
| 238   | 1779                  |
| 288   | 95                    |
| 333   | 75                    |
| 372   | 31                    |
| 429   | 176                   |
+-------------------------------|

// Observe the first cluster/community 822:
MATCH (c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND c.client_link_community_7916=822 AND m.subclass_id=56101
RETURN c,t,m

CALL gds.graph.create.cypher(
    'triadic_graph_7916_822',
    'MATCH (c0:Client) WHERE c0.client_link_community_7916=822 RETURN id(c0) AS id',
    'MATCH (c0:Client)-[cl:CLIENT_LINK_7916]->(c1:Client) WHERE c0.client_link_community_7916=822 AND c1.client_link_community_7916=822 RETURN id(c0) AS source, id(c1) AS target, cl.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.pageRank.stream('triadic_graph_7916_822', { maxIterations: 20, dampingFactor: 0.85 })
    YIELD nodeId, score
    RETURN gds.util.asNode(nodeId).dedupestatic AS dedupestatic, score
    ORDER BY score DESC, dedupestatic ASC;


MATCH (c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND c.client_link_community_7916=232 AND m.subclass_id=56101
RETURN c,t,m


MATCH (c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND c.client_link_community_7916=44 AND m.subclass_id=56101
RETURN c,t,m



MATCH (c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND c.client_link_community_7916=232 AND m.subclass_id=56101
RETURN c.client_link_community_7916 AS client_link_community_7916,  
m.franchisename as franchisename, 
SUM(t.transactionamount) AS transactionamount, 
SUM(t.transactioncount) AS transactioncount


// BLOOM =========================================================================================================
MATCH (m0:Merchant {subclass_id:56101})-[t:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant {56101})
WHERE ID(m0)<ID(m1)
RETURN m0,t,m1
LIMIT 25

MATCH (m0:Merchant {subclass_id:56101})-[t:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant {subclass_id: 56101})
WHERE ID(m0)<ID(m1) AND m0.triadic_56101_community=9137 AND m1.triadic_56101_community=9137 
RETURN m0,t,m1



