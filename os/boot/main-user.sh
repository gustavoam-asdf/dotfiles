#!/bin/sh

dir=$(readlink -f "$(dirname "$0")")
scripts_dir="$dir/scripts/user"

# Run all scripts in the scripts dir

scripts=$(ls $scripts_dir | xargs -I _ echo "$scripts_dir/_")

for script in $scripts; do
	sh $script &
done