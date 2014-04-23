use strict;
use warnings;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request;

#-------------------------------------------------------------------------------
#Simulating url function from input file
#Reading test urls from URLs.txt line by line
#-------------------------------------------------------------------------------
my $inputUrlFile = "D://WD//URLs.txt";
open(MYINPUTFILE, "<$inputUrlFile");
my(@urlLines) = <MYINPUTFILE>;
close(MYINPUTFILE);

#-------------------------------------------------------------------------------
#Main function
#Testing each url for
#   RFC-2396 standard
#   webpage context
#   protocal header
#-------------------------------------------------------------------------------
foreach my $urlLine (@urlLines)
 {
  next if ($urlLine =~/^\#.*/i);
  print "START--------------------------------------------------------------\n";
  print "TestingURL: $urlLine\n";
  
  #Testing url according to RFC-2396 standard
  testRFC239($urlLine);
  
  #Testing url web page
  testUrlPage($urlLine);
  
  #Testing url header
  testUrlHeader($urlLine);
  
  print "--------------------------------------------------------------END\n\n";
 }

#-------------------------------------------------------------------------------
#Testing according to RFC-2396 standard
# reference to RFC-2396 ---> http://www.ietf.org/rfc/rfc2396.txt
#Checking test url for
#   scheme      --> (protocal)
#   authority   --> (Server)
#   port        --> (port)
#   domain      --> (web domain)
#   path        --> (recursive path)
#   query       --> (parameter)
#   fragmen     --> (#string)
#-------------------------------------------------------------------------------
sub testRFC239
{
 my $testUri = shift @_;
 my($scheme,$authority,$path,$query,$fragmen) = "";
 
 if ($testUri =~ m!^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?!)
  {
    ($scheme,$authority,$path,$query,$fragmen) = ($2,$4,$5,$7,$9);
    print "\t-----------------------------------\n";
    print "\tRFC239 testing:\n";
    print "\tscheme: $scheme\n" if defined $scheme;
    if (defined $authority)
    {
     print "\tauthority: $authority\n";
     my @authoritys = split(':', $authority);
     print "\tport: $authoritys[1]\n" if defined $authoritys[1];
     testDomain($authoritys[0]);
    }
    print "\tpath: $path\n" if defined $path;
    print "\tquery: $query\n" if defined $query;
    print "\tfragmen: $fragmen\n" if defined $fragmen;
    print "\t-----------------------------------\n";
   }
}

sub testDomain
{
  my $testUrlDomain = shift @_;
  
  if ($testUrlDomain =~ /.*\.(\w{2,4}$)/)
  {
    print "\tdomain: $1\n";
  }
}

#-------------------------------------------------------------------------------
#Testing test url content
#Checking info like
#    content type
#    doc length
#    mod time
#    expires
#    server
#-------------------------------------------------------------------------------
sub testUrlPage
{
 my $testUri = shift @_;
 my ($content_type, $doc_length, $mod_time, $expires, $server);

    if (($content_type, $doc_length, $mod_time, $expires, $server) = head($testUri))
    {
        print "\tPage testing:\n";
        print "\tcontent_type: $content_type\n" if defined $content_type;
        print "\tdoc_length: $doc_length\n" if defined $doc_length;
        
       if ($mod_time)
       {
         my $ago = time( ) - $mod_time;
         print "\tIt was modified $ago seconds ago; that's about ", int(.5 + $ago / (24 * 60 * 60)), " days ago, at ", scalar(localtime($mod_time)), "!\n";
       }
       else
       {
        print "\tlast modified was not known.\n";
       }               
        print "\texpires: $expires\n" if defined $expires;
        print "\tserver: $server\n" if defined $server;
    }
    else
    {
        print "No Page\n";
    }
}

#-------------------------------------------------------------------------------
#Testing Http headers
#request and response messages
#Load cross verification for web page
#-------------------------------------------------------------------------------
sub testUrlHeader
{
 my $testUri = shift @_;

 my $urlAgent = LWP::UserAgent->new(env_proxy => 1,keep_alive => 1, timeout => 30);
 my $urlHeader = HTTP::Request->new(GET => $testUri);
 my $urlRequest = HTTP::Request->new('GET', $testUri, $urlHeader);
 my $urlResponse = $urlAgent->request($urlRequest);
 
 print "-----------------------------------\n";
 
 print "\tRequest header:\n";
 print $urlRequest->headers_as_string."\n";
 
 if ($urlResponse->is_success)
 {  
  print "\tResponse header:\n";  
  print $urlResponse->headers_as_string."\n";
  
  print "\tHeader content:\n";
  print $urlResponse->as_string."\n";
 }
 
 if ($urlResponse->is_error)
 {
  print "\tError:\n";
  print $urlResponse->error_as_HTML."\n";
 }
print "-----------------------------------\n"; 
}
