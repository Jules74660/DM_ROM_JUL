################################################################################
################################ DM ROM JUL ####################################
################################################################################

# SETUP ####

# //// CHARGEMENT DES PACKAGES /// ####

pacman::p_load(tidyverse, spsurvey, maptools, cartography, readxl, viridisLite, sf)
install.packages("maptools")

getwd() # si on ouvre avec le r.proj on devrait avoir le bon chemin sinon on copie colle le résultat

Chemin <- "/Users/jules/Desktop/Master/M2/strategie_echantillonage/DM_ROM_JUL"
setwd(Chemin)

# /// IMPORTATION DES DONNEES /// ####

download.file('http://www.donnees.statistiques.developpement-durable.gouv.fr/donneesCLC/CLC/region/CLC_D971_UTM_SHP.zip', destfile = 'CLC')
unzip('CLC')

#### 1 ####

### 1 - Corine Land Cover

# OBJECTIF : Importer le shp et la nomenclature puis rajouter une colonne avec le nom 
# en français du type de couverture des sols dans le shp

# Import de la nomenclature

nomenclature <- readxl::read_excel("CLC_D971_UTM_SHP/CLC_nomenclature.xls")

# Import du shapefile

couv2000 <- st_read("CLC_D971_UTM_SHP/CLC00/CLC00_D971_UTM.shp")
couv2006 <- st_read("CLC_D971_UTM_SHP/CLC06/CLC06_D971_UTM.shp")
couv2012 <- st_read("CLC_D971_UTM_SHP/CLC12/CLC12_D971_UTM.shp")

couv2000 <- couv2000 %>% 
  mutate(code_CLC = substr(as.character(CODE_00), 1, 1))

couv2006 <- couv2006 %>% 
  mutate(code_CLC = substr(as.character(CODE_06), 1, 1))

couv2012 <- couv2012 %>% 
  mutate(code_CLC = substr(as.character(CODE_12), 1, 1))



# Associer le type de sols au shapefile avec le code CLC dans CODE_00 du jeu de données nomenclature 

couv2000 <- left_join(couv2000, nomenclature, by = c("code_CLC" = "code_clc_niveau_1"))
couv2006 <- left_join(couv2006, nomenclature, by = c("code_CLC" = "code_clc_niveau_1"))
couv2012 <- left_join(couv2012, nomenclature, by = c("code_CLC" = "code_clc_niveau_1"))

#### 2 ####

## objectif : 2 - Faites une carte avec les différents types de sols 
# Carte de la couverture des sols

ggplot() +
  geom_sf(data = couv2000, aes(fill = code_CLC), color = NA) +
  scale_fill_viridis_d(option = "D", name = "Type de couverture des sols") +
  theme_minimal() +
  labs(title = "Couverture des sols en Guadeloupe",
       subtitle = "Données Corine Land Cover 2000",
       caption = "Source : data.gouv.fr") +
  theme(legend.position = "bottom")

# Il a des types de sols très peu représentés, vous décider de n' échantillonner que 
# ceux qui rassemblent plus de 500 HA et qui ne sont pas marin ( 5230 - Mers et océans)
# puisque vous vous intéressez à une espèce terrestre.






