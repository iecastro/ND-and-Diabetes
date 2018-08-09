library(apaTables)
library(jtools)
library(sjPlot)
library(spdep)

#### set data 
data <- data %>% select(-c(State.x,County.y)) %>% 
  as.tibble()

data$DiabPrev <- as.numeric(data$DiabPrev)
data$ObPrev <- as.numeric(data$ObPrev)
data$InactPrev <- as.numeric(data$InactPrev)

## blocked model 
lm1 <- lm(DiabPrev~ObPrev+InactPrev, data = data)
lm2 <- lm(DiabPrev~ObPrev+InactPrev + PC1, data = data)

## compare models
apa.reg.table(lm1,lm2)

sjt.lm(lm1,lm2,depvar.labels = c("Block 1","Block 2"),
       pred.labels = c("Obesity Prevelence", "Inactivity Prevalence","Area Deprivation"),
       show.r2 = TRUE, show.fstat = TRUE, show.ci = TRUE,show.se = TRUE)

## plots 
ggplot(data, aes(PC1,DiabPrev)) + geom_point() +
  stat_smooth() + theme_classic() +
  labs(x = "County-level Deprivation Index", y = "Diagnosed Diabetes Prevalence (%)")

ggplot(data, aes(PC1,DiabPrev)) + geom_point(aes(color = ObPrev/100)) +
  stat_smooth() + theme_classic() +
  labs(x = "County-level Deprivation Index", y = "Diagnosed Diabetes Prevalence (%)",
       color = "Obesity") +
  scale_color_viridis_c(option="inferno", direction = -1, labels = scales::percent)


## interaction model
int <- lm(DiabPrev~InactPrev+ObPrev*PC1, data = data)
summ(int,center = TRUE)

interact_plot(int, pred = ObPrev, modx = PC1,
              interval = TRUE, int.type = "confidence", 
              x.label = "Obesity Prevalence (%)", y.label = "Diagnosed Diabetes Prevalence (%)")+
             theme_apa(legend.pos = "topleft") + 
              ggtitle("County-level Deprivation", 
              subtitle = "moderates the relationship between obesity and diabetes")


########## spatial autocorrelation

## create neighbors
MapSP <- as_Spatial(MapDiab)  ## convert to Spatial Polygons

coords <- coordinates(MapSP) 
IDs <- row.names(as(MapSP, "data.frame"))

neighbors <- tri2nb(coords, row.names = IDs)

## Moran's I
MapSP$diabetes <- as.numeric(MapSP$DiabPrev)

moran.test(MapSP$diabetes,nb2listw(neighbors),na.action = na.omit)

MapSP$diabetes <- ifelse(is.na(MapSP$diabetes), 0, MapSP$diabetes)
moran.plot(MapSP$diabetes,nb2listw(neighbors), zero.policy = FALSE, 
           labels = FALSE,main=c(" "),
           xlab="Diabetes Prevalence",ylab = "Spatially Lagged Diabetes Prevalence")



## export SF to shapefile 
st_write(MapDiab,"MapDiab.shp")  ## all spatial analysis done in ArcMap


