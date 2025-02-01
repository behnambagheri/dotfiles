function noc
  grep -vEra '^\s*[#;]|^\s*$' $argv
end
