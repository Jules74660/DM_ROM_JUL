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



# GRTS + carto
couv2012 <- couv2012 %>%
  filter(AREA_HA > 500 & code_CLC != "5")


library(spsurvey)

n_base <- c("1" = 10, "2" = 10, "3" = 10)

GRTSpts <- grts(
  sframe = couv2012,
  n_base = n_base,
  stratum_var = "code_CLC",
  DesignID = "DM_Rom_Jul"
)

GRTS_sf <- st_as_sf(GRTSpts$sites_base, coords = c("X","Y"), crs = st_crs(couv2012))


st_write(GRTS_sf, "tirage_GRTS.shp", delete_dsn = TRUE)


library(RColorBrewer)

colors_strata <- brewer.pal(3, "Set1")
couv2012$color <- case_when(
  couv2012$code_CLC == "1" ~ colors_strata[1],
  couv2012$code_CLC == "2" ~ colors_strata[2],
  couv2012$code_CLC == "3" ~ colors_strata[3]
)

plot(st_geometry(couv2012), col = couv2012$color, main = "Tirage GRTS par habitat")
plot(st_geometry(GRTS_sf), col = "black", pch = 15, add = TRUE)  # points en noir
legend("topright", legend = c("Habitat 1","Habitat 2","Habitat 3"),
       fill = colors_strata)


GRTS_df <- GRTSpts$sites_base
write.csv(GRTS_df, "tirage_GRTS.csv", row.names = FALSE)

