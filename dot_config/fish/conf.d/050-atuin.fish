if string match -rq '^fish, version [4-9]\\.' (fish --version)
  atuin init fish | string replace -r '^bind(.*) -k ' 'bind$1 ' | source
else
  atuin init fish | source
end
