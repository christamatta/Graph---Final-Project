// Preview of the graph database
match(n)
return n
limit 100


//Database schema (nodes and relationships)
CALL db.schema.visualization();


//Counts of nodes, node labels, relationships, relationship types, 
//property keys and statistics using the APOC library.
CALL apoc.meta.stats();


//Node labels and count
CALL db.labels() YIELD label
CALL apoc.cypher.run('MATCH (:`'+label+'`) RETURN count(*) as count', {})
YIELD value
RETURN label as Label, value.count AS Count


//Relationship types and count
CALL db.relationshipTypes() YIELD relationshipType as type
CALL apoc.cypher.run('MATCH ()-[:`'+type+'`]->() RETURN count(*) as count', {})
YIELD value
RETURN type AS Relationship, value.count AS Count


//Nb of streamers per their account creation year
MATCH (u:Stream)
WHERE u.createdAt IS NOT NULL
RETURN u.createdAt.year as year,
       count(*) as countOfNewStreamers
ORDER BY year;


//Games that have the highest count of streamers playing them
MATCH (g:Game)
RETURN g.name as game,
       count{ (g)<-[:PLAYS]-() } as number_of_streamers
ORDER BY number_of_streamers DESC
LIMIT 10


//Highest count of VIP relationships
MATCH (u:User)
RETURN u.name as user,
       count{ (u)-[:VIP]->() } as number_of_vips
ORDER BY number_of_vips DESC LIMIT 10;


//Highest count of moderators relationships
//Moderators (also known as mods) ensure that the chat meets the behavior and content standards set by the broadcaster by removing offensive posts and spam that detracts from conversations.
MATCH (u:User)
RETURN u.name as user,
       count{ (u)-[:MODERATOR]->() } as number_of_mods
ORDER BY number_of_mods DESC LIMIT 10;


//Matching five streamers and separately five users that chatted in the original streamer’s broadcast
MATCH (s:Stream)
WITH s LIMIT 1
CALL {
    WITH s
    MATCH p=(s)<--(:Stream)
    RETURN p
    LIMIT 5
    UNION
    WITH s
    MATCH p=(s)<--(:User)
    RETURN p
    LIMIT 5
}
RETURN p
//We can see that streamers behave like regular users. They can chat in other streamer’s broadcasts, be their moderator or VIP.


//Out degree of all nodes label
MATCH (n)
WITH n, labels(n) AS node_labels, COUNT{(n)-->()} AS out_degree
RETURN node_labels, apoc.agg.statistics(out_degree) AS out_degree_statistics
ORDER BY node_labels;


//In degree of all nodes label
MATCH (n)
WITH n, labels(n) AS node_labels, COUNT{(n)<--()} AS in_degree
RETURN node_labels, apoc.agg.statistics(in_degree) AS in_degree_statistics
ORDER BY node_labels;
