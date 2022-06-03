GetTrees <- function() {
	con<-dbConnect(RPostgres::Postgres(), dbname="treebase") #Assumes you have postgres running on local computer with treebase dump loaded in as treebase db
temptable1 <- RPostgres::dbExecute(con, "CREATE TEMP TABLE author_by_pub AS SELECT  person_id, citation_id, author_order, CONCAT (person.firstname, ' ', person.mname, ' ', person.lastname) FROM person JOIN citation_author ON person.person_id = citation_author.authors_person_id;")
temptable2 <- RPostgres::dbExecute(con, "CREATE TEMP TABLE all_authors_by_pub AS SELECT author_by_pub.citation_id, string_agg (author_by_pub.concat, ', ') AS authors FROM author_by_pub GROUP BY author_by_pub.citation_id;")
treedf <- dbFetch(dbSendQuery(con, "SELECT * FROM phylotree
LEFT JOIN treekind ON phylotree.treekind_id = treekind.treekind_id
LEFT JOIN treetype ON phylotree.treetype_id = treetype.treetype_id
LEFT JOIN treequality ON phylotree.treequality_id = treequality.treequality_id
LEFT JOIN study ON phylotree.study_id = study.study_id
LEFT JOIN citation ON study.citation_id = citation.citation_id
LEFT JOIN all_authors_by_pub ON study.citation_id = all_authors_by_pub.citation_id
"))
for (i in sequence(ncol(treedf))) {
	treedf[,i] <- as.character(treedf[,i])
}
treedf_clean <- data.frame(phylotree_id = treedf$phylotree_id, tree_label = treedf$label, ntax=treedf$ntax, newickstring=treedf$newickstring, published=treedf$published, rootedtree=treedf$rootedtree, title=treedf$title, study_id=treedf$study_id, tree_kind = treedf$description, tree_type=treedf$description..24, tree_quality=treedf$description..27, tb_studyid=treedf$tb_studyid, accessionnumber=treedf$accessionnumber, lastmodifieddate=treedf$lastmodifieddate, name=treedf$name, notes=treedf$notes, releasedate=treedf$releasedate, pmid=treedf$pmid, url=treedf$url, abstract=treedf$abstract, doi=treedf$doi, keywords=treedf$keywords, pages=treedf$pages, publishyear=treedf$publishyear, papertitle=treedf$title..50, issue=treedf$issue, journal=treedf$journal, volume=treedf$volume, isbn=treedf$isbn, booktitle=treedf$booktitle, city=treedf$city, publisher=treedf$publisher, authors=gsub("  ", " ", treedf$authors))
dbDisconnect(con) 
return(treedf_clean)
}

GetTaxa <- function() {
	taxa <- dbFetch(dbSendQuery(dbConnect(RPostgres::Postgres(), dbname="treebase"), "SELECT * FROM taxonlabel"))
	taxa_clean <- data.frame(taxon=taxa$taxonlabel, study_id=taxa$study_id)
	return(taxa_clean)
}

SaveEachTree <- function(trees) {
	for(i in sequence(nrow(trees))) {
		cat(trees$newickstring[i], file=paste0("trees/tree_", trees$phylotree_id[i], ".phy"))
	}	
}

SaveEachStudy <- function(trees) {
	unique_studies <- unique(trees$study_id)
	for(i in sequence(length(unique_studies))) {
		rmarkdown::render(input="study.Rmd", output_file=paste0("studies/study_", unique_studies[i] , ".html"), 
		params=list(study_trees=trees[which(trees$study_id==unique_studies[i]),]))
	}		
}