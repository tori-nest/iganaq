_default:
    @just --list

# Build project with Dune
[group('build')]
build:
    dune build

alias b := build

# Cleanup build artifacts
[group('build')]
clean:
    dune clean

alias c := clean

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

alias fb := full-build

# Check formatting and run tests with coverage
[group('checks')]
check: format-check cover

alias ck := check

# Run tests
[group('checks')]
test : build
    dune test

alias t := test

# Format all files
[group('checks')]
format:
    dune fmt
    dune promote

alias fmt := format

# Check formatting without changing files
[group('checks')]
format-check:
    dune fmt --preview

alias f := format-check

# Show system, compiler and tooling information
info:
    @echo OCaml version: $(ocamlc --version)
    @echo Dune version: $(dune --version)
    @echo Git version: $(git --version | cut -f 3 -d ' ')
    @echo Just version: $(just --version | cut -f 2 -d ' ')
    @echo OS/Arch: {{ os() }} {{ arch() }}
    @echo GCC Triplet: $(gcc -dumpmachine)
    @echo Shell: {{ env('SHELL') }}
