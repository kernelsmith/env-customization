# cat .irssi/scripts/autoreply.pl
use Irssi;

sub sig_message_public {
  my ($server, $msg, $nick, $nick_addr, $channel) = @_;
  if ($channel =~ /(?:#ar|#aha)/) {
    #Irssi::print("Public message in $channel from $nick, '$msg'");
    if ($msg =~ /egyp[t7]: p[i!o]+n+g+/i) {
      Irssi::print("Ping in $channel from $nick, '$msg'");
      #$server->command("mode $channel +b *!$nick_addr");
      $server->command("kick $channel $nick pong");
    }
  }
}

Irssi::signal_add('message public', 'sig_message_public');

jimbow [~admin@pool-71-177-95-243.lsanca.fios.verizon.net]