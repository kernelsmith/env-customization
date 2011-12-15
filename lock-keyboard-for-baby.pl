#!/usr/bin/perl
use warnings;
use strict;
use Data::Dumper;
my $lastmod="2006/05/25";
my $datemod="2008/07/03";
my $defaultpassword="QuitNow";
my $progname=$0;
$progname =~ s%.*/%%g;

sub usage($)
{
  my ($exitcode)=@_;

  print STDERR <<END_OF_USAGE ;
usage for $progname
$progname [-xy=XX,YY]
			  [-p|password thepassword]
			  [-stars|-visible|-visible=maxlen]
			  [-message]
			  [-w|-withmouse]
			  [-help]

$progname was written by:Chris Sincock 
(this version $datemod)
Copyright (C) 2006 Chris Sincock
 '-withmouse' option added 2008 Andrew Oakley under GPL

This is free software; see the GNU GPL license for copying conditions.
There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR
A PARTICULAR PURPOSE


If you specify -password or -stars it will default to not telling you
 what password to type
If you don't specify -password or -stars or -vis, it will tell you
 what password to type and the password will be $defaultpassword

You can clear whatever has already been typed by hitting <Return>
END_OF_USAGE

  exit($exitcode);
}


my $password=$defaultpassword;
my $message="Type the password to quit\n:";
my $true=1;
my $false=0;
my $noshow=$true;
my $withmouse=$false;
my $maxshownlength=30;
my $defaults_changed=$false;
my $defaults_changed_vis=$false;

my @startpos=(0,0);

while (@ARGV)
{
  my $arg=shift @ARGV;
  if($arg =~ /^-xy=(\d+),(\d+)$/i)
  {
    @startpos=($1,$2);
  }
  elsif($arg =~ /^(-|--)(h|help|usage|[?])$/i)
  {
    usage(0);
  }
  elsif($arg =~ /^(-|--)(p|pass|password)$/i)
  {
    if(!@ARGV)
    {
      print STDERR "missing argument\n";
      usage(-1);
    }
    $password=shift @ARGV;
    $defaults_changed=$true;
  }
  elsif($arg =~ /^(-|--)(s|stars)$/i)
  {
    $noshow="stars";
    $defaults_changed=$true;
  }
  elsif($arg =~ /^(-|--)(w|withmouse)$/i)
  {
    $withmouse=$true;
    $defaults_changed=$true;
    $defaults_changed_vis=$true;
  }
  elsif($arg =~ /^(-|--)(v|vis|visible)(=(\d+)|)$/i)
  {
    $noshow=$false;
    if(length($4))
    {
      $maxshownlength=$4;
    }
    $defaults_changed=$true;
    $defaults_changed_vis=$true;
  }
  elsif($arg =~ /^(-|--)(m|msg|message)$/i)
  {
    if(!@ARGV)
    {
      print STDERR "missing argument\n";
      usage(-1);
    }
    $message=shift @ARGV;
    if(length($message))
    {
      $message.="\n";
    }
    $defaults_changed=$true;
  }
  else
  {
    usage(-1);
  }
}
if(!$defaults_changed)
{
  $noshow=$false;
}
if((!$defaults_changed || $defaults_changed_vis))
{
  $message="Type '$password' to quit\n";
}

use Gtk2 -init;
my $w  = new Gtk2::Window -popup;
my $l  = new Gtk2::Label $message;
my $eb = new Gtk2::EventBox;
my $gdkwin;
my $grabstatus;
my $typed="";

sub do_grab()
{
  $grabstatus= Gtk2::Gdk->keyboard_grab(
      $gdkwin,$true,Gtk2::Gdk::X11->get_server_time($gdkwin) );
  if($grabstatus ne "success")
  {
    $l->set_text("keyboard grab failed");
  }
  if($withmouse)
  {
    $grabstatus= Gtk2::Gdk->pointer_grab(
       $gdkwin,$true,['button-press-mask','button-release-mask'],undef,undef,Gtk2::Gdk::X11->get_server_time($gdkwin));
    if($grabstatus ne "success")
    {
      $l->set_text("pointer grab failed");
    }
  }
}

sub do_ungrab()
{
  Gtk2::Gdk->keyboard_ungrab(Gtk2::Gdk::X11->get_server_time($gdkwin));
  if($withmouse)
  {
     Gtk2::Gdk->pointer_ungrab(Gtk2::Gdk::X11->get_server_time($gdkwin));
  }
}

sub do_keypress(@)
{
  my ($widg,$evt)=@_;
  my $kv = $evt->keyval;
  my $cs = Gtk2::Gdk->keyval_name($kv);

  if($cs =~ /Return|Enter/)
  {
    if($typed eq $password)
    {
      do_ungrab();
      Gtk2->main_quit;
    }
    else
    {
      $typed="";
    }
  }
  elsif(length($cs) == 1 && $cs =~ /[[:print:]]/)
  {
    $typed .= $cs;
  }
  my $showtyped=$typed;
  if($noshow eq "stars")
  {
    $showtyped =~ s/[^*]/*/g;
  }
  elsif($noshow)
  {
    $showtyped="";
  }
  if(length($showtyped) > $maxshownlength)
  {
    $showtyped=substr($showtyped,0,$maxshownlength);
  }
  $l->set_text($message.$showtyped);
}
$w->add($eb);
$eb->add($l);
$w->add_events( [ qw(key_press_mask) ]);
$w->signal_connect('key_press_event', \&do_keypress);
$w->signal_connect('realize', sub { $w->window->move(@startpos); });
$w->signal_connect('map', sub { $gdkwin=$w->window; do_grab(); });
$w->show_all;
Gtk2->main;
