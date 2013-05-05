package GeckBot::Logger;

use strict;
use warnings;

use base qw/DBIx::Class::Schema/;

# load all Result classes in Library/Schema/Result/
__PACKAGE__->load_namespaces();


1;