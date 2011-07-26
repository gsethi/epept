maingsea <- function(){
    print("Begin GSEA");
    .libPaths(c("/local/tknijnen/robot-cornea/R/samr/"))
    library(samr);
    .libPaths(c("/local/tknijnen/robot-cornea/R/rjson/"))
    library(rjson);
    .libPaths(c("/local/tknijnen/robot-cornea/R/GSA/"))
    library(GSA);
    x <- as.matrix(read.table("./inputs/gseadata.txt"));
    y <- as.numeric(as.matrix(read.table("./inputs/gsealabel.txt")));
    genenames <- strsplit(readLines("./inputs/genenames.txt"),split="\t");
    genenames <- genenames[[1]];
    geneset.obj<- GSA.read.gmt("./inputs/geneset.txt")
    arg <- fromJSON(,"./inputs/perm.json","C");
    perms <- as.numeric(as.matrix(read.table("./inputs/gseavar.txt")));
   
    GSA.obj <-GSA(x,y, genenames=genenames, genesets=geneset.obj$genesets,  resp.type=arg$resptype, nperms=perms[1], random.seed=perms[2],method=arg$gsa_method)

    tt <- GSA.obj$GSA.scores;
    ttstar <- GSA.obj$GSA.scores.perm;
    write(tt,file="./inputs/orgstat.txt",ncolumns=nrow(ttstar));
    write(t(ttstar),file="./inputs/permstat.txt",ncolumns=ncol(ttstar));
    write(geneset.obj$geneset.names,file="./inputs/genesetnames.txt",1);
  
}

try(maingsea(), silent = FALSE)
q();







