if test (uname) = Darwin && type -q ruby
    set -x GEM_HOME /opt/homebrew/lib/ruby/gems/(ruby -e 'puts RUBY_VERSION')
    fish_add_path "$GEM_HOME/bin"
end