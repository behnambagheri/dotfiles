function noc
  if test (count $argv) -gt 0
    # If arguments are provided, process them as files
    grep -vEra '^\s*[#;]|^\s*$' $argv
  else
    # If no arguments, read from stdin
    grep -vEra '^\s*[#;]|^\s*$'
  end
end
