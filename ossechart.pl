#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use Date::Calc qw(Add_Delta_Days Delta_Days);
use URI::GoogleChart;
use autodie;
no autodie;

my $q = CGI->new;
my @mon = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my($alerts, $lineurl, $pieurl, $startlvl, $endlvl, %piestuff, @linestuff, @date, @startd, @finald);

# if (defined $q->param('live')) {
#     @date = (localtime)[5,4,3];
#     $date[0] += 1900;
#     open(FILE, "<", "/var/ossec/stats/totals/$date[0]/$mon[$date[1]]/ossec-totals-$date[2].log") || die "Yo nigga, you fuckin wit me?!! $!";
#     @value = <FILE>;
#     close(FILE);
# }

@date = split('-', $q->param('start'));
@startd = split('-', $q->param('start'));
@finald = split('-', $q->param('final'));
#my $x = 0;
unless (defined $q->param('start')) {
    @date = split('-', "2013-01-31");
    @startd = split('-', "2013-01-31");
    @finald = split('-', "2013-03-01");
}
while ("$startd[0]$startd[1]$startd[2]" <= "$finald[0]$finald[1]$finald[2]") {
    open(FILE, "<", "/var/ossec/stats/totals/$startd[0]/$mon[$startd[1] - 1]/ossec-totals-$startd[2].log");
    ($startd[0],$startd[1],$startd[2]) = Add_Delta_Days($startd[0],$startd[1],$startd[2], 1);
    $startd[2] = qq{0$startd[2]} if ($startd[2] < 10);
    $startd[1] = qq{0$startd[1]} if ($startd[1] < 10);
    foreach my $line (<FILE>) {
	if ($line =~ m/Hour/) {
	    $line =~ m/(\d+)[:](\d+)$/;
	    push(@linestuff, $2);
	}
	elsif ($line =~ m/(\d+)-(\d+)-(\d+)-(\d+)/) {
	    my($hour, $ruleid, $level, $quantity) = $line =~ m/(\d+)*-(\d+)*-(\d+)*-(\d+)/;
	    $piestuff{$level} .= "$ruleid," if (defined $quantity && $piestuff{$level} !~ m/$ruleid/);
	    $piestuff{$ruleid} += $quantity if (defined $quantity);
	}
    }
    close(FILE);
}
&line_charty(@linestuff);
&pie_charty(\%piestuff);
&ticker;
&html;

sub pie_charty {
    my $data = shift;
    @startd = @date;
    $startlvl = $q->param('level1');
    $endlvl = $q->param('level2');
    unless (defined $q->param('level1')) {
	$startlvl = 9;
	$endlvl = 10;
    }
    my @rules = ();
    for (my $x = $startlvl; $x <= $endlvl; $x++) {
	push(@rules, split(',', $data->{$x}));
    }
    my $rulie = "";
    foreach my $x (@rules) {
    	open(FILE, "zcat -c /var/ossec/logs/alerts/$startd[0]/$mon[$startd[1] - 1]/ossec-alerts-$startd[2].log.gz |");
    	($startd[0],$startd[1],$startd[2]) = Add_Delta_Days($startd[0],$startd[1],$startd[2], 1);
    	$startd[2] = qq{0$startd[2]} if ($startd[2] < 10);
    	$startd[1] = qq{0$startd[1]} if ($startd[1] < 10);
    	foreach my $line (<FILE>) {
    	    if ($line =~ m/Rule: /) {
		$line =~ m/-> '(.+)'/;
		unless (index($rulie, $1) != -1) {
		    $rulie .= "$1|";
		}
    	    }
    	}
	close(FILE);
    }
    chop($rulie);
    my $sum = 0;
    my @nums = ();
    foreach my $i (@rules) {
	$sum += $data->{$i};
	push(@nums, $data->{$i});
    }
    foreach my $y (@nums) {
	my $x = 0;
	$nums[$x] = ($y / $sum)*100;
    }
    $pieurl = URI::GoogleChart->new("pie", 600, 150,
				    data => [@nums],
				    chxl => "0:|$rulie",
				    chxt => "x",
				    background => "transparent",
				    rotate => 0,
				    margin => [200,200,0,0],
	);
}

sub line_charty {
    my @data = @_;
    my @xl = ($date[0],$date[1],$date[2]);
    my $dd = Delta_Days($date[0],$date[1],$date[2], $finald[0],$finald[1],$finald[2]);
    if ($dd < 0) {
	print "Content-Type: text/html \n\n<html><head><title>Error!</title></head><body><h1>The starting date is greater than the final date!</h1></body></html>";
	exit(0);
    }
    elsif ($dd < 25) {
    	for (my $i = 1; $i <= $dd; $i++) {
    	    ($xl[0], $xl[1], $xl[2 + $i]) = Add_Delta_Days($xl[0], $xl[1], $xl[1 + $i], 1);
    	}
    }
    elsif ($dd < 50) {
    	for (my $i = 1; $i <= $dd/2; $i++) {
    	    ($xl[0], $xl[1], $xl[2 + $i]) = Add_Delta_Days($xl[0], $xl[1], $xl[1 + $i], 2);
    	}
    }
    elsif ($dd < 75) {
    	for (my $i = 1; $i <= $dd/4; $i++) {
    	    ($xl[0], $xl[1], $xl[2 + $i]) = Add_Delta_Days($xl[0], $xl[1], $xl[1 + $i], 4);
    	}
    }
    my $xl = join("|", @xl[2..$#xl]);
    my $rainyday = $xl[-1]+1;
    $lineurl = URI::GoogleChart->new("lines", 500, 150,
				     data => [@data],
				     range_show => "left",
				     range_round => 1,
				     chxl => "0:|$xl|$rainyday",
				     chxt => "x",
				     color => "red",
				     background => "transparent",
	);
}

sub ticker {
    open(FILE, "<", "/var/ossec/logs/alerts/alerts.log");
    my @value = <FILE>;
    close(FILE);
    $alerts = "";
    foreach my $line (@value) {
	if ($line =~ m/^Rule: \d+/) {
	    $alerts .= "$line " unless (index($alerts, $line) != -1);
	}
    }
}

sub html {
print "Content-Type: text/html \n\n";
print <<ENDHTML;
<html>
<head>
<title>Alert Data</title>
<link rel="stylesheet" type="text/css" href="/mystyle.css">
<marquee>$alerts</marquee>
</head>
<hr />
<body>
<h3><u>$date[1]/$date[2]/$date[0] - $finald[1]/$finald[2]/$finald[0]<i>!</i></u></h3>
<img src="$lineurl" alt="Line Chart">
<img src="$pieurl" alt="Pie Chart">
</body>
</html>
ENDHTML
}
