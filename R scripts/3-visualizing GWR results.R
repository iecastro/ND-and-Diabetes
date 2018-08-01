library(cowplot)

## import data

results <-  st_read("~/Desktop/DataProjects/ND and Diabetes/ArcMap/GWR/Output/GWR_RESULTS.shp")
res.HS1 <-  st_read("~/Desktop/DataProjects/ND and Diabetes/ArcMap/GWR/residuals/residual_hotspot.shp")
res.HS2 <-  st_read("~/Desktop/DataProjects/ND and Diabetes/ArcMap/GWR/residuals/residual_hotspotZOI.shp")### local R2 map 

 ggplot() + geom_sf(data=results, aes(fill = LocalR2)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_distiller(type = "seq", direction = 1, labels = scales::percent) +
  labs(fill="Explained Variance") +
  ggtitle("Spatial variability in goodness-of-fit", subtitle = "determined by Local R-squared values")

##### coefficient maps
### obesity coefficient

A <- ggplot() + geom_sf(data=results, aes(fill = C1_obesity)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_viridis_c(option = "cividis", direction = -1) +
  labs(fill = expression(paste("Estimate", "(",beta,")"))) +
  ggtitle("Effect of Obesity on Diabetes Prevalence")

B <- ggplot() + geom_sf(data=results, aes(fill = StdErrC1_o)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_viridis_c(option = "magma", direction = 1) +
  labs(fill = "Std. Error") +
  ggtitle(" ", subtitle = "Precision of estimates for obesity variable")

  
### ND coefficient
C <- ggplot() + geom_sf(data=results, aes(fill =C2_PC1)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_viridis_c(option = "cividis", direction = -1) +
  labs(fill = expression(paste("Estimate", "(",beta,")"))) +
  ggtitle("Effect of Deprivation on Diabetes Prevalence")

D <- ggplot() + geom_sf(data=results, aes(fill = StdErrC2_P)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_viridis_c(option = "magma", direction = 1) +
  labs(fill = "Std. Error") +
  ggtitle(" ", subtitle = "Precision of estimates for deprivation variable")

### grid
plot_grid(A,B,C,D, ncol = 2)


###### residual maps
## std residuals 

ggplot() + geom_sf(data=results, aes(fill = StdResid)) +
  geom_sf(data=states,fill = NA,color = "#000000", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_distiller(type = "div", palette = "RdYlBu") 
  
## hot spot inversed distance
HS1 <- ggplot() + geom_sf(data=res.HS1, aes(fill = Gi_Bin)) +
  geom_sf(data=states,fill = NA,color = "#000000", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_distiller(type = "div", palette = "RdYlBu",breaks = c(-3,-2,0,2,3), 
                       labels =  c("99%","95%", "Not Sig.", "95%", "99%"))  + 
  labs(fill = "Confidence") +
  ggtitle("Hot Spot analysis of residual values", 
          subtitle = "with an Inverse Distance spatial relationship")
                     
## hot spot ZOI
HS2 <- ggplot() + geom_sf(data=res.HS2, aes(fill = Gi_Bin)) +
  geom_sf(data=states,fill = NA,color = "#000000", size=.5)+
  theme_minimal() + theme(axis.text = element_blank()) +
  scale_fill_distiller(type = "div", palette = "RdYlBu",breaks = c(-3,-2,0,2,3), 
                       labels =  c("99%","95%", "Not Sig.", "95%", "99%"))  + 
  labs(fill = "Confidence") +
  ggtitle("Hot Spot analysis of residual values", 
          subtitle = "with a Zone of Indifference spatial relationship")
### grid 
plot_grid(HS1,HS2, ncol=2)


