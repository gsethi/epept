require 'rubygems'
require 'httpclient' # sudo gem install httpclient
require 'json' # sudo gem install json

class EPEPT_AddamaWSClient

#Initialize host and parameters
def initialize()
  #puts "arg 1" + ARGV[0]
  #@argv_array
  @argv_array = Array.new;
  @argv_array << "/local/EPEPT/yeastdata.tsv";
  @argv_array << "http://informatics.systemsbiology.net";
  @argv_array << "./out";
  @argv_array << "{mode:'GSEA',method:'PWM',gsa_method:'maxmean',nperms:'1000',resptype:'Quantitative',mail_address:'jlin212@gmail.com',ci_chk:'true',ci:'50',oopt_chk:'false',cc_chk:'false'}"
  @argv_array << "/local/EPEPT/geneset.gmt";
  puts "EPEPT arguments " + @argv_array[0] + @argv_array[1] +  @argv_array[2] + @argv_array[3] + @argv_array[4];
  @clnt = HTTPClient.new
  @HOST = @argv_array[1]; #'http://cornea.systemsbiology.net:9080'
  @ADDAMA_BOT_PATH = '/addama-rest/primary-repo/path/RobotForms/EPEPT/form_entry'
  @status = 'pending'
  @outNode = 'outputs'
  @outpath = @argv_array[2]
  @params = @argv_array[3]; #"{method:'PWM',ci_chk:'true',ci:'50',oopt_chk:'false',cc_chk:'false'}"
  @file_tsv = @argv_array[0]; #'./mymatrix.tsv'
  @file_gsea = @argv_array[4]; #'./my.gmt'
  @formName = ""
  rescue Exception:
    puts "Initialize Function failed, please check your input arguments!" 
end

#Checks status after making request
def epept_checkstatus?(uri)
   getResp = @clnt.get(@HOST + uri + '/status');
   #puts getResp.content
   jsonResp = JSON.parse(getResp.content);
   jsonChild = jsonResp['children']
   jsonChild.each() do |jc|
      cnode_name = jc['name']
      if (cnode_name == 'error') then
         @status = 'error';
         @outNode = 'logs';
         puts 'Errors -> Program exited with errors: see the log files that are being saved to your execution path'
         return false;
      elsif (cnode_name == 'completed') then
         @status = 'completed';
         puts 'Job Completed -> The output files (plot.png and Pvalues_mymatrix.tsv) are saved are saved to your execution path'
         return false;
      end
   end
   return true;
end

#Processes output after job completes
def epept_getoutput(uri, nodeType)
  puts @HOST + uri + '/' + nodeType;
  resp = @clnt.get(@HOST + uri + '/' + nodeType);
  jsonResp = JSON.parse(resp.content);
  jsonChild = jsonResp['children'];
  jsonChild.each() do |child|
   puts 'saving:' + child['name']
   fileResp = @clnt.get(@HOST + uri + '/' + nodeType + '/' + child['name']);
   open(@outpath +"/"+ @formName + "_" + child['name'], "wb") { |file|
    file.write(fileResp.content)
   }
  end
end

#Posts request
def epept_makerequest()
   file = File.open(@file_tsv)
   gsfile = File.open(@file_gsea)

#   body = { 'upload' => file, 'filename' => 'mymatrix.tsv', 'method' => 'PWM', 'lower_bound' => '95', 'upper_bound' => '5', 'ci' => 'true', 'oopt' => 'false' }
   body = { 'filename' => file, 'gsfile' => gsfile, 'JSON' => @params }
 
   res = @clnt.post(@HOST + @ADDAMA_BOT_PATH, body)
   jsonInst = JSON.parse(res.content)
   puts 'uri=>' + jsonInst['uri']
   @formName = jsonInst['name']
   iter = 0
   while (epept_checkstatus?(jsonInst['uri']) && (iter <= 20)) do
      puts 'still running, sleep 3 seconds -> poll at most 20 times'
      sleep 4
      iter = iter + 1;
   end   
      puts 'Done running, job status ->' + @status + '-> processingOutput'
      epept_getoutput(jsonInst['uri'], @outNode)      
  end
 #end
end

#Invokes program
epeptWS = EPEPT_AddamaWSClient.new
epeptWS.epept_makerequest()
