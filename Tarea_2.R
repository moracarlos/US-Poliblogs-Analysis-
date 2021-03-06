#Carlos Mora 23595856
#Karina De Sousa 23696989

setwd('/Users/moracarlos/Desktop/Asignacion_2')
install.packages("igraph")
library('igraph')
library('plyr')
#1------------------------------------------------------
#Carga de los datos
graph = read.graph('polblogs.gml', format = "gml")

#2------------------------------------------------------
#Metricas globales
#Enlaces
ecount(graph)
#Vertices
vcount(graph)
# Diametro
diameter(graph)
# Nodos lejanos
farthest.nodes(graph)
#Grafica
plot(graph)

#3------------------------------------------------------
#Medidas de centralidad
centralidad <- data.frame(  
  deg=degree(graph),
  bet=betweenness(graph),
  clo=closeness(graph),
  eig=evcent(graph)$vector,
  cor=graph.coreness(graph)
)

save(centralidad, file = "centralidad.rda")

#4-------------------------------------------------------
#Distribucion de los grados de los blogs
degDist <- degree.distribution(graph)
plot(log(degDist))
hist(log(degDist))

#5-------------------------------------------------------
#Clustering
graph_clusters <- clusters(graph)
#graph es disconexo, por lo que debemos hallar la componente conexa
#mas grande del grafo para poder analizarlo
graph_conComp <- induced_subgraph(graph, which(graph_clusters$membership==which.max(graph_clusters$csize)))
graph_conComp
#Utilizamos el metodo del caminante aleatorio para hacer las medidas sobre el grafo
clusters <- cluster_walktrap(graph_conComp)$membership
clusters
count(clusters)
#Se obtienen 11 clusters, pero dos de ellos representan la mayor concentracion de individuos
#Detectamos la correspondiencia
length(V(graph_conComp)[value  == (clusters-1) ])
length(V(graph_conComp)[value  == (clusters-2) ])
#Obtenemos la correspondencia entre los valores obtenidos de la clusterizacion y los grupos en 
#el grafo de entrada

#6--------------------------------------------------------
#Blogs mas importantes
btw <- betweenness(graph_conComp)
maximo <- sort(btw,decreasing = TRUE)[15]

importantes <- V(graph_conComp)[which(maximo<betweenness(graph_conComp))]
importantes$label

#7--------------------------------------------------------
#Grafica
E(graph_conComp)[which(V(graph_conComp)$value==0) %--% which(V(graph_conComp)$value==1)]$color <- "yellow" #Enlaces a nodos de otra tendencia
E(graph_conComp)[which(V(graph_conComp)$value==1) %--% which(V(graph_conComp)$value==1)]$color <- "red" #Intergrupo
E(graph_conComp)[which(V(graph_conComp)$value==0) %--% which(V(graph_conComp)$value==0)]$color <- "blue"

#Se usa pagerank para medir la importancia de los nodos
plot(graph_conComp, vertex.label = NA, vertex.size = (page.rank(graph_conComp)$vector), edge.arrow.size = 0.01, edge.color=E(graph_conComp)$color)

png("Blogosfera.png", width = 1024, height = 768)
plot(graph_conComp, vertex.label = NA, vertex.size = (page.rank(graph_conComp)$vector), edge.arrow.size = 0.01, edge.color=E(graph_conComp)$color)
dev.off()
