target_directory=""
regex=""
date="2050-01-01"
na=0
da=0
sa=0
ra=0
aa=0

function spacecheck() {
    for dir in "$@"; do
        if [ -d "$dir" ]; then
            target_directory="$dir"
        fi
    done

    while getopts "n:d:s:ral" opt; do
        case $opt in
            n)
                regex="$OPTARG"
                if is_regex "$regex"; then
                    na=1
                else
                    echo "Missing or invalid regular expression argument for -n option."
                    exit 1
                fi
                ;;
            d)
                date="$OPTARG"
                if is_date "$date"; then
                    echo "$date"
                    da=1
                else
                    echo "Missing or invalid date argument for -d option."
                    exit 1
                fi
                ;;
            s)
                minsize="$OPTARG"
                
                ;;
            r)
                # ordem inversa
                ra=1
                ;;
            a)
                # ordem alfabética
                aa=1
                ;;
            l)
                # número de linhas que o utilizador quer na tabela
                ;;
            *)
                ;;
        esac
    done

    name_filter "$target_directory" "$regex"
    size_filter "$target_directory" "$minsize"
}

function name_filter() {
    repository="$1"
    padrao="$2"

    if [ $na -eq 1 ]; then
        echo "SIZE NAME $repository $padrao"
    

        # Only search within the given directory, not subdirectories
        for k in $(find "$repository" -maxdepth 1 -type d); do
        
            size=0
            folder=$(echo $k | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"
            for i in $(find "$k" -type f -regex ".*$padrao.*"); do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done
            echo "Size: $size"
        done
    fi
}

function size_filter() {
    repository="$1"
    minsize="$2"

    if [ $sa -eq 1 ]; then
        echo "SIZE NAME $repository $minsize"

        for k in $(find "$repository" -type d); do
            size=0
            folder=$(echo $k | grep -P -o '(?<=\.\.\/).*')
            echo "Folder: $folder"
            for i in $(find "$k" -type f -size +"$minsize"c); do
                size_i=$(du -b "$i" | cut -f1)
                size=$(($size+$size_i))
            done
            echo "Size: $size"
        done
    fi
}

function is_date() {
    local date_str="$1"
    date -d "$date_str" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    else
        return 1
    fi
}

function is_regex() {
    local pattern="$1"

    # Verifica se o padrão parece ser uma expressão regular válida
    if [[ "$pattern" =~ ^[a-zA-Z0-9.*?]+$ ]]; then
        return 0
    else
        return 1
    fi
}



