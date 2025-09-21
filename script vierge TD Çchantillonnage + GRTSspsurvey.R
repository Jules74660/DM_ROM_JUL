### TD : Tirage d'un plan d'?chantillonnage

#######
##SRS##
#######

######################################
###SRS dans une aire/ un polygone ###
######################################
library(SDraw)
library(maptools)

Chemin <- "C:/Users/xxx/Desktop"  #d?finir votre working directory (le chemin dans votre ordinateur o?
#il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("nom de ton shapefile.shp")
nb<- 10                         # d?finir le nombre d'?chantillons voulus

samples<-srs.polygon(Shape, nb)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples


#########################
###SRS sur un linaire ###
#########################
library(SDraw)
library(maptools)
Chemin <- "C:/Users/xxx/Desktop"   #d?finir votre working directory (le chemin dans votre ordinateur o?
#il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("nom de ton  shapefile.shp")
nb<- 10                          # d?finir le nombre d'?chantillons voulus

samples<-srs.line(Shape, nb)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples

#################
###SRS points ###
#################
Chemin <- "C:/Users/xxx/Desktop"   #d?finir votre working directory (le chemin dans votre ordinateur o?
#il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("name of your shapefile.shp")
nb<- 10                          # d?finir le nombre d'?chantillons voulus

samples<-srs.point(Shape, nb)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples





###############
##### GRTS ####
###############

######################################
###GRTS dans une aire/ un polygone ###
######################################
library(SDraw)
library(maptools)

Chemin <- "C:/Users/xxx/Desktop"  #d?finir votre working directory (le chemin dans votre ordinateur o?
                                  #il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("nom de ton shapefile.shp")
nb<- 10                         # d?finir le nombre d'?chantillons voulus
over.n<-10                      # d?finir le nombre d'?chantillons suppl?mentaires voulus

samples<-grts.polygon(Shape, nb, over.n)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples


#########################
###GRTS sur un linaire ###
#########################
library(SDraw)
library(maptools)
Chemin <- "C:/Users/xxx/Desktop"   #d?finir votre working directory (le chemin dans votre ordinateur o?
                                    #il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("nom de ton  shapefile.shp")
nb<- 10                          # d?finir le nombre d'?chantillons voulus
over.n<-10                      # d?finir le nombre d'?chantillons suppl?mentaires voulus

samples<-grts.line(Shape, nb, over.n)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples

############################
###GRTS design on points ###
############################
Chemin <- "C:/Users/xxx/Desktop"   #d?finir votre working directory (le chemin dans votre ordinateur o?
                                  #il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)

Shape<-readShapeSpatial("name of your shapefile.shp")
nb<- 10                          # d?finir le nombre d'?chantillons voulus
over.n<-10                      # d?finir le nombre d'?chantillons suppl?mentaires voulus

samples<-grts.point(Shape, nb, over.n)
plot(Shape, col=rainbow(length(Shape)))
points(samples, pch=16 )
samples


#######################################
##### GRTS aire stratified #############
#######################################
library(spsurvey)
library(maptools)
Chemin <- "C:/Users/xxx/Desktop"   #d?finir votre working directory (le chemin dans votre ordinateur o?
#il y a votre shapefile). attention, utilisez "/" et non "\"
setwd(Chemin)




design<-list("strate_1"=list(panel=c(Panel=5), seltype="Equal", over=10), 
            "strate_2"=list(panel=c(Panel=5), seltype="Equal", over=10) )

GRTSpts <-spsurvey::grts(design= design,
                         type.frame="area",
                         src.frame="shapefile",
                         in.shape = "nom_du_shapefile_en_entree_sans_extention",
                         stratum = "nom_de_la_colonne_qui_contient_le_nom_des_strates",
                         shapefile=TRUE,
                         out.shape="nom_du_shape_en_sortie_sans_extension"
                         )

as.data.frame(GRTSpts)

######################################
# Sauvegarder le plan dans un fichier texte (il s'enregistre automatiquement dans le working directory)
# sauf pour GRTS avec {spsurvey} puisqu'il cr?e automatiquement un fichier shapefile

write.table(samples,file="myGRTSsurveyplan.txt")