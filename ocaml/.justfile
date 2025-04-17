set unstable

dependencies := \
    require('dune') && \
    require('entr') && \
    require('bisect-ppx-report')

_default:
    @just --list

# Build and execute
[group('dev')]
exec *args:
    dune exec tori -- {{ args }}

# Build and execute on file changes
[group('dev')]
exec-watch *args:
    dune exec --watch tori -- {{ args }}

# Run tests on file changes
[group('dev')]
test-watch:
    dune test --watch

# Format check on file changes
[group('dev')]
format-watch:
    find . -regex '.*\.mli?$' | entr -c -- dune fmt --preview

# Build project with Dune
[group('build')]
build:
    dune build

# Cleanup build artifacts
[group('build')]
clean:
    dune clean

# Generate coverage files and report
[group('checks')]
cover : clean build
    find . -name '*.coverage' -exec rm -v '{}' ';'
    dune runtest --instrument-with bisect_ppx --force
    bisect-ppx-report html
    bisect-ppx-report summary

# Clean, build, run checks and tests with coverage
[group('checks')]
full-build: clean check cover

# Check formatting and run tests with coverage
[group('checks')]
check: format-check cover

# Run tests
[group('checks')]
test : build
    dune test

# Format all files
[group('checks')]
format:
    dune fmt
    dune promote

# Check formatting without changing files
[group('checks')]
format-check:
    dune fmt --preview

# Show system, compiler and tooling information
info:
    @echo OCaml version: $(ocamlc --version)
    @echo Dune version: $(dune --version)
    @echo Git version: $(git --version | cut -f 3 -d ' ')
    @echo Just version: $(just --version | cut -f 2 -d ' ')
    @echo OS/Arch: {{ os() }} {{ arch() }}
    @echo GCC Triplet: $(gcc -dumpmachine)
    @echo Shell: {{ env('SHELL') }}
