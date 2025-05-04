export dependencies := \
    require('dune') + \
    require('ocamlformat') + \
    require('delta') + \
    require('entr') + \
    require('bisect-ppx-report')

set unstable

_default:
    @just --list


# DEV

# Build on changes
[group('dev')]
build-watch:
    dune build --watch

alias bw := build-watch

# Build and execute
[group('dev')]
execute *args:
    dune exec tori -- {{ args }}

alias e := execute

# Build and execute on changes
[group('dev')]
execute-watch *args:
    find lib bin -regex '.*\.mli?$' | entr -c -- dune exec tori -- {{ args }}

alias ew := execute-watch

# Build and execute on changes with a timeout
[group('dev')]
execute-watch-timeout seconds='2' *args:
    find lib bin -regex '.*\.mli?$' | \
        entr -cx -- timeout {{ seconds }} dune exec tori -- {{ args }}

alias ewt := execute-watch-timeout

# Run tests on changes
[group('dev')]
test-watch:
    dune test --watch

alias tw := test-watch

# Format check on changes
[group('dev')]
format-watch:
    find lib bin -regex '.*\.mli?$' | entr -c -- dune fmt --preview

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
    #!/usr/bin/env sh
    find . \
        \( -name '*.ml' -o -name '*.mli' \) \
        \( -path './lib/*' -o -path './bin/*' \) |
        xargs ocamlformat --check

alias fck := format-check

# Format specific files
[group('checks')]
[no-cd]
format-file *args:
    ocamlformat --inplace -- {{ args }}

alias ff := format-file

# Check formatting on specific files
[group('checks')]
[no-exit-message]
[no-cd]
format-check-file *args:
    #!/usr/bin/env sh
    files=$(printf '%s' "{{ args }}" | sed 's/ /\n/g')
    for file in $files; do
        if ocamlformat --check -- $file; then
            echo " [ OK ] $file"
        else
            echo " [ !! ] $file"
            extension=$(printf '%s' "$file" | rev | cut -d . -f 1 | rev)
            formatted="$(basename $file .$extension).fmt.$extension"
            ocamlformat "$file" > "$formatted"
            delta "$file" $formatted
        fi
    done

alias ffck := format-check-file

# Cleanup formatting temporary files
[group('checks')]
[no-cd]
format-file-cleanup:
    #!/usr/bin/env sh
    files=$(find . -regex '.*\.fmt\.[a-zA-Z0-9]+$')
    if [ -n "$files" ]; then
        printf '%s:\n%s\n\n%s\n%s\n > ' \
            'Files found' \
            "$files" \
            '[RETURN] Remove all' '[Ctrl-C] Abort'
        read _
        rm -v $files
    else
        echo 'No temporary formatting files found'
    fi

alias ffcl := format-file-cleanup

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
    @echo justfile dependencies: {{ dependencies }}


