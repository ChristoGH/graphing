CALL db.propertyKeys
CALL db.schema
:play intro-neo4j-exercises


/media/lnr-ai/applications/./neo4j-desktop-offline-1.2.7-x86_64.AppImage 

:play https://guides.neo4j.com/intro-neo4j-exercises/04.html
https://neo4j.com/graphacademy/online-training/introduction-to-neo4j/part-5/

~'Tom.*'

MATCH (gene:Person)-[a:ACTED_IN]-(geneMovie:Movie)-[:DIRECTED]-(director:Person), 
(anyactor:Person)-[:ACTED_IN]-(geneMovie:Movie) WHERE gene.name='Gene Hackman' 
RETURN geneMovie.title as Movie, anyactor.name as Coactor, 

MATCH (follow:Person)-[:FOLLOWS]-(James:Person) WHERE James.name= 'James Thompson' RETURN James, follow

MATCH (follow:Person)-[:FOLLOWS]-(James:Person) WHERE James.name= 'James Thompson' RETURN James, follow.

MATCH (p:Person)
WITH p, size((p)-[:ACTED_IN]->(:Movie)) AS movies
WHERE movies >= 5
OPTIONAL MATCH (p)-[:DIRECTED]->(m:Movie)
RETURN p.name, m.title

MATCH (actor:Person)-[acted_in:ACTED_IN]->(movie:Movie)
WITH (director:Person)-[directed:DIRECTED]->(movie:Movie)
RETURN movie.title as Movie, COLLECT(actor.name) AS Cast, COLLECT(director.name) as Directors