This is a starter kit for bucklescript with [tea](https://github.com/OvermindDL1/bucklescript-tea). It uses [rollup.js](https://rollupjs.org/) to package the javascript and [serve](https://github.com/zeit/serve) to serve the release folder.

# Organisation

* The bucklescript code goes into _src/*.ml_
* The _release_ folder contains an _index.html_ and rollup bundles your js here in _main.js_

# Getting started

* copy or clone this repository
* change the names in package.json
* in the _rollup.config.js_ you can also change the name of the output, you also have to change this name in de _index.html_
* for consistency, also change the name in _bsconfig.json_

## Install

```
npm install
```

## Build

```
npm run build
```

## Watch

```
npm run watch
```

## Configuring with local OCaml

If you are using both ocaml(via local switch) and reason via npm/yarn. You need to switch the local ocaml to 4.02.3+buckle-master. 

Install merlin 2.5.4 in that switch and eval $(opam config env) to get VS Code plugin working.

```
opam switch 4.02.3+buckle-master
opam install merlin=2.5.4

eval `opam config eval`
code .
```

1. To configure OPAM in the current shell session, you need to run:

```
eval `opam config env --root=/home/lakret/.asdf/installs/ocaml/4.06.1`
```

2. To correctly configure OPAM for subsequent use, add the following
   line to your profile file (for instance ~/.profile):

```
. /home/lakret/.asdf/installs/ocaml/4.06.1/opam-init/init.sh > /dev/null 2> /dev/null || true
```

3. To avoid issues related to non-system installations of `ocamlfind`
   add the following lines to ~/.ocamlinit (create it if necessary):

```
let () =
  try Topdirs.dir_directory (Sys.getenv "OCAML_TOPLEVEL_PATH")
  with Not_found -> ()
;;
```

```
opam install core utop
```

```
asdf reshim ocaml
```

Merlin source config:
https://github.com/ocaml/merlin/wiki/project-configuration

Install bsb:

```
npm install -g bs-platform reason-cli
# or
yarn global add bs-platform
```

or locally: 

```
npm install --save-dev bs-platform
```


## Can I work on different switches at the same time in different shells ?

Yes. Use one of:

```
eval $(opam config env --switch <switch>)        # for the current shell
opam config exec --switch <switch> -- <command>  # for one command
```

This only affects the environment.
