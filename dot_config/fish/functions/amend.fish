function amend
  git commit --amend --no-edit --no-verify
  git push --force-with-lease
end
