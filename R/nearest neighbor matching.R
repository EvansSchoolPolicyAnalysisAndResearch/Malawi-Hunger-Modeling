#Comparing accuracy with nearest neighbor.
library(sf)

data_coll <- read.csv("data_coll_allvars.csv") #From containing folder

conf_mat <- function(data, col1, col2) {
  if(with(data, exists("pred"))){
    data <- data |> select(-pred)
  }
  confskey <- data.frame(col1=c(0,1,0,1), col2=c(0,0,1,1), pred=factor(c(1,2,3,4), labels=c('tn', 'fp', 'fn', 'tp')))
  data <- merge(data, confskey, by.x=c(col1, col2), by.y=c("col1", "col2"))
  return(data)
}

calc_metrics <- function(data, col){
  mets <- table(data[[col]])
  precision=round(mets[[4]]/(mets[[4]]+mets[[3]]),3)
  recall=round(mets[[4]]/(mets[[4]]+mets[[2]]),3)
  accuracy=round((mets[[1]]+mets[[4]])/sum(mets), 3)
  cat(sprintf("Precision: %f\nRecall: %f\nAccuracy: %f", precision, recall, accuracy))
}


data_coll_w1 <- data_coll |> filter(wave==1) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w1=cat_cat1, cat2_w1=cat_cat2)
data_coll_w2 <- data_coll |> filter(wave==2) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w2=cat_cat1, cat2_w2=cat_cat2)

data_coll_w12 <- merge(data_coll_w1, data_coll_w2, by=c("enum","month"))
data_coll_w12 <- conf_mat(data_coll_w12, "cat2_w1", "cat2_w2")
calc_metrics(data_coll_w12, "pred")


data_coll_w1 <- data_coll |> filter(wave==1 & panel==0) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w1=cat_cat1, cat2_w1=cat_cat2)
data_coll_w2 <- data_coll |> filter(wave==2) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w2=cat_cat1, cat2_w2=cat_cat2)
data_w1_sp <- data_coll |> filter(wave==1 & panel==0) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_w2_sp <- data_coll |> filter(wave==2) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_w2_sp$w1_enum <- sapply(1:nrow(data_w2_sp), FUN=function(x){
  return(
    data_w1_sp$enum[st_nearest_feature(data_w2_sp[x,], data_w1_sp)[[1]]]
  )
})
data_w2_sp <- st_drop_geometry(data_w2_sp)
data_coll_w1.2 <- merge(data_coll_w2, data_w2_sp, by='enum')
data_coll_w1.2 <- merge(data_coll_w1.2, data_coll_w1, by.x=c('w1_enum', 'month'), by.y=c('enum', 'month'))
data_coll_w1.2 <- conf_mat(data_coll_w1.2, "cat1_w1", "cat1_w2")
calc_metrics(data_coll_w1.2, "pred")

data_coll_w1.2 <- data_coll_w1.2 |> select(-starts_with("pred"))
data_coll_w1.2 <- conf_mat(data_coll_w1.2, "cat2_w1", "cat2_w2")

calc_metrics(data_coll_w1.2, "pred")

data_coll_w2.3 <- conf_mat(data_coll_w2.3, "cat2_w2", "cat2_w3")
calc_metrics(data_coll_w2.3, "pred")


data_w3_sp <- data_coll |> filter(wave==3) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_w4_sp <- data_coll |> filter(wave==4) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_coll_w3 <- data_coll |> filter(wave==3) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w3=cat_cat1, cat2_w3=cat_cat2)
data_coll_w4 <- data_coll |> filter(wave==4) |> select(month, enum, date, cat_cat1, cat_cat2) |> rename(cat1_w4=cat_cat1, cat2_w4=cat_cat2)
data_w4_sp$w3_enum <- sapply(1:nrow(data_w4_sp), FUN=function(x){
  return(
data_w3_sp$enum[st_nearest_feature(data_w4_sp[x,], data_w3_sp)[[1]]]
)
})

data_w4_sp <- st_drop_geometry(data_w4_sp)
data_coll_w3.4 <- merge(data_coll_w4, data_w4_sp, by='enum', all.x=T)
data_coll_w3.4 <- merge(data_coll_w3.4, data_coll_w3, by.x=c('w3_enum', 'month'), by.y=c('enum', 'month'), all.x=T)
data_coll_w3.4 <- conf_mat(data_coll_w3.4, "cat1_w3", "cat1_w4")
calc_metrics(data_coll_w3.4, "pred")

data_coll_w3.4 <- conf_mat(data_coll_w3.4, "cat2_w3", "cat2_w4")
calc_metrics(data_coll_w3.4, "pred")





data_w2_sp <- data_coll |> filter(wave==2) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_w3_sp <- data_coll |> filter(wave==3) |> select(enum, lat, lon) |> distinct() |> st_as_sf(coords=c('lon','lat'))
data_coll_w2 <- data_coll |> filter(wave==2) |> select(month, enum, cat_cat1, cat_cat2) |> rename(cat1_w2=cat_cat1, cat2_w2=cat_cat2)
data_coll_w3 <- data_coll |> filter(wave==3) |> select(month, enum, date, cat_cat1, cat_cat2) |> rename(cat1_w3=cat_cat1, cat2_w3=cat_cat2)
data_w3_sp$w2_enum <- sapply(1:nrow(data_w3_sp), FUN=function(x){
  return(
    data_w2_sp$enum[st_nearest_feature(data_w3_sp[x,], data_w2_sp)[[1]]]
  )
})

data_w3_sp <- st_drop_geometry(data_w3_sp)
data_coll_w2.3 <- merge(data_coll_w3, data_w3_sp, by='enum', all.x=T)
data_coll_w2.3 <- merge(data_coll_w2.3, data_coll_w2, by.x=c('w2_enum', 'month'), by.y=c('enum', 'month'), all.x=T)
data_coll_w2.3 <- conf_mat(data_coll_w2.3, "cat1_w2", "cat1_w3")
calc_metrics(data_coll_w2.3, "pred")

data_coll_w2.3 <- conf_mat(data_coll_w2.3, "cat2_w2", "cat2_w3")
calc_metrics(data_coll_w2.3, "pred")