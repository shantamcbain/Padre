package Padre::Unload;

# Inlined version of Class::Unload with a few more tricks up it's sleeve

use 5.008;
use strict;
use warnings;

our $VERSION = '0.91';

sub unload {
	my $module = shift;

	require Class::Inspector;
	return unless Class::Inspector->loaded($module);

	# Flush inheritance caches
	@{$module . '::ISA'} = ();

	# Delete all symbols except other namespaces
	my $symtab = $module . '::';
	for my $symbol ( keys %$symtab ) {
		next if $symbol =~ /\A[^:]+::\z/;
		delete $symtab->{$symbol};
	}

	my $inc_file = join( '/', split /(?:'|::)/, $module ) . '.pm';
	delete $INC{ $inc_file };

	return 1;
}

1;