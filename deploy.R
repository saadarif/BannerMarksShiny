# Authenticate
library(rsconnect)
setAccountInfo(name = "8ltxdw-saad-arif",
               token = Sys.getenv("TOKEN"),
               secret = Sys.getenv("SECRET"))
# Deploy
deployApp(appFiles = c("app.R"))