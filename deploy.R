# Authenticate
library(rsconnect)
setAccountInfo(name="8ltxdw-saad-arif",
               token=${{secrets.TOKEN}},
               secret=${{secrets.SECRET}} 
              ) 
# Deploy
deployApp(appFiles = c("app.R"))