// = The client-email project =================================================================================================
sudo cp /media/lnr-ai/christo/github_repos/money_personalities/data/demographics_large_df.csv /var/lib/neo4j/import/
sudo mv /var/lib/neo4j/demographics_large_df.csv /var/lib/neo4j/import/

./cypher-shell -u neo4j -p newPassword
CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (e:Email) ASSERT e.email IS UNIQUE;

// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///demographics_large_df.csv' AS row
MERGE (c:Client {dedupestatic: row.dedupe_static})
MERGE (e:Email {email: row.email})
MERGE (c)-[has_email:HAS_EMAIL]->(e)
RETURN count(c);

MATCH (c1:Client)-[he1:HAS_EMAIL]-(e:Email)<-[he2:HAS_EMAIL]-(c2:Client)
WHERE ID(c1)<>ID(c2)
RETURN c1.dedupestatic,c2.dedupestatic,e.email


