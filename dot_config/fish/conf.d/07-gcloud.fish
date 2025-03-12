set -l gcloud_suffix /share/google-cloud-sdk/path.fish.inc
if command -q brew && test -f "$(brew --prefix)$gcloud_suffix"
    source "$(brew --prefix)$gcloud_suffix"
end
