package Padre::File::HTTP;

use 5.008;
use strict;
use warnings;

use Padre::File;

our $VERSION = '0.46';
our @ISA     = 'Padre::File';

sub new {
	my $class = shift;

        # Don't add a new overall-dependency to Padre:
        eval { require LWP::UserAgent; };
        if ($@) {
         warn 'LWP::UserAgent is not installed, Padre::File::HTTP currently depends on it.';
         return;
        }

	my $self = bless { Filename => $_[0], UA => LWP::UserAgent->new()}, $class;
	$self->{UA}->timeout(60); # TODO: Make this configurable
	return $self;
}

sub _request {
 
 my $self = shift;
 my $method = shift || 'GET';
 my $URL = shift || $self->{Filename};

 my $HTTP_Req = HTTP::Request->new($method,$URL);

 my $Result = $self->{UA}->request($HTTP_Req);

 if ($Result->is_success) {
  if (wantarray) {
   return $Result->content,$Result;
  } else {
   return $Result->content;
  }
 } else {
  if (wantarray) {
   return undef,$Result;
  } else {
   return;
  }
 }
}

sub size {
	my $self = shift;
	my ($Content,$Result) = $self->_request('HEAD');
	return $Result->header('Content-Length');
}

sub mode {
	my $self = shift;
	return 33024; # Currently fixed: read-only textfile
}

#TODO: Convert ugly HTTP date-format to a usable timestamp
#sub mtime {
#	my $self = shift;
#	my ($Content,$Result) = $self->_request('HEAD');
#	$Result->header('Last-Modified');
#	return;
#}

sub exists {
	my $self = shift;
	my ($Content,$Result) = $self->_request('HEAD');
	return 1 if $Result->code == 200;
	return 0;
}

sub read {
	my $self = shift;
	return scalar($self->_request());

}

# TODO: Maybe use WebDAV to enable writing
#sub write {
#	my $self    = shift;
#	my $content = shift;
#	my $encode  = shift || ''; # undef encode = default, but undef will trigger a warning
#
#	my $fh;
#	if ( !open $fh, ">$encode", $self->{Filename} ) {
#		$self->{error} = $!;
#		return 0;
#	}
#	print {$fh} $content;
#	close $fh;
#
#	return 1;
#}

1;

# Copyright 2008-2009 The Padre development team as listed in Padre.pm.
# LICENSE
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl 5 itself.
