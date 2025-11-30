# Install packages if not already installed
install.packages("did")
install.packages("data.table")   # helpful but optional

library(did)
library(data.table)

# If your data is in Python originally, load it the same way:
setwd('/Users/ElizabethMiriya/Desktop/')
df <- fread("did_df_crime.csv")

# Convert to data.table just for convenience (optional)
df <- as.data.table(df)

# Create the "g" column = first treatment period (or 0 if never treated)
# Callaway-Sant'Anna REQUIRES g=0 for never-treated units.
df[, g := ifelse(is.na(first_treat_year), 0, first_treat_year)]

# Estimate ATT(g,t) using CS DiD:

df$state_id <- as.numeric(as.factor(df$state))

cs <- att_gt(
  yname = "Y",
  tname = "year",
  idname = "state_id",
  
  gname = "g",      # first treatment year (0 = never-treated)
  
  # You can add controls here (X variables)
  xformla = ~ 1,    # no covariates; change to ~ X1 + X2 if needed
  
  data = df,
  est_method = "dr"  # doubly robust (recommended)
)



# 1: Summarize all group-time ATTs from the main CS estimate
summary(cs)

# 2: Event-study (dynamic) effects averaged across groups
agg <- aggte(cs, type = "dynamic")
ggdid(agg)

# 3: Per-group event-study plot (each group's dynamic effects)
ggdid(cs)

# 4: Overall ATT averaged across groups (NOT dynamic — a single number per group)
overall <- aggte(cs, type = "group")
ggdid(overall)




```
