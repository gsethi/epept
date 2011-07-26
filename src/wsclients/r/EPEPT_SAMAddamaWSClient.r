print("Begin Execution -> Init Permutation input variables and Load JSON Library");
#init
library(rjson);

#args <- rev(commandArgs());
args = '';
args[1] = "{mode:\"SAM\",rseed:\"9999\",nperms:\"999\",resptype:\"Quantitative\",mail_address:\"jlin212@gmail.com\",ci:\"95\",oopt_chk:\"false\",ci_chk:\"true\",cc_chk:\"false\",method:\"PWM\"}"
args[2] = "./out"
args[3] = "http://informatics.systemsbiology.net"
args[4] = "/local/EPEPT/yeastdata.tsv"
#args[5] = "/local/EPEPT/geneset.gmt" GSEA mode only
print(args);

splittedFilePath = strsplit(args[4], "/", fixed=TRUE);
mylength = length(splittedFilePath[[1]]);
myOutFile = splittedFilePath[[1]][mylength];
splittedFileName = strsplit(myOutFile, ".", fixed=TRUE);
myOutFile = splittedFileName[[1]][1];
myOutFile = paste(myOutFile, ".txt", sep="");

epept_params = args[1]; 
pOutput = args[2]; 
host = args[3]; 
inFile = args[4];
#gsFile = args[5]; GSEA mode only
addama_bot_path <- paste("/addama-rest/primary-repo/path/RobotForms/EPEPT/form_entry");
file_tsv <- paste("'filename=@", inFile, "'", sep="");
#gsfile <- paste("'gsfile=@", gsFile, "'", sep="");

myURI = "";
runningStatus = "running";
iter = 1;

epept_makerequest <- function (file_tsv, params, host, addama) {
   curlPostCommand <- paste("curl -X POST -F ", file_tsv, " -F 'JSON=", epept_params,"' ", host, addama_bot_path,sep="");
   print(curlPostCommand);
   charVectorPostFormEntry <- try(system(curlPostCommand, intern=TRUE));
   print(charVectorPostFormEntry);   
   curlPostJson <- fromJSON(charVectorPostFormEntry);
   postedUri <- curlPostJson$uri;
   postUriMsg <- paste('Curl Posted and return this uri:',postedUri);
   return(postedUri);
}

epept_checkstatus <- function (host, uri) {
   curlGetCommand <- paste("curl -X GET ", host, uri, "/status", sep="");
   curlGetStatus <- try(system(curlGetCommand, intern=TRUE));
   curlGetStatusJson <- fromJSON(curlGetStatus);
   curlGetStatusChildren <- curlGetStatusJson$children;
   len <- length(curlGetStatusChildren);
   status = 'running';
   for(i in 1:len){
      child <- curlGetStatusChildren[[i]];
      out <- paste(child$name, child$uri, sep=" ");
      if (child$name == 'error'){
          status = 'error';
          break;
      }
      if (child$name == 'completed'){
          status = 'completed';
          break;
      }
      print(out);
   }
   return(status);
}

#Process logs/output
epept_getoutput <- function(host, uri, status){
   nodeType <- paste("/outputs");
   if (status == "error"){
      nodeType <- paste("/logs");
   }
   curlGetOutputCommand <- paste("curl -X GET ", host, uri, nodeType, sep="");
   curlGetStatus <- try(system(curlGetOutputCommand, intern=TRUE));
   curlGetStatusJson <- fromJSON(curlGetStatus);
   curlGetStatusChildren <- curlGetStatusJson$children;
   childrenLen <- length(curlGetStatusChildren);
   uri_splitted <- unlist(strsplit(uri, "/"));
   len <- length(uri_splitted);
   form_entry_node <- uri_splitted[len];
   for(i in 1:childrenLen){
      child <- curlGetStatusChildren[[i]];
      #out <- paste(child$name, child$uri, sep=" ");
      curlGetOutputCommand <- paste("curl -X GET ", host, uri, nodeType, "/", child$name, " >> ", pOutput,  "/",form_entry_node, "_", child$name,  sep="");
      print(curlGetOutputCommand);
      curlGetStatus <- try(system(curlGetOutputCommand, intern=TRUE));
   }
   if (status == 'completed'){
      pValueFile <- paste(pOutput, "/", form_entry_node, "_Pvalues_", myOutFile, sep=""); 
      outMsg <- paste("PValue matrix has been saved to ", pValueFile,  sep="");
      print(outMsg);
      #myPVal_Matrix <- matrix(scan("/local/temp/matrix.tsv"), 3, 4, byrow=TRUE)
      pValueReadIn <- read.table(pValueFile, sep="\t");
      pMatrix <- as.matrix(pValueReadIn);
      print(matrix(pMatrix));
      #print(table(pValueReadIn), zero.print = ".");
      return(pValueReadIn);
   }
   logMsg <- paste("Error, check logs at", oOutput, sep=" ");  
   return(logMsg);
}

#Make request
myURI <- epept_makerequest(file_tsv, perm_params, host, addama_bot_path);

while (runningStatus == 'running') {
   runningStatus <- epept_checkstatus(host, myURI);
   statusMsg <- paste("iteration ", iter, runningStatus, sep=" "); 
   if (iter > 20){
      break;
   }
   iter <- iter + 1; 
   Sys.sleep(4);
}

EPEPT_Out <- epept_getoutput(host, myURI, runningStatus);
EPEPT_Out;

