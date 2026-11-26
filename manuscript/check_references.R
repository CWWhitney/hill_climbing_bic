# Check every entry in references.bib against Crossref, or against DataCite
# for arXiv DOIs (10.48550/...).
# Run from the repository root:  Rscript manuscript/check_references.R
# Needs a network and the jsonlite package.
# It compares DOI, title, year and first author. It does not check that a
# source supports the sentence that cites it: read the source for that.

lines <- readLines("manuscript/references.bib", encoding = "UTF-8")
lines <- lines[!grepl("^\\s*%", lines)]                      # drop comments
entries <- strsplit(paste(lines, collapse = "\n"), "\n(?=@)", perl = TRUE)[[1]]
entries <- entries[grepl("^\\s*@", entries)]

field <- function(entry, name) {
  m <- regmatches(entry, regexec(
    paste0("(?i)\\n\\s*", name, "\\s*=\\s*[{\"](.*?)[}\"],?\\s*(\\n|$)"),
    entry, perl = TRUE))[[1]]
  if (length(m)) m[2] else NA_character_
}
# compare text without braces, tags, punctuation or capital letters
plain <- function(x) tolower(gsub("[^[:alnum:]]", "", gsub("<[^>]+>|[{}\\\\]", "", x)))

problems <- 0
for (e in entries) {
  key <- sub("^\\s*@\\w+\\{([^,]+),.*", "\\1", strsplit(e, "\n")[[1]][1])
  doi <- field(e, "doi")
  if (is.na(doi)) {
    cat("NO DOI  ", key, ": verify by hand and record how in a note field\n")
    problems <- problems + 1
    next
  }
  arxiv <- startsWith(tolower(doi), "10.48550/")
  url <- paste0(if (arxiv) "https://api.datacite.org/dois/" else "https://api.crossref.org/works/",
                utils::URLencode(doi, reserved = TRUE))
  rec <- tryCatch(jsonlite::fromJSON(url), error = function(err) NULL)
  if (is.null(rec)) {
    cat("NOT FOUND", key, doi, "\n")
    problems <- problems + 1
    next
  }
  if (arxiv) {
    a <- rec$data$attributes
    title <- a$titles$title[1]
    family <- sub(",.*", "", a$creators$name[1])
    year <- NA    # the arXiv posting year can differ from the conference year
  } else {
    m <- rec$message
    title <- m$title[1]
    family <- m$author$family[1]
    year <- as.character(m$issued$`date-parts`[1])
  }
  wrong <- c(
    title  = plain(field(e, "title")) != plain(title),
    year   = !is.na(year) && !identical(field(e, "year"), year),
    author = !grepl(plain(family), plain(field(e, "author")), fixed = TRUE)
  )
  if (any(wrong)) {
    cat("MISMATCH", key, ":", paste(names(wrong)[wrong], collapse = ", "), "\n")
    problems <- problems + 1
  } else {
    cat("ok      ", key, "\n")
  }
}
cat(length(entries), "entries,", problems, "to look at\n")
if (problems > 0) quit(status = 1)
