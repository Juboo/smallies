#!/usr/bin/perl

use strict;
use warnings;
#use Data::Dumper;

my @matrix;
my $date = `date +%F`; chomp($date);
my @page = `wget -q -O - --user=7777 --password=**** 'http://192.168.1.5/vicidial/AST_agent_status_detail.php?DB=&query_date=2017-01-11&end_date=2017-01-11&group%5B%5D=****&user_group%5B%5D=--ALL--&shift=ALL&report_display_type=TEXT&SUBMIT=DOWNLOAD'`;
my ( $headeri ) = grep { $page[$_] =~ "USER NAME" } 0..$#page;
my @header = split(/\|/, $page[$headeri]);
my ( $salei ) = grep { $header[$_] =~ "SALE" } 0..$#header;
my ( $addoni ) = grep { $header[$_] =~ "ADDON" } 0..$#header;
my ( $ei ) = grep { $page[$_] =~ "TOTALS" } 88..$#page;

push(@header, "SCORE");
push(@header, "REVENUE");
for (my $i = 0; $i < scalar(@header); $i++) {
        $header[$i] = "<th>$header[$i]</th>";
        $header[$i] = "<tr>$header[$i]" if($i == 0);
        $header[$i] = "$header[$i]</tr>" if($i == scalar(@header) - 1);
}
for(my $i = 89; $i < $ei-1; $i++) {
        my @data = split(/\|/, $page[$i]);
        $data[1] =~ s/^\s+|\s+$//g;
        $data[$addoni] = int($data[$addoni]);
        $data[$salei] = int($data[$salei]);
        push(@data, 2*$data[$addoni] + $data[$salei]);
        push(@data, 2.1*$data[-1]);
        $matrix[$i-89] = \@data;
}

@matrix = sort { $b->[-1] <=> $a->[-1] } @matrix;

print "Content-type: text/html\n\n";
print "<html>";
print "<head><title>woo doggy</title></head>";
print "<body><center><img src=/logo.png><br><br><h2>MVP: $matrix[0][1]</h2><br><br><table>";
for(my $x = 0; $x < scalar(@header); $x++) {
        print $header[$x] if ($x == 1 || $x == 3 || $x == scalar(@header)-2 || $x == scalar(@header)-1);
}
for(my $x = 0; $x < scalar(@matrix); $x++) {
        for(my $y = 0; $y < scalar(@header); $y++) {
                print "<tr>" if ($y == 0);
                print "<td>$matrix[$x][$y]</td>" if($y == 1 || $y == 3 || $y == scalar(@header)-2 || $y == scalar(@header)-1);
                print "</tr>" if ($y == scalar(@header));
        }
}
print "</center></body></html>";
