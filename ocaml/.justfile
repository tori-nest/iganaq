set unstable

dependencies := \
    require('dune') && \
    require('entr') && \
    require('bisect-ppx-report')

_default:
    @just --list


# DEV

# Build and execute
[group('dev')]
execute *args:
    dune exec tori -- {{ args }}

alias e := execute

# Build and execute on file changes
[group('dev')]
execute-watch *args:
    dune exec --watch tori -- {{ args }}

alias ew := execute-watch

# Run tests on file changes
[group('dev')]
test-watch:
    dune test --watch

alias tw := test-watch

# Format check on file changes
[group('dev')]
format-watch:
    find . -regex '.*\.mli?$' | entr -c -- dune fmt --preview

alias fw := format-watch

# BUILD

# Build project with Dune
[group('build')]
build:
    dune build

alias b := build

# Cleanup build artifacts
[group('build')]
clean:
    dune clean

alias cl := clean

# Clean, build, run checks and tests with coverage
[group('build')]
full-build: clean check cover

alias fb := full-build


# CHECKS

# Check formatting and run tests with coverage
[group('checks')]
check: lint format-check cover

alias c := check

# Generate coverage files and report
[group('checks')]
cover: clean build
    find . -name '*.coverage' -exec rm -v '{}' ';'
    dune runtest --instrument-with bisect_ppx --force
    bisect-ppx-report html
    bisect-ppx-report summary

alias co := cover

# Run tests
[group('checks')]
test: build
    dune test

alias t := test

# Lint with semgrep
[group('checks')]
lint:
    semgrep scan --error

alias l := lint

# Format all files
[group('checks')]
format:
    dune fmt
    dune promote

alias f := format

# Check formatting without changing files
[group('checks')]
format-check:
    dune fmt --preview

alias fck := format-check


# UNGROUPED

# Show system, compiler and tooling information
info:
    @echo OCaml version: $(ocamlc --version)
    @echo Dune version: $(dune --version)
    @echo Git version: $(git --version | cut -f 3 -d ' ')
    @echo Just version: $(just --version | cut -f 2 -d ' ')
    @echo OS/Arch: {{ os() }} {{ arch() }}
    @echo GCC Triplet: $(gcc -dumpmachine)
    @echo Shell: {{ env('SHELL') }}
