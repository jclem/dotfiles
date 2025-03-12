set -l postgres_bin /Applications/Postgres.app/Contents/Versions/latest/bin
if test -d $postgres_bin
    fish_add_path $postgres_bin
end
