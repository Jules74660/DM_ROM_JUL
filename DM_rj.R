################################################################################
################################ DM ROM JUL ####################################
################################################################################

# SETUP ####

# //// CHARGEMENT DES PACKAGES /// ####

pacman::p_load(tidyverse, spsurvey, maptools, cartography, readxl, viridisLite)

getwd() # si on ouvre avec le r.proj on devrait avoir le bon chemin sinon on copie colle le résultat

Chemin <- "/Users/jules/Desktop/Master/M2/strategie_echantillonage/DM_ROM_JUL"
setwd(Chemin)

# /// IMPORTATION DES DONNEES /// ####

download.file('http://www.donnees.statistiques.developpement-durable.gouv.fr/donneesCLC/CLC/region/CLC_D971_UTM_SHP.zip', destfile = 'CLC')
unzip('CLC')

## 1 - Corine Land Cover

# OBJECTIF : Importer le shp et la nomenclature puis rajouter une colonne avec le nom 
# en français du type de couverture des sols dans le shp

# Import du shapefile

couv <- st_read("CLC_D971_UTM_SHP.shp") 


#%>%
  st_transform(crs = 2154)
