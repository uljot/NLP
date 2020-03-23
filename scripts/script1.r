#załadowanie bibliotek
library(tm)

#zmiana katalogu roboczego
workDir <- "D:\\JU"
setwd(workDir)

#definicja katalogów funkcjonalnych
inputDir <- ".\\data"
outputDir <- ".\\results"
scriptsDir <- ".\\scripts"
workspacesDir <- ".\\workspaces"
dir.create(outputDir, showWarnings = TRUE)
dir.create(workspacesDir, showWarnings = TRUE)

#utworzenie korpusu dokumentów
corpusDir <-  paste(
  inputDir,
  "Literatura - streszczenia - oryginał",
  sep = "\\"
)
corpus <- VCorpus(
  DirSource(
    corpusDir,
    pattern = "*.txt",
    encoding = "UTF-8"
  ),
  readerControl = list(
    language = "pl_PL"
  )
)

#wstępne przetwarzanie
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, content_transformer(tolower))
stoplistFile <- paste(
  inputDir,
  "stopwords_pl.txt",
  sep = "\\"
)
stoplist <- readLines(stoplistFile, encoding = "UTF-8")
corpus <- tm_map(corpus, removeWords, stoplist)
corpus <- tm_map(corpus, stripWhitespace)

#wyświetlenie zawartości pojedynczego dokumentu
writeLines(as.character(corpus[[1]]))
writeLines(corpus[[1]]$content)
