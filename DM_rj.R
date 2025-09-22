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

# Import de la nomenclature feuille 4

nomenclature <- readxl::read_excel("CLC_D971_UTM_SHP/CLC_nomenclature.xls", sheet = 4)
#nomenclature <- readxl::read_excel("CLC_D971_UTM_SHP/CLC_nomenclature.xls")

# Import du shapefile

couv2000 <- st_read("CLC_D971_UTM_SHP/CLC00/CLC00_D971_UTM.shp")
couv2006 <- st_read("CLC_D971_UTM_SHP/CLC06/CLC06_D971_UTM.shp")
couv2012 <- st_read("CLC_D971_UTM_SHP/CLC12/CLC12_D971_UTM.shp")

#couv2000 <- couv2000 %>% 
#  mutate(code_CLC = substr(as.character(CODE_00), 1, 1))

#couv2006 <- couv2006 %>% 
#  mutate(code_CLC = substr(as.character(CODE_06), 1, 1))

#couv2012 <- couv2012 %>% 
#  mutate(code_CLC = substr(as.character(CODE_12), 1, 1))

# Associer le type de sols au shapefile avec le code CLC dans CODE_00 du jeu de données nomenclature couv2000

couv2000 <- left_join(couv2000, nomenclature, by = c("CODE_00" = "code_clc_niveau_4"))
couv2006 <- left_join(couv2006, nomenclature, by = c("CODE_06" = "code_clc_niveau_4"))
couv2012 <- left_join(couv2012, nomenclature, by = c("CODE_12" = "code_clc_niveau_4"))

# en faisant la somme des AREA_HA par habitat sa fait une valeur et il faut enlever ceux inféreieur en 500 ha 

couv2000 <- couv2000 %>%
  group_by(CODE_00, libelle_fr) %>%
  summarise(AREA_HA = sum(AREA_HA, na.rm = TRUE), .groups = "drop") %>%
  filter(AREA_HA >= 500) %>% 
  filter(CODE_00 != "5230")

couv2006 <- couv2006 %>%
  group_by(CODE_06, libelle_fr) %>%
  summarise(AREA_HA = sum(AREA_HA, na.rm = TRUE), .groups = "drop") %>%
  filter(AREA_HA >= 500) %>% 
  filter(CODE_06 != "5230")

couv2012 <- couv2012 %>%
  group_by(CODE_12, libelle_fr) %>%
  summarise(AREA_HA = sum(AREA_HA, na.rm = TRUE), .groups = "drop") %>%
  filter(AREA_HA >= 500) %>% 
  filter(CODE_12 != "5230")

#### 2 ####

## objectif : 2 - Faites une carte avec les différents types de sols 
# Carte de la couverture des sols

ggplot() +
  geom_sf(data = couv2012, aes(fill = CODE_12), color = NA) +
  scale_fill_viridis_d(option = "D", name = "Type de couverture des sols") +
  theme_minimal() +
  labs(title = "Couverture des sols en Guadeloupe",
       subtitle = "Données Corine Land Cover 2000",
       caption = "Source : data.gouv.fr") +
  theme(legend.position = "bottom")

# Il a des types de sols très peu représentés, vous décider de n' échantillonner que 
# ceux qui rassemblent plus de 500 HA et qui ne sont pas marin ( 5230 - Mers et océans)
# puisque vous vous intéressez à une espèce terrestre.

  # GRTS + carto

library(spsurvey)

codes <- c("1120","1210","2112","2222","2310","2420","2430",
                  "3111","3112","3220","3230","3240","4110")

n_base <- setNames(rep(3, length(codes)), codes)

GRTSpts <- grts(
  sframe = couv2012,
  n_base = n_base,
  stratum_var = "CODE_12",
  DesignID = "DM_Rom_Jul"
)

GRTS_sf <- st_as_sf(GRTSpts$sites_base, coords = c("X","Y"), crs = st_crs(couv2012))


st_write(GRTS_sf, "tirage_GRTS.shp", delete_dsn = TRUE)



library(viridis)
library(dplyr)
library(sf)
library(RColorBrewer)

colors_strata <- viridis(13)
couv2012$color <- colors_strata[match(couv2012$CODE_12, codes)]

plot(st_geometry(couv2012), col = couv2012$color, main = "Tirage GRTS par habitat")
plot(st_geometry(GRTS_sf), col = "red", pch = 15, add = TRUE)  # points en noir

legend("topright", legend = c("Habitat 1","Habitat 2","Habitat 3","Habitat 4","Habitat 5",
                              "Habitat 6","Habitat 7","Habitat 8","Habitat 9",
                              "Habitat 10","Habitat 11","Habitat 12","Habitat 13"),
       fill = colors_strata[1:13])

GRTS_df <- GRTSpts$sites_base
write.csv(GRTS_df, "tirage_GRTS.csv", row.names = FALSE)


