MATCH path=(merchant0:Merchant {franchisename:'DIS-CHEM DAINFERN'})-[:TRANSACTED_AT]-(client:Client)
MATCH (merchant1:Merchant)-[:TRANSACTED_AT]-(client:Client)
MATCH (merchant2:Merchant)-[:TRANSACTED_AT]-(client:Client)
WHERE ID(merchant1)<>ID(merchant2) AND ID(merchant0)<>ID(merchant2) AND ID(merchant0)<>ID(merchant1)
RETURN client.dedupestatic AS dedupestatic, merchant0.franchisename AS franchisename0,
merchant1.franchisename AS franchisename1, merchant2.franchisename AS franchisename2 
ORDER BY franchisename1 DESC, franchisename2 DESC


Match p=(merchant0:Merchant {franchisename:'DIS-CHEM DAINFERN'})-[r*4]-(d) 
RETURN Distinct(p) LIMIT 25

Match p=(merchant0:Merchant {franchisename:'DIS-CHEM DAINFERN'})-[:TRANSACTED_AT*4]-(d) 
RETURN Distinct(p) LIMIT 25

Match p=(merchant0:Merchant {franchisename:'DIS-CHEM DAINFERN'})-[:TRANSACTED_AT*5]-(d)
Return Distinct(p) LIMIT 25