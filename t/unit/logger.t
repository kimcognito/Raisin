
use strict;
use warnings;

use Test::More;

use Raisin::Logger;

my @CASES = (
    {
        min_level => 'debug',
        input => { level => 'error', message => 'some error' },
        expected => 'ERROR some error',
    },
    {
        min_level => 'debug',
        input => { level => 'warn', message => 'some warn' },
        expected => 'WARN some warn',
    },
    {
        min_level => 'debug',
        input => { level => 'debug', message => 'some debug' },
        expected => 'DEBUG some debug',
    },
    {
        min_level => 'warning',
        input => { level => 'debug', message => 'some debug' },
        expected => undef,
    },
);

subtest 'log' => sub {
    close STDERR;
    for my $case (@CASES) {
        my $logger = Raisin::Logger->new(min_level => $case->{min_level});
        isa_ok $logger, 'Raisin::Logger', "logger ($case->{min_level})";

        my $OUT;
        open STDERR, '>', \$OUT or BAIL_OUT("Can't open STDERR $!");

        $logger->log(level => $case->{input}{level}, message => $case->{input}{message});
        is $OUT, $case->{expected}, $case->{input}{level};

        close STDERR;
    }
};

done_testing;
