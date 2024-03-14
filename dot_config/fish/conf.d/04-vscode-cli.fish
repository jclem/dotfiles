set code_dir "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

if test -d $code_dir
  fish_add_path --append $code_dir
end
