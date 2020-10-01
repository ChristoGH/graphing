
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


// <!-- Create the Merchant node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///CLM_GB_CUSTOMERS_BASE_REPORT.csv' AS row
MERGE (client:Client {dedupestatic:toInteger(row.MASTER_CIS)})
ON MATCH 
SET client.CLM_ENROL_DATE = coalesce(date(row.CLM_ENROL_DATE),"not applicable"),
client.ENROLMENT_CHANNEL = coalesce(row.ENROLMENT_CHANNEL,"not applicable"),
client.STATUS = coalesce(row.STATUS,"not applicable"),
client.CLM_REWARDS_NUMBER = coalesce(toInteger(row.CLM_REWARDS_NUMBER),"not applicable"),
client.AFFINITY = coalesce(tointeger(row.CLM_REWARDS_NUMBER),"not applicable"),

client.GB_APP_DOWNLOAD = coalesce(toInteger(row.GB_APP_DOWNLOAD),"not applicable"),
client.MONEY_APP_DOWNLOAD = coalesce(toInteger(row.MONEY_APP_DOWNLOAD),"not applicable"),

client.CARD_SWIPER_ELIGIBLE = coalesce(toInteger(row.CARD_SWIPER_ELIGIBLE),"not applicable"),
client.CARD_SWIPER_OPTED = coalesce(toInteger(row.CARD_SWIPER_OPTED),"not applicable"),
client.CARD_SWIPER_OPTED_DATE=coalesce(date(row.CARD_SWIPER_OPTED_DATE),"not applicable"),

client.MONEY_MANAGER_ELIGIBLE=coalesce(toInteger(row.MONEY_MANAGER_ELIGIBLE),"not applicable"),
client.MONEY_MANAGER_OPTED=coalesce(toInteger(row.MONEY_MNAGER_OPTED),"not applicable"),
client.MONEY_MANAGER_OPTED_DATE = coalesce(date(row.MONEY_MNAGER_OPTED_DATE),"not applicable"),

client.RESPONSIBLE_BORROWER_ELIGIBLE = coalesce(toInteger(row.RESPONSIBLE_BORROWER_ELIGIBLE),"not applicable"),
client.RESPONSIBLE_BORROWER_OPTED = coalesce(toInteger(row.RESPONSIBLE_BORROWER_OPTED),"not applicable"),
client.RESPONSIBLE_BORROWER_OPTED_DATE = coalesce(date(row.RESPONSIBLE_BORROWER_OPTED_DATE),"not applicable"),

client.GREENBACKS = coalesce(toInteger(row.GREENBACKS),"not applicable"),
client.PROBABILISTIC = coalesce(toInteger(row.PROBABILISTIC),"not applicable"),
client.CAMPAIGN_POINTS = coalesce(toInteger(row.CAMPAIGN_POINTS),"not applicable"),
client.GREENBACKS_RANDVALUE = coalesce(toFloat(row.GREENBACKS_RANDVALUE),"not applicable"),

client.PROBABILISTIC_RANDVALUE = coalesce(toFloat(row.PROBABILISTIC_RANDVALUE),"not applicable"),
client.GREENBACKS_RANDRANGE = coalesce(row.GREENBACKS_RANDRANGE,"not applicable"),
client.PROBABILISTIC_RANDRANGE = coalesce(row.PROBABILISTIC_RANDRANGE,"not applicable")
RETURN count(client) AS client_count;

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_PBCVM.csv' AS row
MATCH (client:Client)
WHERE toInteger(client.dedupestatic)=toInteger(row.Dedupegroup)
SET client.dedupestatic=toInteger(client.dedupestatic)
RETURN COUNT(client) as count;


MATCH (c:Client)
WHERE toInteger(c.dedupestatic)=toInteger('2.11648211134e+11')
SET c.dedupestatic=toInteger(c.dedupestatic)
RETURN c;

match (client:Client)
where NOT apoc.meta.type(client.dedupestatic) = "STRING"
// SET 
return client LIMIT 10;


CALL apoc.periodic.iterate('match (client:Client)
where apoc.meta.type(client.dedupestatic) = "STRING"
return client;
', "SET client.dedupestatic=toInteger(client.dedupestatic);", {batchSize:10000, iterateList:true})
yield batches, total return batches, total;


match (client:Client)
where NOT apoc.meta.type(client.dedupestatic) = "STRING"
// SET 
return COUNT(client);
