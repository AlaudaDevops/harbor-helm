#!/bin/sh
# exports environment will accept a directory
# and range all files in directory
# then export $FILE_NAME=$FILE_CONTENT
# if file content has multi line, will just skip it.

set -e

export_env() {
    export TEST_VAR="hello"

    directory=$1

    if [ -z "$directory" ] || [ ! -d "$directory" ]; then
        echo "skip exporting env, $directory is not exists: $directory"
        return 0
    fi

    ls -la $directory

    if [ ! "$(ls -A $directory)" ]; then
      ls -la
      echo "$directory is empty"
      # prevent some unexpected delete in last 'delay deleting'
      # just wait healthy check to kill pod
      return 1
    fi

    # range all files (recursively) and set environment
    for file in $(find "$directory" -type f); do
        if [ -r "$file" ]; then
            if ([ $(wc -l < "$file") -eq 0 ] && [ $(wc -w < "$file") -gt 0 ]) || [ $(wc -l < "$file") -eq 1 ] ; then
                filename=$(basename "$file")
                content=$(cat "$file")

                export "$filename"="$content"

                echo "set env: $filename"
            fi
        else
            echo "cannot read file: $file"
            return 1
        fi
    done

    # DISABLE: this 'delay delete' solution will cause problem that cannot automatically restore when container CrashLoopBackOff
    # because the env-files has been deleted and the init container would not restart when only container crash in kubernetes
    # https://github.com/kubernetes/enhancements/issues/3676
    #
    # we should delay to delete for preventing main process start failed but losing env-files in next starting loop
    # bash -c "sleep 600; echo \"remove $directory/*\"; rm -r $directory/*" &
}

export_env "$@"