library(tidycensus)
library(tidyverse)
library(viridis)
library(sf)
library(tigris)
library(psych)
library(readxl)
library(scales)

options(tigris_class = "sf", tigris_use_cache = TRUE)
Sys.getenv("CENSUS_API_KEY")

### Deprivation variables 
vars <- c("B17001_002", "B17001_001", "B06009_002" , "B06009_001",
          "B09008_011", "B09008_001","B08124_002", "B08124_001", "B25014_005", 
          "B25014_006",  "B25014_007","B25014_011", "B25014_012", "B25014_013",  
          "B25014_001", "B19058_002", "B19058_001","C23002C_021", "C23002D_008", 
          "C23002C_017", "C23002D_003","B19001_002", "B19001_003", "B19001_004", 
          "B19001_005", "B19001_006", "B19001_001")


### get estimates for all US 
acs_us <- get_acs(geography = "county", variables = vars, year = 2013,
                  output = "wide") %>%
  mutate(pct_poverty = B17001_002E/B17001_001E,
         pct_noHS = B06009_002E / B06009_001E,
         pct_FHH = B09008_011E / B09008_001E,
         pct_mgmt = B08124_002E /  B08124_001E, 
         pct_crowd =  (B25014_005E +B25014_006E+ B25014_007E + 
                         B25014_011E + B25014_012E + B25014_013E) / B25014_001E,
         pct_pubassist = B19058_002E/B19058_001E,
         pct_unempl = (C23002C_021E + C23002D_008E)  / (C23002C_017E + C23002D_003E),
         pct_under30K =( B19001_002E+B19001_003E+B19001_004E+B19001_005E +
                           B19001_006E) / B19001_001E)

## select transformed variables
values  <-  acs_us %>% select(pct_poverty,pct_noHS,pct_FHH,pct_mgmt,pct_crowd,
                              pct_pubassist, pct_unempl,pct_under30K) %>% as.matrix()
values[is.nan(values)] <- 0
## PCA
ND <- principal(values,nfactors = 1)          
NDI_us <- cbind(acs_us,ND$scores) 

## 
NDI_us <- NDI_us %>% select(NAME,GEOID,PC1) %>% 
  separate(NAME, into = c("County","State"), sep = ",")

US_counties <- get_acs(geography = "county", variables = c("B01001_001"), 
                       output = "wide", geometry = TRUE, shift_geo = TRUE)

MapUS <- geo_join(US_counties,NDI_us, by_sp = "GEOID", by_df = "GEOID")

states <- get_acs(geography = "state", variables = c("B01001_001"), 
                  output = "wide", geometry = TRUE, shift_geo = TRUE)

### Map USA

ggplot() + geom_sf(data = MapUS, aes(fill = PC1)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5)+
  theme_minimal() + scale_fill_viridis_c(option = "inferno") +
  labs(fill = " ", caption = "Data: US Census ACS 2013 estimates")+
  ggtitle(" ", subtitle = "County-level Deprivation Index")

#### Get diabetes indicators

Diab_prev <- read_xlsx("~/Desktop/DataProjects/ND and Diabetes/DM_PREV_ALL_STATES2013.xlsx") %>%
  select(State,County ,FIPS = `FIPS Codes`, DiabPrev = `age-adjusted percent`)
  
Obes_prev <- read_xlsx("~/Desktop/DataProjects/ND and Diabetes/OB_PREV_ALL_STATES2013.xlsx") %>%
  select(State,County ,FIPS = `FIPS Codes`, ObPrev = `age-adjusted percent`)

Inact_prev <- read_xlsx("~/Desktop/DataProjects/ND and Diabetes/LTPIA_PREV_ALL_STATES2013.xlsx") %>%
  select(State,County,FIPS = `FIPS Codes`, InactPrev = `age-adjusted percent`)

### merge datasets

merge1 <- merge(Diab_prev,Obes_prev, by.x = c("County", "State"), by.y = c("County", "State"))
merge2 <- merge(merge1,Inact_prev,by.x = c("County", "State"), by.y = c("County", "State")) %>%
  select(-c(FIPS.y))
data <- merge(NDI_us,merge2,by.x = "GEOID", by.y = "FIPS.x", all.x=TRUE) %>%
  select(-c("FIPS")) 
  
## merge data to spatial attributes
MapDiab <- geo_join(US_counties,data, by_sp = "GEOID", by_df = "GEOID")


### map diabetes prevalence 

ggplot() + geom_sf(data=MapDiab, aes(fill = as.numeric(DiabPrev)/100)) +
  geom_sf(data=states,fill = NA,color = "#ffffff", size=.5) +
  scale_fill_viridis_c(option = "magma",labels = scales::percent) +
  theme_minimal()+ 
  labs(fill = " ", caption = "Data: CDC County-level Indicators, 2013")+
  ggtitle(" ", subtitle = "County-level, age-adjusted prevalence of diagnosed Diabetes in adults")

