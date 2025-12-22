# Notes aggregation justfile
# Uses sparse checkout to pull notes from source repos

sources_file := "sources.yml"

# Aggregate all sources using sparse checkout
aggregate:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p .sources notes

    for key in $(yq '.notes | keys | .[]' {{sources_file}}); do
        repo=$(yq ".notes.$key.repo" {{sources_file}})
        path=$(yq ".notes.$key.path" {{sources_file}})
        ref=$(yq ".notes.$key.ref // \"main\"" {{sources_file}})
        private=$(yq ".notes.$key.private // false" {{sources_file}})

        echo "Processing $key ($repo:$path@$ref)..."

        # Use appropriate token for private repos
        if [[ "$private" == "true" ]] && [[ -n "${PRIVATE_REPO_TOKEN:-}" ]]; then
            clone_url="https://${PRIVATE_REPO_TOKEN}@github.com/$repo.git"
        else
            clone_url="https://github.com/$repo.git"
        fi

        if [[ -d ".sources/$key/.git" ]]; then
            git -C ".sources/$key" pull --ff-only 2>/dev/null || true
        else
            git clone --filter=blob:none --sparse --depth=1 \
                "$clone_url" ".sources/$key"
            git -C ".sources/$key" sparse-checkout set "$path"
        fi

        # Create symlink in notes/
        rm -f "notes/$key"
        ln -sfn "../.sources/$key/$path" "notes/$key"
    done

    echo "Aggregation complete."

# Open in Obsidian
open: aggregate
    open -a Obsidian "$(pwd)"

# Clean aggregated sources
clean:
    rm -rf .sources
    find notes -type l -delete

# List configured sources
list:
    @yq '.notes | keys | .[]' {{sources_file}}

# Update all sources
update:
    #!/usr/bin/env bash
    for key in $(yq '.notes | keys | .[]' {{sources_file}}); do
        if [[ -d ".sources/$key/.git" ]]; then
            echo "Updating $key..."
            git -C ".sources/$key" pull --ff-only
        fi
    done
