// Our gephi file is here:
// /media/lnr-ai/downloads/gephi-0.9.2/bin/
// triadic_56101_community
// | Membership Count    | Community ID            |
// |---------------------|-------------------------|
// | 25                  | 7916                    | 1 KFC GROBLERS
// | 30                  | 2697                    | 2
// | 32                  | 6246                    | 3
// | 44                  | 6305                    | 4
// | 55                  | 6314                    | 5
// | 61                  | 290                     | 6
// | 69                  | 6790                    | 7
// | 72                  | 8577                    | 8
// | 84                  | 2160                    | 9
// | 96                  | 5959                    | 10
// | 109                 | 6244                    | 11
// | 115                 | 7805                    | 12
// | 122                 | 7579                    | 13
// | 128                 | 1875                    | 14
// | 149                 | 7544                    | 15
// | 187                 | 5898                    | 16
// | 241                 | 4914                    | 17
// | 258                 | 154                     | 18
// | 319                 | 6778                    | 19
// | 351                 | 5936                    | 20
// | 364                 | 6365                    | 21
// | 398                 | 8188                    | 22
// | 517                 | 1772                    | 23
// | 765                 | 5989                    | 24

// Relevant triadic_56101_community:
[7916,          
2697,
6246,
6305,
6314,
290,
6790,
8577,
2160,
5959,
6244,
7805,
7579,
1875,
7544,
5898,
4914,
154,
6778,
5936,
6365,
8188,
1772,
5989]


CommunityID:[]


match path = (:Client)-[:TRANSACTED_AT]->(:Merchant)
WITH path LIMIT 1000
with collect(path) as paths
call apoc.gephi.add(null,'workspace0', paths) yield nodes, relationships, time
return nodes, relationships, time

MATCH path=(c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND c.client_link_community_7916=44 AND m.subclass_id=56101
WITH path LIMIT 10000
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_test', paths) yield nodes, relationships, time
RETURN nodes, relationships, time;

MATCH path=(c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND m.subclass_id=56101
WITH path LIMIT 10000
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_test', paths) yield nodes, relationships, time
RETURN nodes, relationships, time;

MATCH path=(c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND m.subclass_id=56101
WITH path 
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_sa', paths) yield nodes, relationships, time
RETURN nodes, relationships, time;


// Push 7916 to gephi neo4j_7916 (transactians)
MATCH path=(c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND 
m.subclass_id=56101 AND
m.triadic_56101_community=7916
WITH path 
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_7916', paths, 'count', ['companyname', 'franchisename', 'client_link_community_7916','triadic_56101_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;

// CLIENT_LINK_7916 to gephi
MATCH path = (c0:Client)-[tcl:CLIENT_LINK_7916]-(c1:Client)
WHERE ID(c0)<ID(c1) AND tcl.count=1
RETURN PATH

MATCH path = (c0:Client)-[tcl:CLIENT_LINK_7916]-(c1:Client)
WHERE ID(c0)<ID(c1) 
WITH path 
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_client_link_7916', paths, 'count', ['client_link_community_7916']) yield nodes, relationships, time
RETURN nodes, relationships, time;

// Only use CLIENT_LINK_7916 where count>1
MATCH path = (c0:Client)-[tcl:CLIENT_LINK_7916]-(c1:Client)
WHERE ID(c0)<ID(c1) AND tcl.count>1
WITH path 
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_client_link_groblersdal', paths, 'count', ['companyname', 'franchisename', 'client_link_community_7916','triadic_56101_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;

// Only use CLIENT_LINK_7916 where count>1
MATCH path = (c0:GreenBacks)-[tcl:CLIENT_LINK_7916]-(c1:GreenBacks)
WHERE ID(c0)<ID(c1) AND tcl.count>1
WITH path 
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_client_link_groblersdal_greenbacks', paths, 'count', ['MONEY_MANAGER_OPTED','companyname', 'franchisename', 'client_link_community_7916','triadic_56101_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;



MATCH (c:Client)-[t:TRANSACTED_AT]->(m:Merchant)
WHERE EXISTS(c.client_link_community_7916) AND m.subclass_id=56101
RETURN c,t,m



// the following snippet apocs the nodes and relationships to gephi 
MATCH path=(m0:Merchant)-[t:TRIADIC_MERCHANT_FEET_LINK]->(m1:Merchant)
WHERE ID(m0)<ID(m1) AND 
m0.triadic_56101_community IN [7916,          
2697,
6246,
6305,
6314,
290,
6790,
8577,
2160,
5959,
6244,
7805,
7579,
1875,
7544,
5898,
4914,
154,
6778,
5936,
6365,
8188,
1772,
5989] AND
m1.triadic_56101_community IN [7916,          
2697,
6246,
6305,
6314,
290,
6790,
8577,
2160,
5959,
6244,
7805,
7579,
1875,
7544,
5898,
4914,
154,
6778,
5936,
6365,
8188,
1772,
5989]
with collect(path) as paths
call apoc.gephi.add(null,'neo4j_test', paths, 'count', ['companyname', 'franchisename', 'triadic_56101_community']) yield nodes, relationships, time
RETURN nodes, relationships, time;

// Test the above snippet:


MATCH (m:Merchant {subclass_id:56101})
WHERE EXISTS(m.triadic_56101_community) AND
m.triadic_56101_community IN 
[7916,          
2697,
6246,
6305,
6314,
290,
6790,
8577,
2160,
5959,
6244,
7805,
7579,
1875,
7544,
5898,
4914,
154,
6778,
5936,
6365,
8188,
1772,
5989]
RETURN COUNT(m.triadic_56101_community) as membercount, m.triadic_56101_community as triadic_56101_community
ORDER BY membercount ASC;
// Yields:
// +---------------------------------------+
// | membercount | triadic_56101_community |
// +---------------------------------------+
// | 25          | 7916                    |
// | 30          | 2697                    |
// | 32          | 6246                    |
// | 44          | 6305                    |
// | 55          | 6314                    |
// | 61          | 290                     |
// | 69          | 6790                    |
// | 72          | 8577                    |
// | 84          | 2160                    |
// | 96          | 5959                    |
// | 109         | 6244                    |
// | 115         | 7805                    |
// | 122         | 7579                    |
// | 128         | 1875                    |
// | 149         | 7544                    |
// | 187         | 5898                    |
// | 241         | 4914                    |
// | 258         | 154                     |
// | 319         | 6778                    |
// | 351         | 5936                    |
// | 364         | 6365                    |
// | 398         | 8188                    |
// | 517         | 1772                    |
// | 765         | 5989                    |
// +---------------------------------------+

// 7916

CALL gds.graph.create.cypher(
    'fastfood_7916',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 7916 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 7916 AND
    b.triadic_56101_community = 7916
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_7916', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+-----------------------------------------+
| franchisename     | score               |
+-----------------------------------------+
| "KFC GROBLERS"    | 0.8094224737747936  |
| "NANDOS GROBLER"  | 0.6707869509118609  |
| "DEBONAIRS SI"    | 0.6608892232550715  |
| "KFC MOUTSIYA"    | 0.6010461512487382  |
| "WIMPY GROBLERS"  | 0.5756242030136489  |
| "KFC KWAGGAFO"    | 0.47088854741305114 |
| "STEERS MORATIW"  | 0.441075232590083   |
| "DEBONAIRS GROB"  | 0.3946402884505006  |
| "KFC MOLOTO"      | 0.27750000506639483 |
| "McD Kwagga M"    | 0.26793750151991846 |
| "McD Groblers"    | 0.2592993791215122  |
| "KFC MOUTSE M"    | 0.23228345440002163 |
| "KFC MOUTSIYA M"  | 0.21375000253319743 |
| "KFC PHOLA PA"    | 0.19554937500506642 |
| "DEBONAIRS MORA"  | 0.18673407880123707 |
| "DEBONAIRS SIYA"  | 0.18673407880123707 |
| "DEBONAIRS JANE"  | 0.15000000000000002 |
| "KFC GROBLERSDA"  | 0.15000000000000002 |
| "KFC JANE FUR"    | 0.15000000000000002 |
| "KFC MARBLE H"    | 0.15000000000000002 |
| "KFC Moratiwa"    | 0.15000000000000002 |
| "KFC PHOLA PARK"  | 0.15000000000000002 |
| "KFC SIYABUSW"    | 0.15000000000000002 |
| "KFC SIYABUSWA"   | 0.15000000000000002 |
| "McD Groblersdal" | 0.15000000000000002 |
+-----------------------------------------+

// 2697 ==============================================================================
CALL gds.graph.create.cypher(
    'fastfood_2697',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 2697 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 2697 AND
    b.triadic_56101_community = 2697
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_2697', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+------------------------------------------------+
| franchisename            | score               |
+------------------------------------------------+
| "MCD Phuthaditj"         | 1.251080085898866   |
| "KENTUCKY FRIED"         | 1.226923955211532   |
| "KFC BETHLEHE"           | 1.041205925621034   |
| "WIMPY NEW MA"           | 0.638840493960015   |
| "KFC PHUTHADITJ"         | 0.4770744509864017  |
| "Nandos Maluti"          | 0.42625001519918443 |
| "KFC Ficksbur"           | 0.33196672994236    |
| "STEERS BETHLEH"         | 0.3247532891924493  |
| "Nandos Bethleh"         | 0.3203924919827841  |
| "Nandos Harrism"         | 0.2765109110157937  |
| "WIMPY RESTAURA"         | 0.24425893276929858 |
| "DEBONAIRS METR"         | 0.22368930791271852 |
| "STEERS SETSING"         | 0.22300893086940052 |
| "DEBONAIRS BETH"         | 0.20505474772653542 |
| "WIMPY WES - VI"         | 0.20446672329271684 |
| "WATASHI SPUR"           | 0.20175893055275085 |
| "WIMPY BETHLE"           | 0.18380474899313415 |
| "Nandos Bethlehem"       | 0.1712500003166497  |
| "SPUR WATASHI"           | 0.16559046278125608 |
| "CHICKEN LICKEN PHUTHAS" | 0.15000000000000002 |
| "Debonairs Berg"         | 0.15000000000000002 |
| "KFC BETHLEHEM"          | 0.15000000000000002 |
| "KFC HEILBRON"           | 0.15000000000000002 |
| "KFC NORTHRID"           | 0.15000000000000002 |
| "KFC QWA QWA"            | 0.15000000000000002 |
| "KFC SENEKAL"            | 0.15000000000000002 |
| "MCD Phuthaditjha ()"    | 0.15000000000000002 |
| "SEDIBENG WIMPY"         | 0.15000000000000002 |
| "WIMPY BETHLEHE"         | 0.15000000000000002 |
| "WIMPY TAKE AWA"         | 0.15000000000000002 |
+------------------------------------------------+

// 6246 ==============================================================================
CALL gds.graph.create.cypher(
    'fastfood_6246',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 6246 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 6246 AND
    b.triadic_56101_community = 6246
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_6246', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+----------------------------------------------+
| franchisename          | score               |
+----------------------------------------------+
| "STEERS VENTE"         | 0.9121082121847035  |
| "NANDOS - MAF"         | 0.7893556616274106  |
| "KFC LICHTENB"         | 0.6494125148421779  |
| "NANDOS - ZEERU"       | 0.5896455404528583  |
| "MCDONALDS CROS"       | 0.4956548074098263  |
| "KFC VENTERSD"         | 0.42600031505500574 |
| "CHICKEN LICKEN MEGA"  | 0.42066303130704913 |
| "MCD Mafikeng F"       | 0.40762194497402787 |
| "STEERS LICHTEN"       | 0.4049572076717709  |
| "STEERS AND F"         | 0.40336393448799296 |
| "DEBONAIRS EX"         | 0.2980464639811544  |
| "DEBONAIRS MA"         | 0.2814735050972558  |
| "MCD Mafikeng ("       | 0.27329830061935356 |
| "WIMPY CHOPPI"         | 0.26637335941341006 |
| "KFC MMABATHO"         | 0.23626488253939898 |
| "STEERS ZEERU"         | 0.2357148374426996  |
| "WIMPY MAFIKE"         | 0.22789769490482287 |
| "DEBONAIRS MAFIKENG"   | 0.22738542183069513 |
| "WIMPY LICHTE"         | 0.1964607102359878  |
| "MCD Mafikeng FS ()"   | 0.18187500126659872 |
| "WIMPY THE CR"         | 0.17769140626187438 |
| "KFC MAFIKENG"         | 0.16062500015832487 |
| "MCD Mafikeng ()"      | 0.16062500015832487 |
| "NANDOS MFK"           | 0.16062500015832487 |
| "WIMPY THE CROSSING"   | 0.16062500015832487 |
| "CHICKEN LICKEN MOLOP" | 0.15000000000000002 |
| "KFC CROSSING"         | 0.15000000000000002 |
| "KFC DELAREYV"         | 0.15000000000000002 |
| "KFC LICHTENBURG"      | 0.15000000000000002 |
| "KFC ZEERUST"          | 0.15000000000000002 |
| "LAGUNA SPUR"          | 0.15000000000000002 |
| "McDONALDS MAFI"       | 0.15000000000000002 |
+----------------------------------------------+

// 6305 ==============================================================================
CALL gds.graph.create.cypher(
    'fastfood_6305',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 6305 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 6305 AND
    b.triadic_56101_community = 6305
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_6305', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+------------------------------------------------+
| franchisename            | score               |
+------------------------------------------------+
| "STEERS RESTAUR"         | 1.426281152786396   |
| "MCDONALDS WORC"         | 1.2329586075360568  |
| "KFC COLESBER"           | 1.2067337917978878  |
| "MCD Worcester"          | 0.8184710582718253  |
| "KFC LAINGSBU"           | 0.7910386347823077  |
| "WIMPY  STOP C"          | 0.7709627713506052  |
| "KFC ROBERTSO"           | 0.7183253481372958  |
| "KFC WORCHEST"           | 0.6070547456736677  |
| "WIMPY SWELLEND"         | 0.5917686398563091  |
| "KFC MOUNTAIN"           | 0.5695766311226179  |
| "MCD Beaufort W"         | 0.5087101390410681  |
| "SPUR ROCKY R"           | 0.4184814618900418  |
| "KFC BEAUFORT"           | 0.4069988494331483  |
| "WIMPY HIGH S"           | 0.3974748073436785  |
| "WIMPY ROBERTSO"         | 0.3898659804428462  |
| "SPUR WORCESTER"         | 0.377317736443365   |
| "STEERS MOUNTAI"         | 0.3337283222936094  |
| "WIMPY LAINSB"           | 0.3239251024555415  |
| "KFC BREDASDO"           | 0.3211302639072528  |
| "SPUR SAN DIEGO"         | 0.2957142896950245  |
| "KFC VILLIERS"           | 0.2653163403709186  |
| "KFC WORCHESTER"         | 0.2500875041354448  |
| "STEERS MOUNTAIN MILL"   | 0.22388694975525142 |
| "MCDONALDS WORCESTER"    | 0.22085812634322793 |
| "KFC MOUNTAIN MILL"      | 0.21375000253319743 |
| "SPUR SOUTH WOR"         | 0.20531888788100336 |
| "DEBONAIRS WORCESTER"    | 0.18754945211112503 |
| "WIMPY CERES"            | 0.18754945211112503 |
| "WIMPY MOUNTAIN"         | 0.18754945211112503 |
| "KFC ROBERTSON"          | 0.16933516510762278 |
| "KFC SWELLEN"            | 0.16933516510762278 |
| "STEERS ROBERTS"         | 0.16933516510762278 |
| "DEBONAIRS BEAU"         | 0.15000000000000002 |
| "DEBONAIRS CERE"         | 0.15000000000000002 |
| "DEBONAIRS WORC"         | 0.15000000000000002 |
| "KFC CERES"              | 0.15000000000000002 |
| "KFC TUGELA N"           | 0.15000000000000002 |
| "KFC TUGELA S"           | 0.15000000000000002 |
| "MCD Worcester ()"       | 0.15000000000000002 |
| "McDONALDS BEAU"         | 0.15000000000000002 |
| "SPUR SOUTH WORCESTER"   | 0.15000000000000002 |
| "STEERS TOUWSRI"         | 0.15000000000000002 |
| "WIMPY MOUNTAIN MILL MA" | 0.15000000000000002 |
| "WYOMING SPUR"           | 0.15000000000000002 |
+------------------------------------------------+

// 6314 ==============================================================================
CALL gds.graph.create.cypher(
    'fastfood_6314',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 6314 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 6314 AND
    b.triadic_56101_community = 6314
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_6314', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+------------------------------------------------+
| franchisename            | score               |
+------------------------------------------------+
| "WIMPY GOUDKO"           | 3.199500108272824   |
| "WIMPY MOOI RIV"         | 2.8485257177624814  |
| "STEERS FLAMW"           | 1.2391432734196486  |
| "KFC MATLOLOS"           | 1.1393159630858267  |
| "DEBONAIRS POTC"         | 0.9241552814580825  |
| "KFC KLERKSDO"           | 0.8637932319243069  |
| "BURGER KING MO"         | 0.6463592166984985  |
| "McDONALDS PO"           | 0.6223058819989752  |
| "STEERS COMBO"           | 0.6035264580503281  |
| "Nandos Potchef"         | 0.5461162070766035  |
| "DEBONAIRS KLER"         | 0.5210686627038426  |
| "KFC POTCH GRIM"         | 0.5145123567019062  |
| "MCD Klerksdorp"         | 0.49624479238707697 |
| "KFC KLERKSDORP"         | 0.4795004655269336  |
| "KFC WILKOPPI"           | 0.44213004796627153 |
| "WIMPY MATLOS"           | 0.4329272009066266  |
| "KFC ELANDSHE"           | 0.4280395573562315  |
| "KFC POTCH GR"           | 0.415708335277176   |
| "KFC ELANDSHEUW"         | 0.4050874561567213  |
| "NANDOS KLERKSD"         | 0.37698146672359717 |
| "PIZZA HUT PO"           | 0.37155220097691094 |
| "SPUR SILVER LI"         | 0.35548727430421173 |
| "KFC POTCHEFSTR"         | 0.3288781283260178  |
| "MOCHACHOS KL"           | 0.31752449096045393 |
| "MCD Potchefstr"         | 0.31237612849612    |
| "SPUR ALBUQUERQ"         | 0.2645636170967317  |
| "WIMPY N POTC"           | 0.25262697786959853 |
| "ROCOMAMAS KLER"         | 0.2467124774868774  |
| "KFC DIE BULT"           | 0.2407483791222376  |
| "NANDOS POTCHEF"         | 0.23816000056994993 |
| "SPUR BEAR CREE"         | 0.2363600860410082  |
| "WIMPY WILKOPPIES"       | 0.22109918209316676 |
| "KFC KLERKSDORP N"       | 0.21302404903835853 |
| "CHICKEN LICKEN KLERKSD" | 0.2103568151513173  |
| "MONTANA SPUR"           | 0.2103568151513173  |
| "KFC POTCHEFS"           | 0.20882200661455957 |
| "KFC ORKNEY"             | 0.2012997494729689  |
| "WIMPY WILKOP"           | 0.1929120976887555  |
| "STEERS POTCHEF"         | 0.19037107479211104 |
| "PIZZA HUT KL"           | 0.19005428058298987 |
| "KFC WILKOPPIES"         | 0.18458437621593476 |
| "NANDOS KLERKSDORP"      | 0.18458437621593476 |
| "Steers Bailie"          | 0.1735111283824381  |
| "WIMPY GOUDKOPPIE"       | 0.1672921881079674  |
| "MCD Klerksdorp ()"      | 0.1627499997150153  |
| "NANDOS LATHAM"          | 0.1627499997150153  |
| "SPUR BEAR CREEK"        | 0.1627499997150153  |
| "BURGER KING MOOIRIVER"  | 0.15000000000000002 |
| "DEBONAIRS POTCHEFSTROO" | 0.15000000000000002 |
| "KFC IKAGENG"            | 0.15000000000000002 |
| "KFC POTCH GRIMBEE"      | 0.15000000000000002 |
| "KFC WOLLIES"            | 0.15000000000000002 |
| "SPUR NEBRASKA"          | 0.15000000000000002 |
| "Steers"                 | 0.15000000000000002 |
| "WIMPY DIE BULT"         | 0.15000000000000002 |
+------------------------------------------------+


// 290 ==============================================================================================
CALL gds.graph.create.cypher(
    'fastfood_290',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 290 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 290 AND
    b.triadic_56101_community = 290
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_290', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

+------------------------------------------------+
| franchisename            | score               |
+------------------------------------------------+
| "KFC IZINGOLWEN"         | 1.787641835651231   | -30.785287, 30.133689
| "MC DONALDS L"           | 1.5836965951912303  |
| "STEERS WILDCOA"         | 1.0577466506744244  |
| "WIMPY SHELLY"           | 0.968717723129942   |
| "KFC PORT SHEPS"         | 0.9110424789881122  |
| "KFC PORT EDWAR"         | 0.9010642513259015  |
| "WIMPY - MARGAT"         | 0.8029803575695365  |
| "Nandos Shelly"          | 0.7452352547528575  |
| "STEERS LADYS"           | 0.7078756421840808  |
| "KFC - HIBBERDE"         | 0.6289038789074705  |
| "MCD Ladysmith("         | 0.5446282574317594  |
| "KFC - THULINI"          | 0.542093450908198   |
| "KFC - ALLISON"          | 0.5043829431426275  |
| "STEERS MARGA"           | 0.4848438709012889  |
| "KFC - MARBURG"          | 0.4828630049878715  |
| "KFC - IZINGOLW"         | 0.39795322924104043 |
| "WIMPY ESTCOU"           | 0.39046853188727804 |
| "McDONALDS LADY"         | 0.37124060165006084 |
| "MC DONALDS LADYSMITH"   | 0.3672053635120392  |
| "KFC - PORT EDW"         | 0.3585981884580431  |
| "Nandos Port Sh"         | 0.3460822085112341  |
| "STEERS SHELL"           | 0.3439283159801363  |
| "KFC - GAMALAKH"         | 0.33494742509022934 |
| "KFC - PORT SHE"         | 0.33343587728470286 |
| "WIMPY SAN MARC"         | 0.3266097537321912  |
| "KFC MOOI RIV"           | 0.3187445351872157  |
| "Nandos Ladysmith Squar" | 0.30606228392571216 |
| "KFC SHELLY BE"          | 0.3032772516565075  |
| "WIMPY TED'S"            | 0.29368299126108466 |
| "CHICKEN LICKEN PO"      | 0.28827459617168644 |
| "DEBONAIRS PO"           | 0.27389982045377653 |
| "WIMPY MARGAT"           | 0.27098083689979113 |
| "PIZZA HUT SHEL"         | 0.25163806842427905 |
| "GEORGIA SPUR"           | 0.24084375202655794 |
| "Nandos Ladysmi"         | 0.23183378078974784 |
| "WIMPY LADYSM"           | 0.23175842608325187 |
| "KFC HIGHFLAT"           | 0.23119825575798494 |
| "DEBONAIRS ESTC"         | 0.22620605957054069 |
| "DEBONAIRS LA"           | 0.22149107381701472 |
| "KFC - ALLISON FAMILY T" | 0.21375000253319743 |
| "KFC LDYSMTH"            | 0.19250000063329936 |
| "KFC ESCOURT"            | 0.18574553690850737 |
| "WIMPY MOOI R"           | 0.1754999994300306  |
| "STEERS ORIBI"           | 0.16931573985602882 |
| "WIMPY ORIBI"            | 0.16931573985602882 |
| "CHICKEN LICKEN L/S ALE" | 0.1682142862118781  |
| "KFC BERGVILLE"          | 0.1682142862118781  |
| "WIMPY SOUTH"            | 0.16077458873041908 |
| "KFC BIZANA"             | 0.15854115033398558 |
| "KFC MARBURG"            | 0.15854115033398558 |
| "DEBONAIRS SH"           | 0.15000000000000002 |
| "KFC ESCOURT NO"         | 0.15000000000000002 |
| "KFC EZAKHENI"           | 0.15000000000000002 |
| "KFC HIBBERDENE"         | 0.15000000000000002 |
| "KFC LADYSMITH"          | 0.15000000000000002 |
| "KFC MARGATE"            | 0.15000000000000002 |
| "KFC SHELLY  BEA"        | 0.15000000000000002 |
| "KFC THULINI"            | 0.15000000000000002 |
| "McDONALDS LADYSMITH"    | 0.15000000000000002 |
| "Nandos Port Shepstone"  | 0.15000000000000002 |
| "WIMPY TED'S LA"         | 0.15000000000000002 |
+------------------------------------------------+

// 5989

CALL gds.graph.create.cypher(
    'fastfood_5989',
    'MATCH (m:Merchant {subclass_id:56101}) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 5989 RETURN ID(m) AS id',
    'MATCH (a:Merchant)-[:TRIADIC_MERCHANT_FEET_LINK]->(b:Merchant) WHERE ID(a)<ID(b) AND
    EXISTS(a.triadic_56101_community) AND EXISTS(b.triadic_56101_community) AND
    a.triadic_56101_community = 5989 AND
    b.triadic_56101_community = 5989
     RETURN ID(a) AS source, ID(b) AS target'
);

CALL gds.pageRank.stream('fastfood_5989', { maxIterations: 20, dampingFactor: 0.85 })
YIELD nodeId, score
RETURN gds.util.asNode(nodeId).franchisename AS franchisename, score
ORDER BY score DESC, franchisename ASC;

MATCH (client0:Client)-[cl:CLIENT_LINK_2697]-(client1:Client)
WHERE ID(client1)<ID(client0)
DELETE cl;


CALL apoc.periodic.iterate('MATCH (client0:Client)-[t0:TRANSACTED_AT]->(merchant:Merchant)<-[t1:TRANSACTED_AT]-(client1:Client)
WHERE ID(client0) < ID(client1) AND 
merchant.triadic_56101_community = 2697 
RETURN client0, client1, t0, t1;
', "MERGE (client0)-[link:CLIENT_LINK_2697]-(client1)
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
link.transactionamount1 = link.transactionamount1+t1.transactionamount;", {batchSize:200, iterateList:true, parallel:true})
yield batches, total return batches, total;


CALL gds.graph.create.cypher(
    'client_link_graph_2697',
    'MATCH (c0:Client)-[:TRANSACTED_AT]->(m:Merchant) WHERE EXISTS(m.triadic_56101_community) AND 
    m.triadic_56101_community = 2697 RETURN id(c0) AS id',
    'MATCH (c0:Client)-[rel:CLIENT_LINK_2697]-(c1:Client) RETURN id(c0) AS source, id(c1) AS target, rel.count as count'
)
YIELD graphName, nodeCount, relationshipCount, createMillis;

CALL gds.graph.exists('client_link_graph_2697') YIELD exists;

CALL gds.louvain.stream('client_link_graph_2697', { relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, includeIntermediateCommunities:true})
YIELD nodeId, communityId, intermediateCommunityIds
RETURN gds.util.asNode(nodeId).dedupestatic AS dedupestatic, communityId, intermediateCommunityIds
ORDER BY communityId DESC;

CALL gds.louvain.write('client_link_graph_2697', {relationshipWeightProperty: 'count', 
maxLevels:10, 
maxIterations:200, writeProperty: 'client_link_community_2697'})
YIELD communityCount, modularity, modularities;

MATCH (c:Client) 
WHERE EXISTS(c.client_link_community_2697) 
RETURN COUNT(c.client_link_community_2697) as count, c.client_link_community_2697 as 
client_link_community
ORDER BY count ASC


// Preseentation
1 Client ID = 2248959
2 3472932

MATCH path = (m0:Merchant)<-[:TRANSACTED_AT]-(:Client)-[:TRANSACTED_AT]->(m1:Merchant) 
WHERE  ID(m0)<ID(m1) AND m1.triadic_56101_community=7916 AND m0.triadic_56101_community=7916 RETURN path;

