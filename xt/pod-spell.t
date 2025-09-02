use strict;
use warnings;

use Test::More;
use Test::Spelling;
use Pod::Wordlist;

$ENV{LANG} = 'en_US';

add_stopwords(<DATA>);
all_pod_files_spelling_ok( qw( script ) );


__DATA__

md
policyfiles
Rindfrey

