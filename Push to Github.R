library(gh)
library(gitcreds)
library(remotes)
library(usethis)

usethis::create_github_token()

gitcreds::gitcreds_set()

gh::gh_whoami() 
usethis::git_sitrep() 
usethis::git_vaccinate()

usethis::use_git(message = "initial commit")
