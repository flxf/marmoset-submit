#!/usr/bin/env perl

use WWW::Mechanize;
use IO::Prompt;
use strict;

my $thisclass = shift;
my $assignment = shift;
my $file = shift;
if(!$thisclass || !$assignment || !$file) {
  print "Usage:\n";
  print "./marmoset-submit.pl CS444 A1Code release.zip\n";
  exit;
}

my $m = WWW::Mechanize->new();

#This will redirect to CAS, where we auth.
$m->get("http://marmoset.student.cs.uwaterloo.ca");
my $password = prompt('Password: ', -e => '*');

my $fields = {
  'username' => 'mimcpher',
  'password' => $password,
};

$m->submit_form(form_number => 0, fields => $fields);

#Then we submit the "authenticate as" with the first option
$m->submit_form(form_number => 0);

my @whats = grep /td class=.description/, split("\n", $m->content);
my $idx = 1;
my $which = -1;
foreach(@whats) {
  print "$idx: ";
  if($_ =~ m/$assignment/) {
    print "Match: ";
    $which = $idx;
  }
  print $_ . "\n";
  $idx++;
}

if($which < 0) {
  die "Didn't find the assignment. Choose one of:";
}

my @submits = $m->follow_link( text => 'submit', n => $which );

if(!($m->content =~ m/Submit project $assignment for $thisclass in/)) {
  die "Submission page didn't match requested one. not submitting";
}

$m->form_number(0);
$m->field('file' => $file);
$m->submit();