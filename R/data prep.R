stratified_sample <- function(data, strat_column, size_per_stratum) {
strata <- unique(data[[strat_column]])
sampled_data <- do.call(rbind, lapply(strata, function(stratum) {
  subset_data <- data[data[[strat_column]] == stratum, ]
  subset_data[sample(nrow(subset_data), size_per_stratum), ]
}))
return(sampled_data)
}

do_dates <- function(df){
  df$date <- paste0("01-", df$obs_monthnum, "-", df$obs_year)
  df$date <- as.Date(df$date, "%d-%m-%Y")
  return(df)
}

do_dates2 <- function(df){
  df$date <- paste0("01-", df$month, "-", df$obs_year)
  df$date <- as.Date(df$date, "%d-%b-%Y")
  return(df)
}

data_coll <- read.csv("data_coll_allvars.csv") |> do_dates()

## Set up cat2
hunger_obs <- data_coll |>
  #filter(cat!=2 & cat!=3) |>
  group_by(date) |>
  summarize(n=n())
hunger_obs <- hunger_obs |> filter(n>100)

data_coll <- left_join(hunger_obs, data_coll, by="date")

#data_coll_cat3 <- data_coll |> filter(cat!=1 & cat!=2)
hunger_samps <- list()
for(i in 1:5){
  hunger_samp <- stratified_sample(data_coll, "date", 100)
  write.csv(hunger_samp, sprintf("Subsamples/data_coll_samp%i_train_cat1.csv", i))
  #hunger_samps[i] <- hunger_samp
}

do_dates <- function(df){
df$date <- paste0("01-", df$obs_monthnum, "-", df$obs_year)
df$date <- as.Date(df$date, "%d-%m-%Y")
return(df)
}

data_coll <- read.csv("Subsamples/data_coll_allvars.csv") |> do_dates()
hunger_obs <- data_coll |>
  group_by(date) |>
  summarize(n=n())
hunger_obs <- hunger_obs |> filter(n>100)


data_coll <- left_join(hunger_obs, data_coll, by="date")

#data_coll_cat3 <- data_coll |> filter(cat!=1 & cat!=2)
for(wave in c(1,3,4)){
  hunger_samps <- list()
  eas <- data_coll[data_coll$wave==wave,] |> select(enum) |> distinct()
  eas <- eas[sample(1:nrow(eas)),]
  eas <- data.frame(enum=eas)
  eas$stratum <- rep(seq(1:5), length.out=nrow(eas))
  
  for(i in 1:5){
    hunger_samp <- left_join(eas |> filter(stratum==i), data_coll[data_coll$wave==wave,], by="enum")
    write.csv(hunger_samp, sprintf("Subsamples/data_coll_samp%i_wave%i_train.csv", i,wave))
    hunger_samps[[i]] <- hunger_samp
  }
  
  for(i in 1:5){
    hunger_samp_out <- do.call(rbind, hunger_samps[-i])
    write.csv(hunger_samp_out, sprintf("Subsamples/data_coll_samp%i_wave%i_test.csv", i, wave))
  }
}

for(wave in c(1,2,3,4)){
  print(sprintf("wave=%i", wave))
  eas <- data_coll[data_coll$wave==wave,] |> select(enum) |> distinct()
  for(i in 1:5){ 
    print(sprintf("round=%i", i))
    eas_out <- eas[sample(1:nrow(eas)),]
    eas_out <- data.frame(enum=eas_out)
    eas_out$stratum <- rep(seq(1:2), length.out=nrow(eas_out))
  
    hunger_samp <- left_join(eas_out |> filter(stratum==1), data_coll[data_coll$wave==wave,], by="enum")
    write.csv(hunger_samp, sprintf("D:/MWI Data/data_coll_samp%i_wave%i_train50.csv", i,wave))
    
    hunger_test <- left_join(eas_out |> filter(stratum==2), data_coll[data_coll$wave==wave,], by="enum")
    write.csv(hunger_test, sprintf("D:/MWI Data/data_coll_samp%i_wave%i_test50.csv", i, wave))
  }
}

