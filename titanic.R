df = as.data.frame(Titanic)
# summarized data
df_a = df[df$Survived == "Yes", c("Class", "Sex", "Age", "Freq")]
names(df_a)[ncol(df_a)] = "YesFreq"
df_b = df[df$Survived == "No", c("Class", "Sex", "Age", "Freq")]
names(df_b)[ncol(df_b)] = "NoFreq"
df_mod = merge(df_a, df_b, by = c("Class", "Sex", "Age"))
df_mod$SProb = df_mod$YesFreq / (df_mod$YesFreq + df_mod$NoFreq)
df_mod = df_mod[!is.na(df_mod$SProb), ]

GetAcc = function(pred){
  # compare relative frequencies to predicted probabilities
  # summarize result as root mean squared deviation
  RMSD = sqrt(sum((pred - df_mod$SProb)^2 * (df_mod$YesFreq + df_mod$NoFreq)) / sum(df_mod$YesFreq + df_mod$NoFreq))
  return(RMSD)
}



# 1. CHI-SQUARED APPROACH

# based on relative frequencies
TestChiSq = function(M){
  ExpFreq = t(t(rowSums(M))) %*% colSums(M) / sum(M)
  if (min(ExpFreq) < 5){
    # The test is not reliable if one of the expected frequencies is below 5
    return(NaN)
  } else {
    return(chisq.test(M)$p.value)
  }
}

GetBestClass = function(Sex, Age){
  subset = df[df$Sex == Sex & df$Age == Age & df$Class != "Crew", ]
  M = as.table(cbind(subset[subset$Survived == "No", "Freq"], subset[subset$Survived == "Yes", "Freq"]))
  dimnames(M) = list(Class = 1:3, Survived = c(F, T))
  
  # Relative marginal frequencies by survival
  MRelFreq = apply(M, 2, function(x){x / rowSums(M)})[, 2]
  # P-values with Bonferroni adjustment
  Pval_1vs2 = TestChiSq(M[c(1, 2), ]) * 3
  Pval_1vs3 = TestChiSq(M[c(1, 3), ]) * 3
  Pval_2vs3 = TestChiSq(M[c(2, 3), ]) * 3
  
  ResDf = as.data.frame(cbind(MRelFreq, c(1, Pval_1vs2, Pval_1vs3), c(Pval_1vs2, 1, Pval_2vs3), c(Pval_1vs3, Pval_2vs3, 1)))
  rownames(ResDf) = c("1st", "2nd", "3rd")
  colnames(ResDf) = c("Prob", "pV1", "pV2", "pV3")
  
  return(ResDf)
}



# 2. LOGISTIC REGRESSION

model_bin = glm(Survived ~ Sex + Age + Class, weights = df$Freq, data = df, family = "binomial")
summary(model_bin)
# calculate accuracy
GetAcc(predict(model_bin, df_mod, type = "response"))



# 3. LINEAR REGRESSION

model_lin = lm((Survived == "Yes") ~ Sex + Age + Class, weights = df$Freq, data = df)
summary(model_lin)
anova(model_lin)
# calculate accuracy
GetAcc(predict(model_lin, df_mod, type = "response"))



# 4. LINEAR REGRESSION II.

# Fits to relative frequencies
model_lin2 = lm(SProb ~ Sex + Age + Class, weights = df_mod$YesFreq + df_mod$NoFreq, data = df_mod)
summary(model_lin2)
anova(model_lin2)
# calculate accuracy
GetAcc(predict(model_lin2, df_mod, type = "response"))

