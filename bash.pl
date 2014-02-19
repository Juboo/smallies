#!/usr/bin/perl

use strict;
use warnings;
use LWP::Simple;

my $url = 'http://www.bash.org/?random'; # A bunch of random quotes
my $content = get $url; # $content is now a string containing the html
die("Couldn't get URL!") unless(defined $content);

# Icky regexp. Captures the first encoutered single-lined quote!
my($link, $score, $quote) = $content =~ /<p class="quote"><a href="\?(\d+)".+(\(\d+\)).+<p class="qt">(.+|\S*)<\/p>/;
$link = "http://www.bash.org/?".$link; # URL for the quote
$quote =~ s/&lt;/</; # Instead of &lt;Wub&gt;
$quote =~ s/&gt;/>/; # it's now <Wub>
print "$score  $link  $quote";
