library(rsconnect)
rsconnect::deployApp('.',appName = "bulloterie_eig",forceUpdate = T,appFileManifest = "manifest.txt",account = "drees")
rsconnect::showLogs()
