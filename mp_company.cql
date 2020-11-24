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
// sudo mv /media/lnr-ai/downloads/home/christo/data/clientswipes_202003_PBCVM.csv /var/lib/neo4j/import/
// sudo unzip wetransfer-186086.zip -d /media/lnr-ai/christo/github_repos/logistics/data/
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
./cypher-shell -u neo4j -p neo4j
// journalctl -e -u neo4j

// cd /usr/local/data
// sudo chown -R neo4j:neo4j /var/lib/neo4j/plugins
// sudo chown -R neo4j:neo4j /media/lnr-ai/neo4j/data
// seg_l3_num = [312,313,321,322,323,324,325,333,336]

./cypher-shell -u neo4j -p newPassword

// https://linuxize.com/post/how-to-add-swap-space-on-ubuntu-18-04/
// https://www.tecmint.com/clear-ram-memory-cache-buffer-and-swap-space-on-linux/
// CLEAR swap space: swapoff -a && swapon -a

CREATE CONSTRAINT ON (c:Client) ASSERT c.dedupestatic IS UNIQUE;
CREATE CONSTRAINT ON (m:Merchant) ASSERT m.franchisename IS UNIQUE;
CREATE CONSTRAINT ON (s:Segment) ASSERT s.seg_l3_num IS UNIQUE;
CREATE CONSTRAINT ON (c:Company) ASSERT c.companyname IS UNIQUE;

// <!-- Create the Client node here: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_PBCVM.csv' AS row
MERGE (c:Client {dedupestatic: toInteger(row.Dedupegroup)})
ON CREATE SET c.totaltransactionamount = toFloat(row.TransactionAmount),
c.totaltransactioncount = 1,
c.seg_l3_num=toInteger(row.Seg_L3_Num),
c.seg_l3_str=row.Seg_L3_STR,
c.period=row.period
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

CALL apoc.periodic.iterate('match (client:Client)
where apoc.meta.type(client.dedupestatic) = "STRING"
return client;
', "SET client.dedupestatic=toInteger(client.dedupestatic);", {batchSize:10000, iterateList:true})
yield batches, total return batches, total;


USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_PBCVM.csv' AS row
MERGE (c:Company {companyname:coalesce(row.companyname, "Unknown")})
ON CREATE SET c.companyindex = coalesce(toInteger(row.companyindex),"Unknown"),
c.totaltransactioncount = 1,
c.totaltransactionamount=toFloat(row.TransactionAmount),
c.period = row.period, 
c.discretionary = coalesce(toInteger(row.discretionary),"Unknown"),
c.class_id = coalesce(toInteger(row.class_id),"Unknown"),
c.division_id = coalesce(toInteger(row.division_id),"Unknown"),
c.group_id = coalesce(toInteger(row.group_id),"Unknown"),
c.subclass_id = coalesce(toInteger(row.subclass_id),"Unknown")
ON MATCH SET c.totaltransactioncount = c.totaltransactioncount + 1, 
c.totaltransactionamount=c.totaltransactionamount+toFloat(row.TransactionAmount)
RETURN count(c);

// <!-- Create COMPANY transaction relationships here, between Client and Company: -->
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///clientswipes_202003_PBCVM.csv' AS row
MATCH (client:Client {dedupestatic: toInteger(row.Dedupegroup)})
MATCH (company:Company {companyname: coalesce(row.companyname, "Unknown")})
MERGE (client)-[r:TRANSACTED_AT_COMPANY]->(company)
ON CREATE SET r.transactioncount = 1,
r.transactionamount = toFloat(row.TransactionAmount),
r.period = row.period,
r.db=row.db,
r.dbprefix=row.dbprefix
ON MATCH SET r.transactioncount = r.transactioncount + 1,
r.transactionamount = r.transactionamount + toFloat(row.TransactionAmount)
RETURN count(*);

USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///CLM_GB_CUSTOMERS_BASE_REPORT.csv' AS row
MERGE (client:Client {dedupestatic:toInteger(row.MASTER_CIS)})
ON MATCH 
SET client:GreenBacks
client.CLM_ENROL_DATE = coalesce(date(row.CLM_ENROL_DATE),"not applicable"),
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

MATCH (client:Client) WHERE client.dedupestatic=toInteger(row.MASTER_CIS) 
SET client:GreenBacks
        RETURN client LIMIT 25

CALL apoc.periodic.iterate('MATCH (company0:Company)<-[t0:TRANSACTED_AT_COMPANY]-(client:money_personalities_client)-[t1:TRANSACTED_AT_COMPANY]->(company1:Company)
WHERE ID(company0) < ID(company1) 
RETURN company0, company1, t0, t1;
', "MERGE (company0)-[link:MP_MERCHANT_FEET_LINK]-(company1)
ON CREATE SET link.count = 1,
link.count0 = t0.count,
link.count1= t1.count, 
link.ID0=ID(company0),
link.ID1=ID(company1),
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




MATCH (m0:Company)-[rel:MP_MERCHANT_FEET_LINK]-(m1:Company)
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
