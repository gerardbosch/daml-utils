#!/usr/bin/env bash

DOC="Generate Java bindings for DAML.

It generates the package (mvn package) for the current directory DAML project.

  Usage:
    generate-java-bindings.sh [options] <basepackage>

    basepackage is the base Java package for the generated code (e.g. com.example)

    Options:
      -i --install       Install the generated library in Maven local repository (mvn install).
      -o --output=<dir>  The output directory for the bindings generation [default: daml.java].
"
# docopt parser below, refresh this parser with `docopt.sh generate-java-bindings.sh`
# shellcheck disable=2016,1075
docopt() { parse() { if ${DOCOPT_DOC_CHECK:-true}; then local doc_hash
doc_hash=$(printf "%s" "$DOC" | shasum -a 256)
if [[ ${doc_hash:0:5} != "$digest" ]]; then
stderr "The current usage doc (${doc_hash:0:5}) does not match \
what the parser was generated with (${digest})
Run \`docopt.sh\` to refresh the parser."; _return 70; fi; fi; local root_idx=$1
shift; argv=("$@"); parsed_params=(); parsed_values=(); left=(); testdepth=0
local arg; while [[ ${#argv[@]} -gt 0 ]]; do if [[ ${argv[0]} = "--" ]]; then
for arg in "${argv[@]}"; do parsed_params+=('a'); parsed_values+=("$arg"); done
break; elif [[ ${argv[0]} = --* ]]; then parse_long
elif [[ ${argv[0]} = -* && ${argv[0]} != "-" ]]; then parse_shorts
elif ${DOCOPT_OPTIONS_FIRST:-false}; then for arg in "${argv[@]}"; do
parsed_params+=('a'); parsed_values+=("$arg"); done; break; else
parsed_params+=('a'); parsed_values+=("${argv[0]}"); argv=("${argv[@]:1}"); fi
done; local idx; if ${DOCOPT_ADD_HELP:-true}; then
for idx in "${parsed_params[@]}"; do [[ $idx = 'a' ]] && continue
if [[ ${shorts[$idx]} = "-h" || ${longs[$idx]} = "--help" ]]; then
stdout "$trimmed_doc"; _return 0; fi; done; fi
if [[ ${DOCOPT_PROGRAM_VERSION:-false} != 'false' ]]; then
for idx in "${parsed_params[@]}"; do [[ $idx = 'a' ]] && continue
if [[ ${longs[$idx]} = "--version" ]]; then stdout "$DOCOPT_PROGRAM_VERSION"
_return 0; fi; done; fi; local i=0; while [[ $i -lt ${#parsed_params[@]} ]]; do
left+=("$i"); ((i++)) || true; done
if ! required "$root_idx" || [ ${#left[@]} -gt 0 ]; then error; fi; return 0; }
parse_shorts() { local token=${argv[0]}; local value; argv=("${argv[@]:1}")
[[ $token = -* && $token != --* ]] || _return 88; local remaining=${token#-}
while [[ -n $remaining ]]; do local short="-${remaining:0:1}"
remaining="${remaining:1}"; local i=0; local similar=(); local match=false
for o in "${shorts[@]}"; do if [[ $o = "$short" ]]; then similar+=("$short")
[[ $match = false ]] && match=$i; fi; ((i++)) || true; done
if [[ ${#similar[@]} -gt 1 ]]; then
error "${short} is specified ambiguously ${#similar[@]} times"
elif [[ ${#similar[@]} -lt 1 ]]; then match=${#shorts[@]}; value=true
shorts+=("$short"); longs+=(''); argcounts+=(0); else value=false
if [[ ${argcounts[$match]} -ne 0 ]]; then if [[ $remaining = '' ]]; then
if [[ ${#argv[@]} -eq 0 || ${argv[0]} = '--' ]]; then
error "${short} requires argument"; fi; value=${argv[0]}; argv=("${argv[@]:1}")
else value=$remaining; remaining=''; fi; fi; if [[ $value = false ]]; then
value=true; fi; fi; parsed_params+=("$match"); parsed_values+=("$value"); done
}; parse_long() { local token=${argv[0]}; local long=${token%%=*}
local value=${token#*=}; local argcount; argv=("${argv[@]:1}")
[[ $token = --* ]] || _return 88; if [[ $token = *=* ]]; then eq='='; else eq=''
value=false; fi; local i=0; local similar=(); local match=false
for o in "${longs[@]}"; do if [[ $o = "$long" ]]; then similar+=("$long")
[[ $match = false ]] && match=$i; fi; ((i++)) || true; done
if [[ $match = false ]]; then i=0; for o in "${longs[@]}"; do
if [[ $o = $long* ]]; then similar+=("$long"); [[ $match = false ]] && match=$i
fi; ((i++)) || true; done; fi; if [[ ${#similar[@]} -gt 1 ]]; then
error "${long} is not a unique prefix: ${similar[*]}?"
elif [[ ${#similar[@]} -lt 1 ]]; then
[[ $eq = '=' ]] && argcount=1 || argcount=0; match=${#shorts[@]}
[[ $argcount -eq 0 ]] && value=true; shorts+=(''); longs+=("$long")
argcounts+=("$argcount"); else if [[ ${argcounts[$match]} -eq 0 ]]; then
if [[ $value != false ]]; then
error "${longs[$match]} must not have an argument"; fi
elif [[ $value = false ]]; then
if [[ ${#argv[@]} -eq 0 || ${argv[0]} = '--' ]]; then
error "${long} requires argument"; fi; value=${argv[0]}; argv=("${argv[@]:1}")
fi; if [[ $value = false ]]; then value=true; fi; fi; parsed_params+=("$match")
parsed_values+=("$value"); }; required() { local initial_left=("${left[@]}")
local node_idx; ((testdepth++)) || true; for node_idx in "$@"; do
if ! "node_$node_idx"; then left=("${initial_left[@]}"); ((testdepth--)) || true
return 1; fi; done; if [[ $((--testdepth)) -eq 0 ]]; then
left=("${initial_left[@]}"); for node_idx in "$@"; do "node_$node_idx"; done; fi
return 0; }; optional() { local node_idx; for node_idx in "$@"; do
"node_$node_idx"; done; return 0; }; switch() { local i
for i in "${!left[@]}"; do local l=${left[$i]}
if [[ ${parsed_params[$l]} = "$2" ]]; then
left=("${left[@]:0:$i}" "${left[@]:((i+1))}")
[[ $testdepth -gt 0 ]] && return 0; if [[ $3 = true ]]; then
eval "((var_$1++))" || true; else eval "var_$1=true"; fi; return 0; fi; done
return 1; }; value() { local i; for i in "${!left[@]}"; do local l=${left[$i]}
if [[ ${parsed_params[$l]} = "$2" ]]; then
left=("${left[@]:0:$i}" "${left[@]:((i+1))}")
[[ $testdepth -gt 0 ]] && return 0; local value
value=$(printf -- "%q" "${parsed_values[$l]}"); if [[ $3 = true ]]; then
eval "var_$1+=($value)"; else eval "var_$1=$value"; fi; return 0; fi; done
return 1; }; stdout() { printf -- "cat <<'EOM'\n%s\nEOM\n" "$1"; }; stderr() {
printf -- "cat <<'EOM' >&2\n%s\nEOM\n" "$1"; }; error() {
[[ -n $1 ]] && stderr "$1"; stderr "$usage"; _return 1; }; _return() {
printf -- "exit %d\n" "$1"; exit "$1"; }; set -e; trimmed_doc=${DOC:0:466}
usage=${DOC:114:60}; digest=28809; shorts=(-o -i); longs=(--output --install)
argcounts=(1 0); node_0(){ value __output 0; }; node_1(){ switch __install 1; }
node_2(){ value _basepackage_ a; }; node_3(){ optional 0 1; }; node_4(){
optional 3; }; node_5(){ required 4 2; }; node_6(){ required 5; }
cat <<<' docopt_exit() { [[ -n $1 ]] && printf "%s\n" "$1" >&2
printf "%s\n" "${DOC:114:60}" >&2; exit 1; }'; unset var___output \
var___install var__basepackage_; parse 6 "$@"; local prefix=${DOCOPT_PREFIX:-''}
local docopt_decl=1; [[ $BASH_VERSION =~ ^4.3 ]] && docopt_decl=2
unset "${prefix}__output" "${prefix}__install" "${prefix}_basepackage_"
eval "${prefix}"'__output=${var___output:-daml.java}'
eval "${prefix}"'__install=${var___install:-false}'
eval "${prefix}"'_basepackage_=${var__basepackage_:-}'; local docopt_i=0
for ((docopt_i=0;docopt_i<docopt_decl;docopt_i++)); do
declare -p "${prefix}__output" "${prefix}__install" "${prefix}_basepackage_"
done; }
# docopt parser above, complete command for generating this parser is `docopt.sh generate-java-bindings.sh`


check_env() {
  # Check daml
  [[ ! -x "$(command -v daml)" ]] &&
    echo "daml command not found in PATH. Install DAML SDK and assure it is on PATH." &&
    exit 11
    # Check Maven
  [[ ! -x "$(command -v mvn)" ]] &&
    echo "mvn command not found in PATH. Install Maven and assure it is on PATH. You can install it with sdkman.io if you like :)" &&
    exit 12
}

set_daml_versions() {
  [[ -f "$DAML_YAML" ]] || exit 13
  sdk_version=$(grep '^sdk-version:' "$DAML_YAML" | cut -d ' ' -f2)
  contract_version=$(grep '^version:' "$DAML_YAML" | cut -d ' ' -f2)

  VERSIONS=("$sdk_version" "$contract_version")
}

get_daml_bindings_dep() {
  cat <<EOF
    <dependency>
        <groupId>com.daml</groupId>
        <artifactId>bindings-rxjava</artifactId>
        <version>${SDK_VERSION}</version>
    </dependency>
EOF
}

generate_from_archetype() {

    local pom_file="$1"

    mvn -B archetype:generate \
      -DgroupId="${_basepackage_}" \
      -DartifactId="$PROJECT_NAME" \
      -DarchetypeGroupId="org.apache.maven.archetypes" \
      -DarchetypeArtifactId="maven-archetype-quickstart" &&
    find . -type f -name '*.java' | xargs rm -f   # rm code from archetype

    # Set version from daml.yaml
    sed -i -e "s|<version>1.0-SNAPSHOT</version>|<version>${CONTRACT_VERSION}-SNAPSHOT</version>|" "$pom_file"

    # Fix compiler version
    sed -i -e 's/<maven.compiler.source>1.7/<maven.compiler.source>1.8/' \
           -e 's/<maven.compiler.target>1.7/<maven.compiler.target>1.8/' \
      "$pom_file"

    # Add DAML Java bindings required dependency to POM
    local bindings_dep=$(get_daml_bindings_dep)
    bindings_dep=${bindings_dep//$'\n'/\\$'\n'}   # escape \n with \\n for sed to work
    sed -i "s|<dependencies>|<dependencies>\n${bindings_dep}|" "$pom_file"
}

# Create an empty Maven project for generated bindings
create_maven_project() {
  (
    local pom_file="${PWD}/${__output}/${PROJECT_NAME}/pom.xml"

    mkdir -p "$__output"
    cd "$__output"
    [[ -f "$pom_file" ]] || generate_from_archetype "$pom_file"
  )
}

mvn_build() {
  (
    cd "${__output}/${PROJECT_NAME}"
    local mvn_command=$(if "$__install"; then echo "install"; else echo "package"; fi)
    mvn $mvn_command
  )
}

main() {
  echo -e "\nGenerating Maven library with DAML bindings...\n"

  create_maven_project

  echo "Building DAR..."
  local dar_file=$(daml build | sed --quiet --regexp-extended -e 's/Created\s+(.*\.dar)/\1/p')

  # and generate bindings into Maven project src dir
  daml codegen java -o "${__output}/${PROJECT_NAME}/src/main/java" "${dar_file}=${_basepackage_}"

  mvn_build
}

# Constants
DAML_YAML="daml.yaml"

# Parse arguments
eval "$(docopt "$@")"   # See https://github.com/andsens/docopt.sh for the magic :)

check_env
PROJECT_NAME=$(grep '^name:' "$DAML_YAML" | cut -d ' ' -f2)
set_daml_versions
SDK_VERSION=${VERSIONS[0]}
CONTRACT_VERSION=${VERSIONS[1]}
main "$@"
