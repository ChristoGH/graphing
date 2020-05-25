MATCH (you:Person)
DETACH DELETE you;
MATCH (shop:Shop)
DETACH DELETE shop;

:param Joe=>'Joe';
:param Johan=>'Johan';
:param Anna=>'Anna';
:param Julia=>'Julia';

CREATE (:Shop {name:"PNP"});
CREATE (:Shop {name:"SPAR"});
CREATE (:Shop {name:"CHECKERS"});
CREATE (:Shop {name:"WOOLWORTHS"});
CREATE (:Person {name:$Joe});
CREATE (:Person {name:$Johan});
CREATE (:Person {name:$Anna});
CREATE (:Person {name:$Julia});


MATCH (pnp:Shop {name:"PNP"})
MATCH (spar:Shop {name:"SPAR"})
MATCH (checkers:Shop {name:"CHECKERS"})
MATCH (woolworths:Shop {name:"WOOLWORTHS"})
MATCH (johan:Person {name:$Johan})
MATCH (anna:Person {name:$Anna})
MATCH (julia:Person {name:$Julia})
MATCH (joe:Person {name:$Joe})
WITH anna,johan,julia,joe,pnp,spar,checkers,woolworths
MERGE (joe)-[:SHOPPED {count:11}]->(pnp)
MERGE (joe)-[:SHOPPED {count:3}]->(spar)
MERGE (joe)-[:SHOPPED {count:6}]->(checkers)
MERGE (joe)-[:SHOPPED {count:17}]->(woolworths)
MERGE (johan)-[:SHOPPED {count:2}]->(pnp)
MERGE (johan)-[:SHOPPED {count:13}]->(spar)
// MERGE (you)<-[:SHOPPED {count:6}]-(:Shop {name:"CHECKERS"})
MERGE (johan)-[:SHOPPED {count:27}]->(woolworths)

MERGE (anna)-[:SHOPPED {count:13}]->(pnp)
MERGE (anna)-[:SHOPPED {count:33}]->(spar)
// MERGE (you)<-[:SHOPPED {count:6}]-(:Shop {name:"CHECKERS"})
// MERGE (you)<-[:SHOPPED {count:17}]->(:Shop {name:"WOOLWORTHS"});
// RETURN you;

// MERGE (you)-[:SHOPPED {count:11}]->(:Shop {name:"PNP"})
MERGE (julia)-[:SHOPPED {count:1}]->(spar)
MERGE (julia)-[:SHOPPED {count:16}]->(checkers)
MERGE (julia)-[:SHOPPED {count:9}]->(woolworths);
// RETURN you;

// MATCH (person:Person)
MATCH (shop0:Shop)-[shopped0:SHOPPED]-(shopper)-[shopped1:SHOPPED]-(shop1:Shop)
WHERE ID(shop0) < ID(shop1)
MERGE (shop0)-[mutual_shop:MUTUAL_SHOP]-(shop1)
ON CREATE SET mutual_shop.count0 = shopped0.count,
mutual_shop.count1=shopped1.count, mutual_shop.n = 1,
mutual_shop.ID0=ID(shop0),
mutual_shop.ID1=ID(shop1)
ON MATCH SET mutual_shop.count0 = mutual_shop.count0+shopped0.count,
mutual_shop.count1 = mutual_shop.count1+shopped1.count, 
mutual_shop.n = mutual_shop.n+1;


// "checkers to spar"
// MATCH (s1:Shop)-[rel:MUTUAL_SHOP]-(s2:Shop) WHERE ID(s1)=2794968 AND ID(s2)=2795040 
// call apoc.refactor.invert(rel)
// RETURN s1, s2, rel


// Determine direction of relationshp:
// MATCH (s1:Shop)-[rel:MUTUAL_SHOP]-(s2:Shop) WHERE ID(s1)=2794968 AND ID(s2)=2795040
// RETURN s1,s2,type(rel), (startNode(rel) = s1) as out_n


MATCH (s0:Shop)-[rel:MUTUAL_SHOP]-(s1:Shop)
WHERE ID(s0)=rel.ID0 AND ID(s1)=rel.ID1
WITH rel.count0<rel.count1 AS pointright, rel as relationship,(startNode(rel) = s0) as isright,s0,s1,
rel.count0 as count0,rel.count1 as count1, rel.ID0 as ID0, rel.ID1 as ID1, rel.n as n, ID(rel) as rel_id
FOREACH (p IN CASE WHEN (pointright and (NOT isright)) THEN [1] ELSE [] END |
    MERGE (s0)-[newrel:MUTUAL_SHOP]->(s1)
        ON CREATE SET newrel.count0 = count0,
        newrel.count1=count1,
        newrel.ID0=ID0,
        newrel.ID1=ID1,
        newrel.n=n
    DELETE relationship
)
FOREACH (p IN CASE WHEN ((NOT pointright) and isright) THEN [1] ELSE [] END |
    MERGE (s0)<-[newrel:MUTUAL_SHOP]-(s1)
        ON CREATE SET newrel.count0 = count0,
        newrel.count1=count1,
        newrel.ID0=ID0,
        newrel.ID1=ID1, 
        newrel.n=n
    DELETE relationship
)

rel.count0<rel.count1 AS pointright
rel.count0>rel.count1 AS pointleft
(startNode(rel) = s0) as isright
(startNode(rel) = s1) as isleft

change direction if 
pointright and isleft OR
pointleft and isright

((pointright AND (NOT isright)) OR ((NOT pointright) and isright))