// I'm using Red Hat Linux specifically Oracle-7 and here is how I got it working

// Download the apoc-<version>.jar into the /var/lib/neo4j/plugins directory
chown neo4j:neo4j apoc-<version>.jar
chmod 755 apoc-<version>.jar
Open the neo4j.conf at /etc/neo4j/neo4j.conf and replace the line #dbms.security.procedures.whitelist=apoc.coll.*,apoc.load.* with dbms.security.procedures.whitelist=apoc.coll.*,apoc.load.*,apoc.* and save it.
Restart the Neo4j service by issuing the command systemctl restart neo4j