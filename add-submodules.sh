for dir in ./plugins/*
do
    if [ -e $dir/.git ]; then
        urls=$(cat $dir/.git/config | grep url | xargs sh -c 'echo "$@" | cut -d\  -f 2')
        num_urls=$(echo $urls | wc -l)
        repo=$urls
        if [ $num_urls = "1" ]; then
            echo "adding $dir"
            echo "git submodule add $repo $dir"
            git submodule add $repo $dir
        else
            echo "$dir cannot be added because it has $num_urls urls: $urls"
        fi
    else
        echo "$dir cannot be added because it is not a git repo"
    fi
done


        
