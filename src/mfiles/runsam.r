mainsam <- function(){
    print("Begin SAM");
    .libPaths(c("/local/tknijnen/robot-cornea/R/samr/"))
    library(samr);
    .libPaths(c("/local/tknijnen/robot-cornea/R/rjson/"))
    library(rjson);
    x <- as.matrix(read.table("./inputs/samdata.txt"));
    y <- as.numeric(as.matrix(read.table("./inputs/samlabel.txt")));
    arg <- fromJSON(,"./inputs/perm.json","C");
    perms <- as.numeric(as.matrix(read.table("./inputs/samvar.txt")));
    data=list(x=x,y=y, geneid=as.character(1:nrow(x)),genenames=paste("g",as.character(1:nrow(x))),logged2=TRUE);
    samr.obj<-samr(data, resp.type=arg$resptype, nperms=perms[1],random.seed=perms[2]);
    tt <- samr.obj$tt;
    ttstar <- samr.obj$ttstar0;
    write(tt,file="./inputs/orgstat.txt",ncolumns=nrow(ttstar));
    write(t(ttstar),file="./inputs/permstat.txt",ncolumns=ncol(ttstar));
}

try(mainsam(), silent = FALSE)
q();







