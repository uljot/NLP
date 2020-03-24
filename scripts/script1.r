#załadowanie bibliotek
library(tm)
library(hunspell)
library(stringr)

#zmiana katalogu roboczego
workDir <- "D:/Studia/Przetwarzanie jezyka/NLP"
setwd(workDir)

#definicja katalogów funkcjonalnych
inputDir <- "./data"
outputDir <- "./results"
scriptsDir <- "./scripts"
workspacesDir <- "./workspaces"
dir.create(outputDir, showWarnings = TRUE)
dir.create(workspacesDir, showWarnings = TRUE)

#utworzenie korpusu dokumentów
corpusDir <-  paste(
  inputDir,
  "Literatura - streszczenia - oryginał",
  sep = "/"
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
  sep = "/"
)
stoplist <- readLines(stoplistFile, encoding = "UTF-8")
corpus <- tm_map(corpus, removeWords, stoplist)
corpus <- tm_map(corpus, stripWhitespace)

#usunięcie em dash i 3/4
remove_char <- content_transformer(function(x, pattern) gsub(pattern, "", x))
corpus <- tm_map(corpus, removeChar, intToUtf8(8722))
corpus <- tm_map(corpus, removeChar, intToUtf8(190))

polish <- dictionary(lang="pl_PL")

lemmatize <- function(text) {
  simpleText <- str_trim(as.character(text))
  parsedText <- strsplit(simple_text, split = " ")
  newTextVec <- hunspell_stem(parsedText[[1]], dict = polish)
  for (i in 1:length(new_text_vec)) {
    if (length(newTextVec[[i]]) == 0) newTextVec[i] <- parsedText[[1]][i]
    if (length(newTextVec[[i]]) > 1) newTextVec[i] <- newTextVec[[i]][1]
  }
  new_text <- paste(newTextVec, collapse = " ")
  return(newText)
}

corpus <- tm_map(corpus, content_transformer(lemmatize))

#usunięcie rozszerzeń z nazw plików
cutExtensions <- function(document){
  meta(document, "id") <- gsub(pattern = "/.txt$", replacement = "", meta(document, "id"))
  return(document)
}

corpus <- tm_map(corpus, cutExtensions)

#eksport zawartości korpusu do plików tekstowych
preprocessedDir <- paste(
  inputDir,
  "Literatura - streszczenia - przetworzone",
  sep = "/"
)
dir.create(preprocessedDir)
writeCorpus(corpus, path = preprocessedDir)

#wyświetlenie zawartości pojedynczego dokumentu
writeLines(as.character(corpus[[1]]))
writeLines(corpus[[1]]$content)
