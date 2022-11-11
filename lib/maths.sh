#!/usr/bin/env bash

# This function can evaluate complex arithmetic expressions
# by passing it into the Ruby's Math module.
#
# Example: maths.eval '√(57)*⅓×(sin(π÷(1.3)))' => 1.66882
#
maths.eval() {
  local __math_chars=(!²³¹¼½¾×÷ΠΣ⁰ⁱ⁴⁵⁶⁷⁸⁹ⁿ⅓⅔⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞∅∈∉√∛∜∞∩∪∿⊂⊃⟌τ𝛕𝜏𝝉𝞃𝞽०१२३४५६७८९ℯ𝐞𝑒𝒆𝖾𝗲𝘦𝙚𝚎ｅπϖ𝛑𝛡𝜋𝜛𝝅𝝕𝝿𝞏𝞹𝟉𝐢𝑖𝒊𝒾𝓲𝔦𝕚𝖎𝗂𝗶𝘪𝙞𝚒)
  local -a __math_chars_array=($(echo "${__math_chars}" | sedx 's/(.)/\1 /g'))
  local __math_chars_array
  [[ -z "$1" ]] && {
    output.set-max-width 100
    output.set-min-width 40

    usage-box "maths.eval 'expression' [ floating precitions [ total width ] © Computes a mathematical expression with UTF support" \
      "Example 1." "maths.eval '√(57)*⅓×(sin(π÷(1.3)))' => 1.66882" \
      "Example 2." "maths.eval '5!×(ｅ)' => 326.19382" \
      "Special Characters:" "" \
      " 0 through 23" "${__math_chars_array[*]:0:24}" \
      "24 through 48" "${__math_chars_array[*]:24:24}" \
      "48 through 72" "${__math_chars_array[*]:48:24}" \
      "72 through 96" "${__math_chars_array[*]:72:24}"

    info "NOTE: ensure to use () brackets to group items you want to compute."
    info "NOTE: if in doubt, add more brackets :) "

    output.reset-min-max-width

    return 0
  }

  gem.install unicode_math >/dev/null

  local expression="$1"
  shift
  local output_precision="${1:-"5"}"
  shift
  local output_width="${1}"

  local ruby_script="require 'unicode_math'; printf('%${output_width}.${output_precision}f', (Math.module_eval { ${expression} }))"
  ruby_script="$(echo "${ruby_script}" | sedx 's/ ?(×|÷|!)/\.\1/g')"

  local temp_file
  temp_file="$(mktemp)"

  ruby -r 'unicode_math' -e "${ruby_script}" 2>"${temp_file}"

  local code="$?"
  [[ ${code} -ne 0 ]] && {
    error "Unable to perform an arithmetic expression:" \
      "${bldylw}${ruby_script}" >&2

    info "Error: \n${bldylw}$(cat "${temp_file}")"
    return 1
  }

  rm -f "${temp_file}"
  return 0
}


