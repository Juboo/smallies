#!/usr/bin/perl
use POE;
use POE::Component::IRC;
use WWW::BashOrg;

sub CHANNEL () { "#eh" }

my $irc = POE::Component::IRC->spawn;

POE::Session->create(
        inline_states => {
                _start => \&bot_start,
                irc_001 => \&on_connect,
                irc_public => \&on_public,
        },
);

sub bot_start {
        $irc->yield(register => "all");
        $irc->yield(
                connect => {
                        Username => 'Bub',
                        Ircname => 'POE::Component::IRC',
                        Server => 'irc.rizon.sexy',
                        Port => 6667,
                        debug => 0,
                        Nick => 'wubbot',
                }
        );
}

sub on_connect {
        $irc->yield(nickserv => "IDENTIFY wubbotlovesyou"); # Don't steal password please
        $irc->yield(join => CHANNEL);
}

sub on_public {
        my($kernel, $who, $where, $msg) = @_[KERNEL, ARG0, ARG1, ARG2];
        my $nick = (split /!/, $who)[0];
        my $channel = $where->[0];
        if($msg =~ /^.thing/) {
                my $fortune = `fortune -a`;
                my @resp = split("\n", $fortune);
                for(my $i = 0; $i < scalar(@resp); $i++) {
                        $irc->yield(privmsg => $channel, $resp[$i]);
                }
        }
        elsif($msg =~ /^.bash/) {
                my $b = WWW::BashOrg->new;
                my $q = $b->random;
                my @quote = split("\n", $q);
                for(my $i = 0; $i < scalar(@quote); $i++) {
                        $irc->yield(privmsg => $channel, $quote[$i]);
                }
        }
        elsif($msg =~ /wubbot/) {
                my $query = $msg =~ /(.*)$/;
                my $resp = `ruby /home/tanner/documents/rb/clever.rb $query`;
                $irc->yield(privmsg => $channel, "$nick, $resp");
        }
        elsif(lc($msg) =~ /eh/ && $channel =~ /eh/) {
                $irc->yield(privmsg => $channel, "Eh!");
        }
}

$poe_kernel->run();
exit 0;
