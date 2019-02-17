#!/bin/bash

script_dir="$(cd "$(dirname $0)" ; pwd)"

# style functions:
    _bold       () { while read a ; do echo -e "\e[1m$a\e[0m"; done  } ; export -f _bold
    _underline  () { while read a ; do echo -e "\e[4m$a\e[0m"; done  } ; export -f _underline
    _blink      () { while read a ; do echo -e "\e[5m$a\e[0m"; done  } ; export -f _blink
    #-
    _red        () { while read a ; do echo -e "\e[31m$a\e[0m"; done } ; export -f _red
    _green      () { while read a ; do echo -e "\e[32m$a\e[0m"; done }  ; export -f _green
    _yellow     () { while read a ; do echo -e "\e[33m$a\e[0m"; done } ; export -f _yellow
    _blue       () { while read a ; do echo -e "\e[34m$a\e[0m"; done } ; export -f _blue
    _magenta    () { while read a ; do echo -e "\e[35m$a\e[0m"; done } ; export -f _magenta
    _cyan       () { while read a ; do echo -e "\e[36m$a\e[0m"; done } ; export -f _cyan
    _lgray      () { while read a ; do echo -e "\e[37m$a\e[0m"; done } ; export -f _lgray
    _dgray      () { while read a ; do echo -e "\e[90m$a\e[0m"; done } ; export -f _dgray
    _lred       () { while read a ; do echo -e "\e[91m$a\e[0m"; done } ; export -f _lred
    _lyellow    () { while read a ; do echo -e "\e[93m$a\e[0m"; done } ; export -f _lyellow
    _lblue      () { while read a ; do echo -e "\e[94m$a\e[0m"; done } ; export -f _lblue
    _lmagenta   () { while read a ; do echo -e "\e[95m$a\e[0m"; done } ; export -f _lmagenta
    _lcyan      () { while read a ; do echo -e "\e[96m$a\e[0m"; done } ; export -f _lcyan
####


list_tasks () {
    find "$script_dir/tasks" -type f | sort
}

menu () {
    mapfile -t task_titles < <(list_tasks | while read t; do meta_field "$(extract_task_meta $t)" Title ; done)

    while true ; do
        echo "Task Menu:"
        local ctr=0
        for ln in "${task_titles[@]}" ; do
            ctr=$(( $ctr + 1 ))
            echo "   $ctr : $ln"
        done
        echo
        echo "  q : Quit"

        read -p " Choose : " response
        if (( $? == 0 )) ; then
            case $response in
                [1-9]|[0-9][0-9])
                    task_file="$(list_tasks | sed -n ${response}p)"
                    if [[ -z "$task_file" ]] ; then
                        echo "Invalid !"
                        continue
                    fi

                    execute_task "$task_file"

                    ;;
                q)
                    break
                    ;;
            esac
        fi
    done
}

extract_task_meta () {
    local task_file="$1"
    #
    awk '/^#-+\s*$/{exit}; { sub(/^#/,"",$0) ; print }' "$task_file"
}

meta_field () {
    local full_meta="$1"
    local meta_field="$2"
    #
    echo "$full_meta" | awk -v metaf="$meta_field" 'BEGIN { IGNORECASE=1 ; q=0 } {if ( q==1 && $0 ~ /^([a-zA-Z0-9_-]+:|-+$)/ ) { exit } ; if ( $0 ~ "^"metaf":" ) { q = 1 ; gsub("^"metaf":","",$0) } ;  if ( q == 1 ) { gsub(/^\s+/,"",$0);  print } }'
}

_temporize_task () {
    local task_file="$1"
    #
    local new_name="/tmp/$RANDOM$RANDOM$RANDOM.bash"
    awk 'BEGIN{b=0} {if (b) print } /^#-+\s*$/{b=1}  ' "$task_file" > "$new_name"
    chmod +x "$new_name"
    echo "$new_name"
}

execute_task () {
    local task_file="$1"
    #
    local meta_info="$(extract_task_meta "$task_file")"

    # Show information
    meta_field "$meta_info" Title
    echo
    meta_field "$meta_info" desCriPtIOn | sed 's/^/    /'
    echo
    echo "Default Value Description:" | sed 's/^/  /'
    meta_field "$meta_info" default-description  | sed 's/^/    /'

    # Make a copy
    tmp_task_file="$(_temporize_task $task_file)"

    # Ask user
    while true ; do
        echo
        read -n 1 -p 'What next? [q/e/r/h]' response
        if (( $? == 0 )) ; then
            echo
            case  $response in
                h)
                    echo "e : edit task before running (recommended"
                    echo "r : run task without editing"
                    echo "q : return to menu"
                    echo "h : shows this help list!"
                    ;;
                e)
                    vim "$tmp_task_file"
                    ;;
                q)
                    break
                    ;;
                r)
                    $tmp_task_file
                    if (( $? == 0 )) ; then
                        echo "Successful!"
                        break
                    else
                        echo "Failed!!"
                    fi
                    ;;
                *)
                    echo "Invalid!"
            esac
        fi
    done
    echo

    # Clean up
    rm "$tmp_task_file"
}


#execute_task /home/shak/github/roboarch/src/tasks/00-gparted.bash

menu


