#!/bin/bash

target_dir="${1:-.}"

if [[ ! -d "$target_dir" ]]; then
  echo "Error: Directory does not exist: $target_dir" >&2
  exit 1
fi

declare -a image_list

function rand() {
  min=$1
  max=$(($2 - $min + 1))
  num=$(($RANDOM + 1000000000))
  echo $(($num % $max + $min))
}

while IFS= read -r -d $'\0' file; do
  image_list+=("$file")
done < <(find "$target_dir" -type f \( \
  -iname "*.jpg" -o \
  -iname "*.jpeg" -o \
  -iname "*.png" -o \
  -iname "*.gif" -o \
  -iname "*.webp" -o \
  -iname "*.bmp" -o \
  -iname "*.tiff" \) -print0)

random_num=$(rand 0 ${#image_list[@]})

osascript -e "tell application \"System Events\" to set picture of every desktop to \"${image_list[$random_num]}\""
# printf "random %d :\n" "$random_num"
echo "${image_list[$random_num]}"
