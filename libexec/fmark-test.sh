display_cmd_help() {
    echo "usage: fmark-test [--dbfile=DBFILE] [--help]"
    echo "Tests connection and HTTP status of bookmark URLs"
    echo
    echo "  --max-time=SECONDS    maximum time in seconds operation to take"
    echo "                        default to be 5"
    echo "  --threads=NUM         number of multiple requests to make"
    echo "                        default to be 10"
    echo "  --help                show this information"
}

quit() {
    kill -9 0
}

trap "quit" 1 2 3 15 24

fmark_init "$@"

threads=$(fmark_get_opt "threads" $@ || echo 10)
maxtime=$(fmark_get_opt "max-time" $@ || echo 5)

thread_fifo="/tmp/$$.thread"
mkfifo $thread_fifo
exec 9<>$thread_fifo

outlock_fifo="/tmp/$$.lock"
mkfifo $outlock_fifo
exec 8<>$outlock_fifo

for ((i = 0; i < $threads; i++)); do
    echo >&9
done

echo >&8

while read url <&0; do
    read -u 9
    {
        if expr "${url}" : "https*://.*" > /dev/null; then

            if http_code=$(curl -m $maxtime -iI -o /dev/null -s -w %{http_code} $url); then
                http_status=$http_code
            else
                http_status="ERR"
            fi

            msg="[${http_status}] ${url}"
        else
            http_status="IGN"
            msg="[IGN] ${url}"
        fi

        read -u 8
        {
            if [ "$http_status" = "IGN" ]; then
                fmark_color_print "${msg}" "black"
            elif [ "$http_status" = "ERR" ]; then
                fmark_color_print "${msg}" "red"
            elif [ $http_status -lt 300 ]; then
                fmark_color_print "${msg}" "green"
            elif [ $http_status -lt 400 ]; then
                fmark_color_print "${msg}" "yellow"
            else
                fmark_color_print "${msg}" "magenta"
            fi

            echo >&8
        }

        echo >&9
    }&
done
