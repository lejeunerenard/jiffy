requires 'perl', '5.008005';

requires 'MongoDB';
requires 'Moo';
requires 'YAML::Any';

on test => sub {
    requires 'Test::More', '0.88';
};
