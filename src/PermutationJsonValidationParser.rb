require 'rubygems'
require 'json' # sudo gem install json
require 'roo' #for xls convertion

class PermutationJsonValidationParser

def initialize()
  @HOST = 'http://cornea.systemsbiology.net:9080'
  @metaJsonInput = ''
  @annotationsPermHash = Hash.new
  @annotationsWarningHash = Hash.new
  @xlsInFile = ''
  @xlsOutFile = ''
end

def is_a_number?(s)
 #ignore + and -  s.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  s.to_s.match(/^[\d]+(\.[\d]+){0,1}$/) == nil ? false : true
end

def convertXsl()
   begin
    @xlsOutFile = @xlsInFile.sub('.xls', '_xls_.csv');
    if (@xlsInFile.index('xlsx') == nil) then
       s = Excel.new(@xlsInFile)           # creates an Excel Spreadsheet instance
       s.to_csv(@xlsOutFile);
    else
       @xlsOutFile = @xlsInFile.sub('.xlsx', '_xlsx_.csv');
       x = Excelx.new(@xlsInFile)           # creates an Excel x Spreadsheet instance
       x.to_csv(@xlsOutFile);
       #@annotationsPermHash["file"] = @xlsOutFile;
    end
   rescue Exception => e
      puts "Error at convertXsl " + e.message
   end
end


def generateCustom
   annotationsJson = @annotationsPermHash.to_json;
   customJsonFile = File.open("./inputs/perm.json", "w")
   customJsonFile.write(annotationsJson);
   customJsonFile.close
end

#Might be nice to have a .property file that defines the custom inputs for app, with default values
#then this program can read this input file...
def validate_input()
#open up inputs.json
   IO.foreach("./inputs/inputs.json"){ |line|
      #puts line;
      #right now all the json inputs comes in one line
      @metaJsonInput = @metaJsonInput + line;
   }
   jsonObj = JSON.parse(@metaJsonInput)
   @annotationsPermHash["uri"] = jsonObj["uri"];

   mail_address = jsonObj["mail_address"];
   @annotationsPermHash["mail_address"] = mail_address;
   if (mail_address == nil)then
      @annotationsPermHash["mail_address"] = 'jlin@systemsbiology.org';
   end

   #if file does not exist, create error message and logged and return
   filename = jsonObj["filename"];
   @annotationsPermHash["file"] = filename;
   #if file is not defined, then create error message and logged, exit program
   if (filename == nil) then
      puts "filename is null, set error to error log and exit program"
      errorLogFile = File.open("./logs/validation_error.log", "w")
      errorLogFile.write("Fatal error: Input Filename does not exist, program exiting(-1)")
      errorLogFile.close
      exit(-1)
   end
   method = jsonObj["method"];
   findex = filename.index(".xls")
   if (findex != nil && findex > 1) then
      @annotationsWarningHash["xls_warning"] = "Converting xls to csv";
      @xlsInFile = "./inputs/" + filename;
      convertXsl();
      csv_filename = filename.sub('.xls', '_xls_.csv'); 
      if (filename.index('xlsx') != nil) then
         #puts "xls file" + ARGV[0]
         csv_filename = filename.sub('.xlsx', '_xlsx_.csv'); # "Array[0] + '.csv';
      end
      @annotationsPermHash["file"] = csv_filename;
   end
   #puts method;
   @annotationsPermHash["method"] = method;
   #if method is not defined or not one of the possible options, then go with PWM
   if ( (method == nil) || ( (method.downcase != 'ml') && (method.downcase != 'pwm') && (method.downcase != 'mom') ) )  then
      #puts "method is null, set default"
      @annotationsPermHash["method"] = 'PWM';
      @annotationsWarningHash["method_warning"] = "No (existing) method to estimate GPD parameters is selected, default set to PWM";
   end

   mode = jsonObj["mode"];
   @annotationsPermHash["mode"] = mode;
   #if method is not defined or not one of the possible options, then go with PWM
   if ( (mode == nil) || ( (mode.downcase != 'pv') && (mode.downcase != 'sam') && (mode.downcase != 'gsea') ) )  then
      mode = 'PV';
      @annotationsPermHash["mode"] = 'PV';
      @annotationsWarningHash["mode_warning"] = "Empty or invalid mode value found, default set to PV";
   end
   
   if (mode.downcase == 'gsea' || mode.downcase == 'sam') then
       resptype = jsonObj["resptype"];
       @annotationsPermHash["resptype"] = resptype;
       if ( (resptype == nil) || ( (resptype.downcase != 'quantitative') && (resptype.downcase != 'two class unpaired') && (resptype.downcase != 'survival') && (resptype.downcase != 'multiclass') && (resptype.downcase != 'two class paired') ) )  then
  	    @annotationsPermHash["resptype"] = 'Two class unpaired';
      	    @annotationsWarningHash["resp_warning"] = "Empty or invalid resptype value found, default set to Two class unpaired";
  	 end

       nperms = jsonObj["nperms"];
       @annotationsPermHash["nperms"] = nperms;
       if (nperms == nil || (is_a_number?(nperms) == false ))then
       		@annotationsPermHash["nperms"] = '1000';
      		@annotationsWarningHash["nperms_warning"] = "NPerms variable does not exist or value is not one of the possible values, default set to 1000";
       end
       if (mode.downcase == 'gsea') then
       		gsa_method = jsonObj["gsa_method"];
   		@annotationsPermHash["gsa_method"] = gsa_method;
   		if ( (gsa_method == nil) || ( (gsa_method.downcase != 'maxmean') && (gsa_method.downcase != 'mean') && (gsa_method.downcase != 'absmean') ) )  then
      			@annotationsPermHash["gsa_method"] = 'maxmean';
      		@annotationsWarningHash["gsa_method_warning"] = "Invalid gsa_method value found, default set to maxmean";
   		end
		gsfile = jsonObj["gsfile"];
   		@annotationsPermHash["gsfile"] = gsfile;
  		if (gsfile == nil) then
      			puts "GS filename is null, set error to error log and exit program"
      			errorLogFile = File.open("./logs/validation_error.log", "w")
      			errorLogFile.write("Fatal error: GSEA Mode, gene set file does not exist, program exiting(-1)")
      			errorLogFile.close
      			exit(-1)
   		end
       end
   end
       rseed = jsonObj["rseed"];
       @annotationsPermHash["rseed"] = rseed;
       if (rseed == nil || (is_a_number?(rseed) == false ))then
                @annotationsPermHash["rseed"] = '0';
                @annotationsWarningHash["rseed_warning"] = "Empty or random seed variable does not exist or value is not one of the possible values, default set to 0";
       end

	   
   cc_chk = jsonObj["cc_chk"];
   @annotationsPermHash["cc_chk"] = cc_chk;
   if (cc_chk == nil) then
     @annotationsPermHash["cc_chk"] = 'false';
     cc_chk = 'false';
   else
      if ((cc_chk.downcase != 'true') && (cc_chk.downcase != 'false') && (cc_chk.downcase != 'on'))then
         @annotationsPermHash["cc_chk"] = 'false';
         cc_chk = 'false';
         @annotationsWarningHash["cc_chk_warning"] = "Convergence criterium variable does not exist or value is not one of the possible values, default set to false";
      end
   end

  if (cc_chk.downcase == 'on') then
      @annotationsPermHash["cc_chk"] = 'true';
  end

   ci_chk = jsonObj["ci_chk"];
   @annotationsPermHash["ci_chk"] = ci_chk;
   if (ci_chk == nil) then
     @annotationsPermHash["ci_chk"] = 'true';
     ci_chk = 'true';
    else
       if ((ci_chk.downcase != 'true') && (ci_chk.downcase != 'false') && (ci_chk.downcase != 'on')) then
            @annotationsPermHash["ci_chk"] = 'true';
            ci_chk = 'true';
            @annotationsWarningHash["ci_chk_warning"] = "Confidence interval computation variable does not exist or value is not one of the possible values, dfault set to true";
       end
  end
  
  if (ci_chk.downcase == 'on') then
      @annotationsPermHash["ci_chk"] = 'true';
  end

 civ = jsonObj["ci"];
   @annotationsPermHash["ci"] = civ;
   if (civ == nil || (is_a_number?(civ) == false ))then
      @annotationsPermHash["ci"] = '95';
      @annotationsWarningHash["ci_warning"] = "Confidence interval variable does not exist or value is not one of the possible values, default set to 95";
   end
   if (is_a_number?(civ) == true) then
      if (civ.to_i < 1 || civ.to_i > 99) then
         @annotationsPermHash["ci"] = '95';      @annotationsWarningHash["ci_warning"] = "Confidence interval variable does not exist or value is not one of the possible values,
 default set to 95";
      end
   end

   oopt_chk = jsonObj["oopt_chk"];
   @annotationsPermHash["oopt_chk"] = oopt_chk;
   if (oopt_chk == nil) then
      oopt_chk = 'false';
      @annotationsPermHash["oopt_chk"] = 'false';
   else
      if ((oopt_chk.downcase != 'true') && (oopt_chk.downcase != 'false') && (oopt_chk.downcase != 'on'))then
      	oopt_chk = 'false';
      	@annotationsPermHash["oopt_chk"] = 'false';
      	@annotationsWarningHash["oopt_chk_warning"] = "Optimal order preserving transform variable does not exist or value is not one of the possible values, default set to false";
      end
   end

  if (oopt_chk.downcase == 'on') then
      @annotationsPermHash["oopt_chk"] = 'true';
  end


   warningLogFile = File.open("./logs/validation_warning.log", "w")
   @annotationsWarningHash.each { |key, value| warningLogFile.write(key + ' = ' + value + "\n") }
   warningLogFile.close
   generateCustom()
  end

end

execute = PermutationJsonValidationParser.new
execute.validate_input
exit
                                                           
