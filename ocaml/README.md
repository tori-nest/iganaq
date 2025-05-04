## Configuration parser

Grammar:

    assignment  = { space }, key, { space }, equal, { space }, value, "\n"
    space       = " " | "\t"
    key         = letter, { letter | digit | "_" }
    equal       = "="
    valuable    = ( letter | digit | "_" | "-" | "~" | "/" ), { valuable }
    value       = valuable, { " " | valuable }

Written using the ISO 14977 EBNF Notation <https://www.cl.cam.ac.uk/~mgk25/iso-14977.pdf>. In this grammar, `digit` implies `decimal digit`.

See also:
    - Comparison of BNF notations: <https://www.cs.man.ac.uk/~pjj/bnf/ebnf.html>
    - W3C ABNF Notation: <https://www.w3.org/Notation.html>
    - IETF RFC 5234 ABNF Notation (replaces 4234, 2234): <https://www.rfc-editor.org/rfc/rfc5234>
