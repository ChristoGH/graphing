
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

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_neo4j.csv' AS row
MERGE (c:Client {dedupestatic: row.Dedupegroup})
RETURN count(c);

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_neo4j.csv' AS row
MERGE (m:Merchant {franchisename:coalesce(row.franchisename, "Unknown")})
ON CREATE SET m.companyindex = coalesce(row.companyindex,"Unknown")
ON CREATE SET m.companyname = coalesce(row.companyname,"Unknown")
RETURN count(m);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_neo4j.csv' AS row
MATCH (c:Client {dedupestatic: row.Dedupegroup})
MATCH (m:Merchant {franchisename: row.franchisename})
MERGE (c)-[r:TRANSACTED_AT]->(m)
RETURN count(*);