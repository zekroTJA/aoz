set -e

function run_day {
    echo "--------- $1 ---------"
    ./zig-out/bin/$1
}

zig build

day=$1

[ "$day" == "all" ] && {
    days=$(ls -1 src | grep "day_")
    for day in $days; do
        run_day $day
    done
    
    exit 0
}

[ -z "$DAY" ] && {
    day=$(ls -r1 src | grep "day_" | head -1)
}

run_day $day