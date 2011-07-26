require LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Headers;
use JSON;
use Data::Dumper;
use strict;
#initialize programmatic variables
#my ($matrixFile, $host, $outputPath) = @ARGV;
#permutation parameters
my $matrixFile = "/local/EPEPT/yeast.tsv";
my $host = "http://informatics.systemsbiology.net";
my $outputPath = "/local/EPEPT/out";
my $params = "{method:'PWM',ci_chk:'true',ci:'49',oopt_chk:'false',cc_chk:'false',mail_address:'jlin212\@gmail.com'}";

my $json = new JSON;
my $obj;
my $url;
my $ADDAMA_BOT_PATH = '/addama-rest/primary-repo/path/RobotForms/EPEPT/form_entry';
my $status = 'PENDING';
my $formUri = "";
my $json = new JSON;
my $obj;
my $form_entry_name = "";
#http objects and settings
my $ua = LWP::UserAgent->new;
$ua->timeout(1000);
$ua->env_proxy;
sub usage() {
    print "Usage: perl get.pl <uri>";
}

die usage() unless $host;

epept_makerequest();
my $iteration = 0;
while ($status eq 'RUNNING'){
   my $permStatus = epept_checkstatus();
   if (!$permStatus){
      print("\nRetrieving EPEPT results for job status: $status");
      epept_getoutput($status);
      last;
   }else{
      $iteration++;
      sleep(3); 
   }
   if ($iteration > 10){
      print("\nProgram terminating after $iteration iterations: status is: $status");
      last;
   }
}

sub epept_makerequest() {
   $url = $host . $ADDAMA_BOT_PATH . "?JSON=" . $params;
   #{method:" . $method . ",ci_chk:" . $ci_chk . ",ci:" . $ci . ",oopt_chk:" . $oopt_chk . ",cc_chk:" . $cc_chk . "}";
   if($url) {
      my $response = $ua->post($url, Content_Type => 'form-data', Content => [filename => [$matrixFile]]);
      if ($response->is_success) {
        my $responseJson = $response->content;  # or whatever
        $obj = $json->decode($responseJson);
        $form_entry_name = $obj->{'name'};
        $formUri = $obj->{'uri'};
        print("\nPermutation request succeeded, name is $form_entry_name \n" );
        $status = 'RUNNING';
      }else {
        die $response->status_line;
    }
  }
}

sub epept_checkstatus(){
   print ("\ncheck status on $formUri\n");
   my $statusUrl = $host . $formUri . "/status";
   my $statusResponse = $ua->get($statusUrl);
   my $statusObj = $json->decode($statusResponse->content);
   foreach my $cha(@{$statusObj->{children}}){
      my $name = $cha->{name};
      print("\nname of children $name\n");
     if ($name eq 'completed'){
        $status = 'COMPLETED';
        return 0;
     }elsif ($name eq 'error'){
        $status = 'ERROR';
        return 0;
     }
  }
   return 1;
}

sub epept_getoutput(){
   my $outputStatus = $_[0];
   my $outputType = "logs";
   if ($status eq 'COMPLETED'){
      $outputType = "outputs";
   }
   my $outputUrl = $host . $formUri . "/" . $outputType;
   my $outputResponse = $ua->get($outputUrl);
   my $outputObj = $json->decode($outputResponse->content);
   foreach my $cha(@{$outputObj->{children}}){
      my $outFileName = $cha->{name};
      my $outUri = $cha->{uri};
      my $outFileUrl = $host . $outUri;
      #$formUri . "/" . $outputType, "/" . $outFileName;
      #print "\n$outUri\nURI to get $outFileUrl\n";
      my $outFileResponse = $ua->get($outFileUrl);
      my $myContent = $outFileResponse->content;
      my $fileOut = $outputPath . "/" . $form_entry_name . "_" . $outFileName;
      print("\nRetrieving $outUri to $fileOut\n"); 
      open FILE, ">$fileOut" or die $!;
      print FILE $myContent;
      close FILE;
      print "File $fileOut saved and closed\n";
   }
   print ("\nProcessed $outputType outputs for $form_entry_name\n");   
}
