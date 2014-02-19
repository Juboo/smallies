#!/usr/bin/perl

# This won't work in windows until I replace all the system() functions with actual perl

use strict;
use warnings;
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Request::Common;
use Net::SMTP; # Handles the emailing
use Tie::File; # Converts files into arrays for easy line replacement
use Time::Piece; # For getting the date

# We need the date to construct the proper URL for an up-to-date IDS report
my @date;
$date[0] = Time::Piece->new->strftime('%Y');
$date[1] = Time::Piece->new->strftime('%m');
$date[2] = Time::Piece->new->strftime('%d') - 1; # Who the hell doesn't start counting from 0?
$date[3] = Time::Piece->new->strftime('%H');

my $pl = "/home/tanner/projects/pl"; # I don't want to type this over and over
my $py = "/home/tanner/projects/py";

my $url = "https://*.*.*.*/base/base_stat_alerts.php?time_cnt=1&time%5B0%5D%5B0%5D=+&time%5B0%5D%5B1%5D=%3E%3D&time%5B0%5D%5B2%5D=$date[1]&time%5B0%5D%5B3%5D=$date[2]&time%5B0%5D%5B4%5D=$date[0]&time%5B0%5D%5B5%5D=$date[3]&time%5B0%5D%5B6%5D=&time%5B0%5D%5B7%5D=&time%5B0%5D%5B8%5D=+&time%5B0%5D%5B9%5D=+";

print "Downloading YMCA IDS unique 24 hour report...\n";
# You may have to use curl -L or a perl-pure alternative to wget. The problem is that it requires authentication, and I've only done authentication like this in wget.
#system("wget", "-q", "--output-document=$pl/page.tmp", "--http-user=administrator", "--http-password=*****", "--no-check-certificate", $url);
sub download(SITE) {
	my $req = GET SITE;
	$req->authorization_basic('administrator','*****');
	my $res = $ua->request($req);
	unless($res->is_success) {
		print $res
}


print "Stripping unecessary lines...\n";
tie(my @file, 'Tie::File', "$pl/page.tmp");
splice(@file, -57, 55);
splice(@file, 37, 1); 
splice(@file, 8, 8); 

print "Adding logo...\n";
$file[6] = '        <BODY><div class="mainheadertitle"><center><img src=/home/tanner/projects/pl/mht/imagething.png></center></div>';
$file[28] = ' ';

# In firefox (if you have the UnMHT addon) you can open this, but in IE you cannot.
print "Converting HTML to MHT...\n";
untie(@file);
system("mv", "page.tmp", "$pl/mht/index.html");
$date[2] += 1;

system("$py/mht.py", "-p", "$date[0]$date[1]$date[2]_YMCA_IDS.mht", "$pl/mht/");

my $file = "$date[0]$date[1]$date[2]_YMCA_IDS.mht";
my $server = 'mail.*****.com';
my $from = 'yomomma@*****.com';
my $to = 'you@*****.com';
my $boundary = 'frontier';

open(DATA, $file);
	my @attach = <DATA>;
close(DATA);


my $mail = Net::SMTP->new($server, Timeout => 30);
$mail->mail($from);
$mail->recipient($to);
$mail->data();
$mail->datasend("To: $to\n");
$mail->datasend("From: $from\n");
$mail->datasend("Subject: IDS\n");
$mail->datasend("MIME-Type: 1.0\n");
$mail->datasend("Content-Type: multipart/mixed; \n\tboundary=\"$boundary\"\n\n");
$mail->datasend("--$boundary\n");
$mail->datasend("Content-Type: text/html \n");
$mail->datasend("Content-Disposition: quoted/printable\n\n");
$mail->datasend("<b>Hello World!</b>\n\n");
$mail->datasend("--$boundary\n");
$mail->datasend("Content-Type: application/text; name=\"$file\"\n");
$mail->datasend("Content-Disposition: attachment; filename=\"$file\"\n\n");
$mail->datasend("@attach");
$mail->datasend("--$boundary\n");
$mail->dataend();
$mail->quit();
