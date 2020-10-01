
// . Return a client
MATCH (c0:Client)-[t:TRANSACTED_AT]->(m0:Merchant)
WHERE m0.subclass_id=56101 
AND ID(c0)=2274613
RETURN c0 LIMIT 1;

// 2. Return a merchant
MATCH (c0:Client)-[t:TRANSACTED_AT]->(m0:Merchant)
WHERE m0.subclass_id=56101
AND ID(m0)=4655320
RETURN m0 LIMIT 1;

// 3. Return a client, merchant and transaction
MATCH p=(c0:Client)-[t:TRANSACTED_AT]->(m0:Merchant)
WHERE m0.subclass_id=56101 AND ID(m0)=4655320
AND ID(c0)=2274613
RETURN p LIMIT 1;

// 4. Two clients at the same merchant
MATCH p=(c0:Client)-[t:TRANSACTED_AT]->(m0:Merchant)
WHERE m0.subclass_id=56101 AND ID(m0)=4655320
// AND ID(c0)=2274613
RETURN p LIMIT 2;

// 5. The same client at two merchants
MATCH p=(c0:Client)-[t:TRANSACTED_AT]->(m0:Merchant)
WHERE m0.subclass_id=56101 
// AND ID(m0)=4655320
AND ID(c0)=2274613
RETURN p LIMIT 2;

// 6. Two different clients and different Merchants
MATCH (c0:Client)-[t0:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH (c0:Client)-[t1:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
MATCH (c1:Client)-[t2:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH (c1:Client)-[t3:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
WHERE
// m0.subclass_id=56101 
// AND ID(m0)=4655320
ID(c0)<>ID(c1) AND ID(m0)<>ID(m1)
RETURN m0,m1,c0,c1 LIMIT 1;

// 7. Two different clients and different Merchants and TRIADIC_MERCHANT_FEET_LINK:
MATCH (m0:Merchant)-[r:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant) 
MATCH (c0:Client)-[t0:TRANSACTED_AT]->(m0) 
MATCH (c0)-[t1:TRANSACTED_AT]->(m1) 
RETURN c0,m0,m1 LIMIT 1;

// 8. Two different clients and one Merchant and CLIENT_LINK_7916:
MATCH (c0:Client)-[r:CLIENT_LINK_7916]-(c1:Client) 
MATCH (c0)-[t0:TRANSACTED_AT]->(m0:Merchant) 
MATCH (c1)-[t1:TRANSACTED_AT]->(m0:Merchant) 
RETURN c0,c1,m0 LIMIT 1;

// 9. Client communities
MATCH path=(c0:Client)-[r:CLIENT_LINK_7916]-(c1:Client) 
WHERE NOT c0:GreenBacks AND NOT c1:GreenBacks
RETURN path LIMIT 5

// 10. Merchant communities
MATCH path=(m0:Merchant)-[r:TRIADIC_MERCHANT_FEET_LINK]-(m1:Merchant) 
RETURN path LIMIT 5


// ALL SA FAST FOOD communities:
MATCH (m:Merchant {subclass_id:56101})
WHERE EXISTS(m.triadic_56101_community) 
RETURN COUNT(m.triadic_56101_community) as membercount, m.triadic_56101_community as triadic_56101_community
ORDER BY membercount ASC;




MATCH (m0)-[cl:TRIADIC_MERCHANT_FEET_LINK]-(m1) 
WHERE ID(m0)<ID(m1)
RETURN cl.count as count, COUNT(cl) as number
ORDER BY count ASC;

//

MATCH (c0:Client)-[t0:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH (c0:Client)-[t1:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
MATCH (c1:Client)-[t2:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH (c1:Client)-[t3:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
WHERE
// m0.subclass_id=56101 
// AND ID(m0)=4655320
ID(c0)<>ID(c1) AND ID(m0)=4655363 AND ID(m1)=4756449
RETURN m0,m1,c0,c1 LIMIT 3;

// Multiple linkages between clients to the same merchants

MATCH p0=(c0:Client)-[t0:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH p1=(c0:Client)-[t1:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
MATCH p2=(c1:Client)-[t2:TRANSACTED_AT]->(m0:Merchant {subclass_id:56101})
MATCH p3=(c1:Client)-[t3:TRANSACTED_AT]->(m1:Merchant {subclass_id:56101})
WHERE
// m0.subclass_id=56101 
// AND ID(m0)=4655320
ID(c0)<>ID(c1) AND ID(m0)=4655363 AND ID(m1)=4756449
RETURN p0,p1,p2,p3 LIMIT 3;

// The start of communities

    // Merchant communities
    MATCH p=()-[r:TRIADIC_MERCHANT_FEET_LINK]->() RETURN p LIMIT 4

    // Client communities
    MATCH p=()-[r:CLIENT_LINK_7916]->() RETURN p LIMIT 4

    MATCH (c0:Client)-[r:CLIENT_LINK_7916]-(c1:Client) 
    MATCH (c0)-[t0:TRANSACTED_AT]->(m0:Merchant) 
    MATCH (c1)-[t1:TRANSACTED_AT]->(m0:Merchant) 
    RETURN c0,c1,m0 LIMIT 1



// 24 fast food communities across South Africa

// This yields the transactional centers
// a search engine ran on the results, one one were to look for a 
// fast food place in an area these would be the most dominant

// Look at one such center 7916, Groblersdal.  KFC Groblersdal was ranked highest. 
// This process was repeated for each community

// So much for the Merchant communities.

// Merchant communities are defined by client preferences.  Merchant communities also 
// define client communities.

// Just some merchaant sit at the center of agroup of merchant based on client preferences,
// so some clients sit at the center of of client communities of client behaviour (preferences
// and choices) 
