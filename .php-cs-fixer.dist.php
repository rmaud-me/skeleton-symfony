<?php

$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__)
    ->exclude(['var', 'config', 'vendor', 'public'])
;

// You can visualize the effect of each rule with this site : https://mlocati.github.io/php-cs-fixer-configurator
return (new PhpCsFixer\Config())
    ->setRules([
        '@Symfony' => true,
        '@Symfony:risky' => true,
        'concat_space' => ['spacing' => 'one'],
        'phpdoc_align' => ['align' => 'left'],
        'declare_strict_types' => true,
        'native_constant_invocation' => true,
        'native_function_invocation' => [
            'include' => ['@internal', '@compiler_optimized'],
        ],
        'single_line_throw' => false,
        'phpdoc_to_comment' => [
            'ignored_tags' => ['todo', 'var', 'see', 'phpstan-ignore-next-line'],
        ],
        'trailing_comma_in_multiline' => [
            'elements' => ['arrays', 'array_destructuring', 'match'],
        ],
        'no_null_property_initialization' => false,
        'blank_line_before_statement' => [
            'statements' => [
                'break',
                'continue',
                'declare',
                'return',
                'throw',
                'try',
            ],
        ],
    ])
    ->setFinder($finder)
    ->setRiskyAllowed(true)
;
