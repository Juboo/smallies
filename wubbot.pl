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
	$irc->yield(nickserv => "IDENTIFY ****");
	$irc->yield(join => CHANNEL);
}

sub on_public {
	my($kernel, $who, $where, $msg) = @_[KERNEL, ARG0, ARG1, ARG2];
	my $nick = (split /!/, $who)[0];
	my $channel = $where->[0];
	if($msg =~ /^.fortune/) {
		my $fortune = `fortune /usr/share/games/fortune/fortunes`;
		$fortune =~ s/\R/ /g;
		$irc->yield(privmsg => $channel, "$nick, $fortune");
	}
	elsif($msg =~ /^.bash/) {
		my $b = WWW::BashOrg->new;
		my $q = $b->random;
		my @quote = split("\n", $q);
		for(my $i = 0; $i < scalar(@quote); $i++) {
			$irc->yield(privmsg => $channel, $quote[$i]);
		}
	}
	elsif($msg =~ /love/) {
		my $fortune = `fortune /usr/share/games/fortune/love`;
		$fortune =~ s/\R/ /g;
		$irc->yield(privmsg => $channel, $fortune);
	}
}

$poe_kernel->run();
exit 0;
