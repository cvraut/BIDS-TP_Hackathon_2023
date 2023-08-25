meta_cols<-colnames(cell_features_TS2PL1)[1:22]
objectid_cols<-which(str_detect(colnames(cell_features_TS2PL1), "Number"))
rm_cols<-colnames(cell_features_TS2PL1)[c(1:22, objectid_cols)]

cell_features_nometa = cell_features_TS2PL1 %>%
  select(-rm_cols)



